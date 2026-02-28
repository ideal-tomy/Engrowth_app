import 'dart:async';
import 'dart:typed_data';

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
  static const _dbTimeout = Duration(milliseconds: 250);
  static const _bucket = 'tts-audio';

  /// Supabase が初期化済みか（Edge Function 利用可能か）
  static bool get isAvailable {
    try {
      return Supabase.instance.client != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> _playBytes(List<int> bytes) async {
    await playback.playBytes(bytes);
  }

  /// DB から storage_path を取得し Public URL を構築（ヒット時のみ）
  /// タイムアウト・未ヒット時は null
  Future<String?> _tryFetchUrlFromDb({
    required String text,
    String language = 'en-US',
    required String voice,
    double speakingRate = 1.0,
  }) async {
    final normalized = normalizeTextForCache(text);
    if (normalized.isEmpty) return null;

    final keyStr = buildTtsCacheKey(
      text: normalized,
      language: language,
      voice: voice,
      speed: speakingRate,
    );
    final keyHash = sha256Hex(keyStr);

    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('tts_assets')
          .select('storage_path')
          .eq('cache_key', keyHash)
          .maybeSingle()
          .timeout(_dbTimeout, onTimeout: () => null);

      if (response == null) return null;
      final row = response is Map<String, dynamic> ? response : null;
      final path = row?['storage_path'] as String?;
      if (path == null || path.isEmpty) return null;

      final baseUrl = EnvConfig.supabaseUrl.replaceAll(RegExp(r'/$'), '');
      return '$baseUrl/storage/v1/object/public/$_bucket/$path';
    } catch (_) {
      return null;
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
    final dbUrl = await _tryFetchUrlFromDb(
      text: text,
      language: language,
      voice: voice,
      speakingRate: speakingRate,
    );
    if (dbUrl != null && dbUrl.isNotEmpty) {
      stopwatch.stop();
      final latencyMs = stopwatch.elapsedMilliseconds;
      AnalyticsService().logTtsRequest(
        latencyMs: latencyMs,
        cacheHit: true,
        sessionId: ttsSessionId,
        source: 'direct_db',
      );
      onTtsRequestComplete?.call(latencyMs, true);
      await playback.playFromUrl(dbUrl);
      return;
    }

    // 2. ミス/タイムアウト: Edge Function にフォールバック
    final body = {
      'text': text,
      'language': language,
      'speakingRate': speakingRate.clamp(0.25, 4.0),
      'voice': voice,
    };

    final client = Supabase.instance.client;
    final response = await client.functions
        .invoke(
          _functionName,
          body: body,
        )
        .timeout(_timeout, onTimeout: () {
      throw TimeoutException('TTS synthesis timeout');
    });

    final data = response.data;
    if (data == null) {
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
        );
        onTtsRequestComplete?.call(latencyMs, cacheHit);
        await playback.playFromUrl(url);
        return;
      }
    }

    // 旧形式: bytes（後方互換）
    if (data is List<int> || data is Uint8List) {
      stopwatch.stop();
      AnalyticsService().logTtsRequest(
        latencyMs: stopwatch.elapsedMilliseconds,
        cacheHit: false,
      );
      final bytes = data is Uint8List ? data : Uint8List.fromList(data as List<int>);
      await _playBytes(bytes);
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

    final dbUrl = await _tryFetchUrlFromDb(
      text: text,
      language: language,
      voice: voice,
      speakingRate: speakingRate,
    );
    if (dbUrl != null && dbUrl.isNotEmpty) return dbUrl;

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
