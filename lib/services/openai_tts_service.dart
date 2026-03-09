import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';
import '../config/tts_voice_config.dart';
import 'analytics_service.dart';
import 'openai_tts_playback_web.dart' if (dart.library.io) 'openai_tts_playback_io.dart' as playback;
import 'tts_cache_key_util.dart';
import 'tts_debug_collector.dart';

/// DB 保存音声のみで再生するサービス
/// - DB 直参照のみ。ミス時は Edge/OpenAI を呼ばず例外をスロー
/// - 失敗時は flutter_tts へフォールバックしない（課金防止・挙動の一貫性）
class OpenAiTtsService {
  /// デプロイWebのネットワーク遅延を考慮し、250ms→800msに拡張
  static const _dbTimeout = Duration(milliseconds: 800);
  static const _bucket = 'tts-audio';

  // #region agent log
  Future<void> _agentDebugLog({
    required String runId,
    required String hypothesisId,
    required String location,
    required String message,
    required Map<String, Object?> data,
  }) async {
    try {
      await http.post(
        Uri.parse('http://127.0.0.1:7637/ingest/26b6c108-ae04-4eec-a0d9-b0c254d481bc'),
        headers: const {
          'Content-Type': 'application/json',
          'X-Debug-Session-Id': '528958',
        },
        body: jsonEncode({
          'sessionId': '528958',
          'runId': runId,
          'hypothesisId': hypothesisId,
          'location': location,
          'message': message,
          'data': data,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );
    } catch (_) {
      // ログ送信失敗時はアプリ動作へ影響させない
    }
  }
  // #endregion

  /// Supabase が初期化済みか
  static bool get isAvailable {
    try {
      return Supabase.instance.client != null;
    } catch (_) {
      return false;
    }
  }

  /// DB lookup 結果（観測用）
  static const String _dbHit = 'hit';
  static const String _dbMiss = 'miss';
  static const String _dbResultTimeout = 'timeout';
  static const String _dbError = 'error';

  /// DB から storage_path を取得し Public URL を構築
  /// 戻り値: (url, dbResult, dbElapsedMs, errorCode)
  Future<({String? url, String dbResult, int dbElapsedMs, String? errorCode})>
      _tryFetchUrlFromDb({
    required String text,
    String language = 'en-US',
    required String voice,
    double speakingRate = 1.0,
  }) async {
    final normalized = normalizeTextForCache(text);
    if (normalized.isEmpty) {
      return (url: null, dbResult: _dbMiss, dbElapsedMs: 0, errorCode: null);
    }

    final keyStr = buildTtsCacheKey(
      text: normalized,
      language: language,
      voice: voice,
      speed: speakingRate,
    );
    final keyHash = sha256Hex(keyStr);
    final stopwatch = Stopwatch()..start();

    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('tts_assets')
          .select('storage_path')
          .eq('cache_key', keyHash)
          .maybeSingle()
          .timeout(_dbTimeout, onTimeout: () {
        throw TimeoutException('TTS DB lookup timeout');
      });

      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;

      final row = response is Map<String, dynamic> ? response : null;
      final path = row?['storage_path'] as String?;
      if (path == null || path.isEmpty) {
        return (url: null, dbResult: _dbMiss, dbElapsedMs: elapsed, errorCode: null);
      }

      final baseUrl = EnvConfig.supabaseUrl.replaceAll(RegExp(r'/$'), '');
      final url = '$baseUrl/storage/v1/object/public/$_bucket/$path';
      return (url: url, dbResult: _dbHit, dbElapsedMs: elapsed, errorCode: null);
    } on TimeoutException {
      stopwatch.stop();
      return (
        url: null,
        dbResult: _dbResultTimeout,
        dbElapsedMs: stopwatch.elapsedMilliseconds,
        errorCode: 'timeout',
      );
    } catch (e, st) {
      stopwatch.stop();
      if (kDebugMode) debugPrint('OpenAI TTS DB lookup error: $e\n$st');
      return (
        url: null,
        dbResult: _dbError,
        dbElapsedMs: stopwatch.elapsedMilliseconds,
        errorCode: e.toString().replaceAll(RegExp(r'\s+'), ' ').length > 200
            ? '${e.toString().substring(0, 200)}...'
            : e.toString(),
      );
    }
  }

  /// 英語で再生
  /// [role] に 'A'/'B' を指定すると、役割別の voice を使用
  Future<void> speakEnglish(
    String text, {
    double speakingRate = 1.0,
    String? role,
    void Function(int latencyMs, bool? cacheHit)? onTtsRequestComplete,
    String? ttsSessionId,
  }) async {
    await _synthesizeAndPlay(
      text: text,
      language: 'en-US',
      speakingRate: speakingRate,
      voice: TtsVoiceConfig.voiceForRole(role),
      onTtsRequestComplete: onTtsRequestComplete,
      ttsSessionId: ttsSessionId,
    );
  }

  /// ゆっくり英語で再生
  Future<void> speakEnglishSlow(String text, {String? role}) async {
    await speakEnglish(
      text,
      speakingRate: TtsVoiceConfig.speedEnglishSlow,
      role: role,
    );
  }

  /// 日本語で再生
  /// [role] に 'A'/'B' を指定すると、役割別の voice を使用
  Future<void> speakJapanese(String text, {double speakingRate = 1.0, String? role}) async {
    final voice = role != null
        ? TtsVoiceConfig.voiceForRole(role)
        : TtsVoiceConfig.voiceForJapanese;
    await _synthesizeAndPlay(
      text: text,
      language: 'ja-JP',
      speakingRate: speakingRate,
      voice: voice,
    );
  }

  Future<void> _synthesizeAndPlay({
    required String text,
    required String language,
    required double speakingRate,
    required String voice,
    void Function(int latencyMs, bool? cacheHit)? onTtsRequestComplete,
    String? ttsSessionId,
  }) async {
    if (text.trim().isEmpty) return;
    if (text.length > 4096) {
      throw ArgumentError('Text exceeds 4096 characters');
    }

    final stopwatch = Stopwatch()..start();

    // 1. DB 直参照を優先（Cold Start 回避）
    final dbResult = await _tryFetchUrlFromDb(
      text: text,
      language: language,
      voice: voice,
      speakingRate: speakingRate,
    );
    if (dbResult.url != null && dbResult.url!.isNotEmpty) {
      stopwatch.stop();
      final latencyMs = stopwatch.elapsedMilliseconds;
      AnalyticsService().logTtsRequest(
        latencyMs: latencyMs,
        cacheHit: true,
        sessionId: ttsSessionId,
        source: 'direct_db',
        pathTaken: 'direct_db',
        dbResult: dbResult.dbResult,
        dbElapsedMs: dbResult.dbElapsedMs,
      );
      onTtsRequestComplete?.call(latencyMs, true);
      await playback.playFromUrl(dbResult.url!, ttsSessionId: ttsSessionId);
      return;
    }

    // DB ミス: Edge を呼ばず例外をスロー（課金防止）
    final normalized = normalizeTextForCache(text);
    final clampedSpeed = speakingRate.clamp(0.25, 4.0);
    final keyStr = buildTtsCacheKey(
      text: normalized,
      language: language,
      voice: voice,
      speed: clampedSpeed,
    );
    final keyHash = sha256Hex(keyStr);

    if (kDebugMode) {
      debugPrint('🚨 【犯人特定用】アプリ側のレシピ生文字列: "$keyStr"');
    }

    // #region agent log
    unawaited(_agentDebugLog(
      runId: 'tts_db_miss_prefill_check',
      hypothesisId: 'H1_env_or_key_mismatch',
      location: 'openai_tts_service.dart:_synthesizeAndPlay',
      message: 'TTS DB miss before throwing exception',
      data: {
        'normalizedPreview': normalized.length > 80 ? '${normalized.substring(0, 80)}...' : normalized,
        'language': language,
        'voice': voice,
        'speakingRate': clampedSpeed,
        'model': kTtsModel,
        'cacheKeyHashPrefix': keyHash.substring(0, 8),
        'dbResult': dbResult.dbResult,
        'dbElapsedMs': dbResult.dbElapsedMs,
        'supabaseUrl': EnvConfig.supabaseUrl,
      },
    ));
    // #endregion
    TtsDebugCollector.recordDbMiss(
      cacheKey: keyHash,
      textPreview: normalized.length > 80 ? '${normalized.substring(0, 80)}...' : normalized,
      dbResult: dbResult.dbResult,
      dbElapsedMs: dbResult.dbElapsedMs,
      edgeCalled: false,
      recipeRaw: keyStr,
    );
    throw Exception(
      'TTS cache miss: 音声がDBにありません。prefill を実行してください。'
      ' (cache_key: ${keyHash.substring(0, 8)}...)\n'
      '【犯人特定用】レシピ生文字列: $keyStr',
    );
  }

  /// 音声 URL のみ取得（プリフェッチ用。再生はしない）
  /// DB のみ。ミス時は null を返す（Edge は呼ばない）
  Future<String?> fetchAudioUrl({
    required String text,
    String language = 'en-US',
    double speakingRate = 1.0,
    required String voice,
  }) async {
    if (text.trim().isEmpty) return null;
    if (text.length > 4096) return null;

    final dbResult = await _tryFetchUrlFromDb(
      text: text,
      language: language,
      voice: voice,
      speakingRate: speakingRate,
    );
    return dbResult.url;
  }

  /// プリフェッチ済み URL から直接再生
  Future<void> playFromUrl(String url) async {
    await playback.playFromUrl(url);
  }

  /// 停止
  Future<void> stop() async {
    playback.stop();
  }

  void dispose() {
    playback.stop();
  }
}
