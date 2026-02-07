import 'package:flutter_tts/flutter_tts.dart';

/// TTS（Text-to-Speech）サービス
/// 例文の音声再生を管理
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  /// 初期化
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(1.0);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // コールバック設定
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      print('TTS Error: $msg');
    });

    _isInitialized = true;
  }

  /// 英語で再生（通常速度）
  Future<void> speakEnglish(String text) async {
    await initialize();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(1.0);
    await _flutterTts.speak(text);
  }

  /// 英語で再生（ゆっくり）
  Future<void> speakEnglishSlow(String text) async {
    await initialize();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.6);
    await _flutterTts.speak(text);
  }

  /// 日本語で再生
  Future<void> speakJapanese(String text) async {
    await initialize();
    await _flutterTts.setLanguage('ja-JP');
    await _flutterTts.setSpeechRate(1.0);
    await _flutterTts.speak(text);
  }

  /// 停止
  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }

  /// 再生中かどうか
  bool get isSpeaking => _isSpeaking;

  /// 破棄
  void dispose() {
    _flutterTts.stop();
  }
}
