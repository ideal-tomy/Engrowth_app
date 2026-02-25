import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyThemeMode = 'app_theme_mode';

/// 手動で選択したテーマモード（端末に合わせる / ライト / ダーク）
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode?>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode?> {
  @override
  ThemeMode? build() => null;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_keyThemeMode);
    if (index == null) {
      state = null; // 未設定 = 端末に合わせる
      return;
    }
    switch (index) {
      case 0:
        state = ThemeMode.system;
        break;
      case 1:
        state = ThemeMode.light;
        break;
      case 2:
        state = ThemeMode.dark;
        break;
      default:
        state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    final index = switch (mode) {
      ThemeMode.system => 0,
      ThemeMode.light => 1,
      ThemeMode.dark => 2,
    };
    await prefs.setInt(_keyThemeMode, index);
  }
}
