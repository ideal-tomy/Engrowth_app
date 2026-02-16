import 'package:flutter_tts/flutter_tts.dart';
import 'google_tts_service.dart';

/// TTS（Text-to-Speech）サービス
/// Google Cloud TTS（APIキー設定時）でリアルな発音、未設定時はデバイスTTSを使用
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  static double _defaultSpeechRate = 1.0;

  final FlutterTts _flutterTts = FlutterTts();
  GoogleTtsService? _googleTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _useGoogleTts = false;

  /// 再生速度のデフォルト値を設定（設定画面から呼び出し）
  static void setDefaultSpeechRate(double rate) {
    _defaultSpeechRate = rate.clamp(0.5, 2.0);
  }

  bool get useGoogleTts => _useGoogleTts;

  /// 初期化
  Future<void> initialize() async {
    if (_isInitialized) return;

    _useGoogleTts = GoogleTtsService.isAvailable;
    if (_useGoogleTts) {
      _googleTts ??= GoogleTtsService();
    }

    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(1.0);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setStartHandler(() => _isSpeaking = true);
    _flutterTts.setCompletionHandler(() => _isSpeaking = false);
    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      print('TTS Error: $msg');
    });

    _isInitialized = true;
  }

  /// 英語で再生（設定画面の再生速度を使用）
  Future<void> speakEnglish(String text) async {
    await initialize();
    if (_useGoogleTts && _googleTts != null) {
      try {
        _isSpeaking = true;
        await _googleTts!.speakEnglish(text, speakingRate: _defaultSpeechRate);
      } catch (e) {
        print('Google TTS fallback to device: $e');
        await _speakEnglishFlutter(text);
      } finally {
        _isSpeaking = false;
      }
    } else {
      await _speakEnglishFlutter(text);
    }
  }

  Future<void> _speakEnglishFlutter(String text) async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(_defaultSpeechRate);
    await _flutterTts.speak(text);
  }

  /// 英語で再生（ゆっくり固定）
  Future<void> speakEnglishSlow(String text) async {
    await initialize();
    if (_useGoogleTts && _googleTts != null) {
      try {
        _isSpeaking = true;
        await _googleTts!.speakEnglishSlow(text);
      } catch (e) {
        print('Google TTS fallback to device: $e');
        await _flutterTts.setLanguage('en-US');
        await _flutterTts.setSpeechRate(0.6);
        await _flutterTts.speak(text);
      } finally {
        _isSpeaking = false;
      }
    } else {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.6);
      await _flutterTts.speak(text);
    }
  }

  /// 日本語で再生
  Future<void> speakJapanese(String text) async {
    await initialize();
    if (_useGoogleTts && _googleTts != null) {
      try {
        _isSpeaking = true;
        await _googleTts!.speakJapanese(text, speakingRate: _defaultSpeechRate);
      } catch (e) {
        print('Google TTS fallback to device: $e');
        await _speakJapaneseFlutter(text);
      } finally {
        _isSpeaking = false;
      }
    } else {
      await _speakJapaneseFlutter(text);
    }
  }

  Future<void> _speakJapaneseFlutter(String text) async {
    await _flutterTts.setLanguage('ja-JP');
    await _flutterTts.setSpeechRate(_defaultSpeechRate);
    await _flutterTts.speak(text);
  }

  /// 停止
  Future<void> stop() async {
    if (_useGoogleTts && _googleTts != null) {
      await _googleTts!.stop();
    }
    await _flutterTts.stop();
    _isSpeaking = false;
  }

  /// 再生中かどうか
  bool get isSpeaking => _isSpeaking;

  /// 破棄
  void dispose() {
    _googleTts?.dispose();
    _flutterTts.stop();
  }
}
