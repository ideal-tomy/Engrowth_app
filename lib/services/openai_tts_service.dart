import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  Future<void> speakEnglish(String text, {double speakingRate = 1.0}) async {
    await _synthesizeAndPlay(
      text: text,
      language: 'en-US',
      speakingRate: speakingRate,
      voice: 'nova',
    );
  }

  /// ゆっくり英語で再生
  Future<void> speakEnglishSlow(String text) async {
    await speakEnglish(text, speakingRate: 0.6);
  }

  /// 日本語で再生
  Future<void> speakJapanese(String text, {double speakingRate = 1.0}) async {
    await _synthesizeAndPlay(
      text: text,
      language: 'ja-JP',
      speakingRate: speakingRate,
      voice: 'alloy',
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
    if (data is! List<int> && data is! Uint8List) {
      if (kDebugMode) debugPrint('OpenAI TTS: unexpected response type ${data.runtimeType}');
      throw Exception('Invalid TTS response format');
    }
    final bytes = data is Uint8List ? data : Uint8List.fromList(data as List<int>);
    await _playBytes(bytes);
  }

  /// 停止
  Future<void> stop() async {
    playback.stop();
  }

  void dispose() {
    playback.stop();
  }
}
