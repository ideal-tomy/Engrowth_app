import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';
import '../config/tts_voice_config.dart';
import 'analytics_service.dart';
import 'openai_tts_playback_web.dart' if (dart.library.io) 'openai_tts_playback_io.dart' as playback;
import 'tts_cache_key_util.dart';

/// Supabase Edge Function 経由で OpenAI TTS を呼び出し、MP3 を再生するサービス
/// - ハイブリッド: DB 直参照を優先、ミス/タイムアウト時のみ Edge Function
/// - API キーはクライアントに持たず Edge Function 内で使用
/// - 失敗時は呼び出し元で flutter_tts へフォールバック
class OpenAiTtsService {
  static const _functionName = 'tts_synthesize';
  static const _timeout = Duration(seconds: 30);
  /// デプロイWebのネットワーク遅延を考慮し、250ms→800msに拡張（毎回Edge化を抑制）
  static const _dbTimeout = Duration(milliseconds: 800);
  static const _bucket = 'tts-audio';

  /// Supabase が初期化済みか（Edge Function 利用可能か）
  static bool get isAvailable {
    try {
      return Supabase.instance.client != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> _playBytes(List<int> bytes, {String? ttsSessionId}) async {
    await playback.playBytes(bytes, ttsSessionId: ttsSessionId);
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

    // 2. ミス/タイムアウト: Edge Function にフォールバック
    final edgeStopwatch = Stopwatch()..start();
    final body = <String, dynamic>{
      'text': text,
      'language': language,
      'speakingRate': speakingRate.clamp(0.25, 4.0),
      'voice': voice,
    };
    if (ttsSessionId != null) body['tts_session_id'] = ttsSessionId;

    final client = Supabase.instance.client;
    final response = await client.functions
        .invoke(
          _functionName,
          body: body,
        )
        .timeout(_timeout, onTimeout: () {
      throw TimeoutException('TTS synthesis timeout');
    });

    edgeStopwatch.stop();
    final edgeElapsedMs = edgeStopwatch.elapsedMilliseconds;

    final data = response.data;
    if (data == null) {
      stopwatch.stop();
      AnalyticsService().logTtsRequest(
        latencyMs: stopwatch.elapsedMilliseconds,
        cacheHit: false,
        sessionId: ttsSessionId,
        source: 'edge',
        pathTaken: 'edge',
        dbResult: dbResult.dbResult,
        dbElapsedMs: dbResult.dbElapsedMs,
        edgeElapsedMs: edgeElapsedMs,
        errorCode: 'empty_response',
      );
      throw Exception('Empty TTS response');
    }

    // 新形式: JSON { url, cache_hit }
    if (data is Map<String, dynamic>) {
      final url = data['url'] as String?;
      if (url != null && url.isNotEmpty) {
        stopwatch.stop();
        final latencyMs = stopwatch.elapsedMilliseconds;
        final cacheHit = data['cache_hit'] as bool?;
        AnalyticsService().logTtsRequest(
          latencyMs: latencyMs,
          cacheHit: cacheHit,
          sessionId: ttsSessionId,
          source: 'edge',
          pathTaken: 'edge',
          dbResult: dbResult.dbResult,
          dbElapsedMs: dbResult.dbElapsedMs,
          edgeElapsedMs: edgeElapsedMs,
        );
        onTtsRequestComplete?.call(latencyMs, cacheHit);
        await playback.playFromUrl(url, ttsSessionId: ttsSessionId);
        return;
      }
    }

    // 旧形式: bytes（後方互換）
    if (data is List<int> || data is Uint8List) {
      stopwatch.stop();
      AnalyticsService().logTtsRequest(
        latencyMs: stopwatch.elapsedMilliseconds,
        cacheHit: false,
        sessionId: ttsSessionId,
        source: 'edge',
        pathTaken: 'edge',
        dbResult: dbResult.dbResult,
        dbElapsedMs: dbResult.dbElapsedMs,
        edgeElapsedMs: edgeElapsedMs,
      );
      final bytes = data is Uint8List ? data : Uint8List.fromList(data as List<int>);
      await _playBytes(bytes, ttsSessionId: ttsSessionId);
      return;
    }

    if (kDebugMode) debugPrint('OpenAI TTS: unexpected response type ${data.runtimeType}');
    throw Exception('Invalid TTS response format');
  }

  /// 音声 URL のみ取得（プリフェッチ用。再生はしない）
  /// ハイブリッド: DB 直参照 → ミス時 Edge
  /// キャンセル時は呼び出し元で generation ID 等で破棄すること
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
    if (dbResult.url != null && dbResult.url!.isNotEmpty) return dbResult.url;

    final body = {
      'text': text,
      'language': language,
      'speakingRate': speakingRate.clamp(0.25, 4.0),
      'voice': voice,
    };

    final client = Supabase.instance.client;
    final response = await client.functions
        .invoke(_functionName, body: body)
        .timeout(_timeout, onTimeout: () {
      throw TimeoutException('TTS fetch timeout');
    });

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['url'] as String?;
    }
    return null;
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
