import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../config/env_config.dart';

/// Google Cloud Text-to-Speech API サービス
/// リアルな英語発音・会話の流れを再現するため Wavenet 音声を使用
class GoogleTtsService {
  static const _baseUrl = 'https://texttospeech.googleapis.com/v1/text:synthesize';
  static const _voiceName = 'en-US-Wavenet-D';  // 自然な会話向け英語（男性）
  static const _languageCode = 'en-US';

  final AudioPlayer _player = AudioPlayer();
  String? _tempPath;

  /// APIキーが設定されているか
  static bool get isAvailable => EnvConfig.googleTtsApiKey != null && EnvConfig.googleTtsApiKey!.isNotEmpty;

  /// 英語で再生（speakingRate 0.5〜2.0）
  Future<void> speakEnglish(String text, {double speakingRate = 1.0}) async {
    final apiKey = EnvConfig.googleTtsApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('Google TTS API key not configured');
    }

    final body = {
      'input': {'text': text},
      'voice': {
        'languageCode': _languageCode,
        'name': _voiceName,
      },
      'audioConfig': {
        'audioEncoding': 'MP3',
        'speakingRate': speakingRate.clamp(0.25, 4.0),
        'pitch': 0.0,
      },
    };

    final uri = Uri.parse('$_baseUrl?key=$apiKey');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Google TTS API error: ${response.statusCode} ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final audioContent = json['audioContent'] as String?;
    if (audioContent == null) throw Exception('No audio content in response');

    final bytes = base64Decode(audioContent);
    final dir = await getTemporaryDirectory();
    _tempPath = '${dir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
    await File(_tempPath!).writeAsBytes(bytes);

    await _player.setFilePath(_tempPath!);
    await _player.play();
    await _player.playerStateStream
        .where((s) =>
            s.processingState == ProcessingState.completed ||
            s.processingState == ProcessingState.idle)
        .first;
    await _cleanupTemp();
  }

  /// ゆっくり再生
  Future<void> speakEnglishSlow(String text) async {
    await speakEnglish(text, speakingRate: 0.6);
  }

  /// 日本語で再生（en-US の代替として ja-JP を使用）
  Future<void> speakJapanese(String text, {double speakingRate = 1.0}) async {
    final apiKey = EnvConfig.googleTtsApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('Google TTS API key not configured');
    }

    final body = {
      'input': {'text': text},
      'voice': {
        'languageCode': 'ja-JP',
        'name': 'ja-JP-Wavenet-B',
      },
      'audioConfig': {
        'audioEncoding': 'MP3',
        'speakingRate': speakingRate.clamp(0.25, 4.0),
        'pitch': 0.0,
      },
    };

    final uri = Uri.parse('$_baseUrl?key=$apiKey');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Google TTS API error: ${response.statusCode} ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final audioContent = json['audioContent'] as String?;
    if (audioContent == null) throw Exception('No audio content in response');

    final bytes = base64Decode(audioContent);
    final dir = await getTemporaryDirectory();
    _tempPath = '${dir.path}/tts_ja_${DateTime.now().millisecondsSinceEpoch}.mp3';
    await File(_tempPath!).writeAsBytes(bytes);

    await _player.setFilePath(_tempPath!);
    await _player.play();
    await _player.playerStateStream
        .where((s) =>
            s.processingState == ProcessingState.completed ||
            s.processingState == ProcessingState.idle)
        .first;
    await _cleanupTemp();
  }

  Future<void> _cleanupTemp() async {
    if (_tempPath != null) {
      try {
        final f = File(_tempPath!);
        if (await f.exists()) await f.delete();
      } catch (_) {}
      _tempPath = null;
    }
  }

  /// 停止
  Future<void> stop() async {
    await _player.stop();
    await _cleanupTemp();
  }

  bool get isPlaying =>
      _player.processingState == ProcessingState.loading ||
      _player.processingState == ProcessingState.ready && _player.playing;

  void dispose() {
    _player.dispose();
  }
}
