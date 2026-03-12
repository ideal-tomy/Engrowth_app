import 'package:shared_preferences/shared_preferences.dart';

/// ListenFirstPopup の表示制御用永続化
/// - アカウント作成済み: 「今後表示しない」チェック時は永続非表示
/// - アカウント未作成: 1日1回、初回訪問時のみ表示
class ListenFirstPopupPrefsService {
  static const _keyDismissedPermanently = 'listen_first_popup_dismissed_pattern';
  static const _keyLastShownDate = 'listen_first_popup_last_shown_date';

  /// パターンスプリント用 ListenFirstPopup を永続非表示にする
  Future<void> setDismissedPermanently(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDismissedPermanently, value);
  }

  /// 永続非表示が有効か
  Future<bool> isDismissedPermanently() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDismissedPermanently) ?? false;
  }

  /// 本日すでに表示済みか（ゲスト用 1日1回）
  Future<bool> wasShownToday() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString(_keyLastShownDate);
    if (last == null) return false;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return last == today;
  }

  /// 本日表示したことを記録（ゲスト用）
  Future<void> markShownToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(_keyLastShownDate, today);
  }
}
