import 'package:shared_preferences/shared_preferences.dart';

/// 起動時ショートカットポップアップの表示制御（1日1回）
class StartupShortcutService {
  static const _keyLastShownDate = 'startup_shortcut_last_shown_date';

  /// 当日に表示済みか
  Future<bool> hasShownToday() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString(_keyLastShownDate);
    if (last == null) return false;
    final today = DateTime.now().toIso8601String().split('T')[0];
    return last == today;
  }

  /// 表示済みとして記録
  Future<void> markShownToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString(_keyLastShownDate, today);
  }
}
