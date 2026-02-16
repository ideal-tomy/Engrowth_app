import 'package:shared_preferences/shared_preferences.dart';

const _keyConsent = 'recording_consent_given';

/// 録音同意の管理
class RecordingConsentService {
  static Future<bool> hasConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyConsent) ?? false;
  }

  static Future<void> setConsent(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyConsent, value);
  }
}
