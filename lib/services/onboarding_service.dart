import 'package:shared_preferences/shared_preferences.dart';

const _keyOnboardingCompleted = 'onboarding_completed';

/// 初回体験の完了状態を管理
class OnboardingService {
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  static Future<void> setOnboardingCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, value);
  }

  /// 開発・テスト用: 初回体験をリセット
  static Future<void> resetOnboarding() async {
    await setOnboardingCompleted(false);
  }
}
