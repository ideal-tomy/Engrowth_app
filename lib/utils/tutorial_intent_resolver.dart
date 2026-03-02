/// STT結果を意図バケットに正規化
/// greeting / self_intro / unknown（フォールバック）
class TutorialIntentResolver {
  static const String greeting = 'greeting';
  static const String selfIntro = 'self_intro';
  static const String unknown = 'unknown';

  static final _greetingPatterns = [
    'hello', 'hi', 'hey', 'greetings', 'good morning', 'good afternoon',
    'good evening', 'howdy', 'yo', 'こんにちは', 'はい', 'やあ',
  ];

  static final _selfIntroPatterns = [
    'my name is', "i'm ", "i am ", "name is", "call me",
    'です', 'といいます', 'といいます', 'と申します',
  ];

  /// STTテキストを意図バケットにマッピング
  static String resolveIntent(String? sttText) {
    if (sttText == null || sttText.trim().isEmpty) return unknown;

    final lower = sttText.trim().toLowerCase();

    for (final p in _greetingPatterns) {
      if (lower.contains(p)) return greeting;
    }

    for (final p in _selfIntroPatterns) {
      if (lower.contains(p)) return selfIntro;
    }

    return unknown;
  }
}
