import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/tts_voice_config.dart';
import 'analytics_service.dart';
import 'openai_tts_playback_web.dart' if (dart.library.io) 'openai_tts_playback_io.dart' as playback;

/// Supabase Edge Function 経由で OpenAI TTS を呼び出し、MP3 を再生するサービス
/// - API キーはクライアントに持たず Edge Function 内で使用
/// - 失敗時は呼び出し元で flutter_tts へフォールバック
class OpenAiTtsService {
  static const _functionName = 'tts_synthesize';
  static const _timeout = Duration(seconds: 30);

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

  /// 英語で再生
  /// [role] に 'A'/'B' を指定すると、役割別の voice を使用
  Future<void> speakEnglish(String text, {double speakingRate = 1.0, String? role}) async {
    await _synthesizeAndPlay(
      text: text,
      language: 'en-US',
      speakingRate: speakingRate,
      voice: TtsVoiceConfig.voiceForRole(role),
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
  }) async {
    if (text.trim().isEmpty) return;
    if (text.length > 4096) {
      throw ArgumentError('Text exceeds 4096 characters');
    }

    final body = {
      'text': text,
      'language': language,
      'speakingRate': speakingRate.clamp(0.25, 4.0),
      'voice': voice,
    };

    final stopwatch = Stopwatch()..start();
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
        AnalyticsService().logTtsRequest(
          latencyMs: stopwatch.elapsedMilliseconds,
          cacheHit: data['cache_hit'] as bool?,
        );
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
  /// キャンセル時は呼び出し元で generation ID 等で破棄すること
  Future<String?> fetchAudioUrl({
    required String text,
    String language = 'en-US',
    double speakingRate = 1.0,
    required String voice,
  }) async {
    if (text.trim().isEmpty) return null;
    if (text.length > 4096) return null;

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
