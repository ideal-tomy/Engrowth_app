/// OpenAI TTS の音声・速度設定
/// 役割A/B・言語ごとに voice と speed を切替可能
class TtsVoiceConfig {
  TtsVoiceConfig._();

  /// 役割A用 voice（会話の片方）
  static String voiceRoleA = 'alloy';

  /// 役割B用 voice（会話のもう片方）
  static String voiceRoleB = 'nova';

  /// 役割なし・英語デフォルト voice
  static String voiceEnglishDefault = 'nova';

  /// 日本語用 voice
  static String voiceJapanese = 'alloy';

  /// 英語ゆっくり再生時の speed
  static double speedEnglishSlow = 0.6;

  /// 役割に応じた voice を取得
  static String voiceForRole(String? role) {
    if (role == null) return voiceEnglishDefault;
    final r = role.toUpperCase();
    if (r == 'A') return voiceRoleA;
    if (r == 'B') return voiceRoleB;
    return voiceEnglishDefault;
  }

  /// 日本語用 voice を取得
  static String get voiceForJapanese => voiceJapanese;
}
