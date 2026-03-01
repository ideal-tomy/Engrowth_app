import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kEnableMarqueeRailKey = 'ui_experiments_enable_marquee_rail';

/// Marquee導線（ヘッダー・フッター上レール）の表示フラグ
/// OFF: 既存UI / ON: Marquee導線を表示（比較検証用）
final enableMarqueeRailProvider =
    StateNotifierProvider<EnableMarqueeRailNotifier, bool>((ref) {
  return EnableMarqueeRailNotifier();
});

class EnableMarqueeRailNotifier extends StateNotifier<bool> {
  EnableMarqueeRailNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kEnableMarqueeRailKey) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnableMarqueeRailKey, state);
  }

  Future<void> setEnabled(bool value) async {
    if (state == value) return;
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnableMarqueeRailKey, state);
  }
}
