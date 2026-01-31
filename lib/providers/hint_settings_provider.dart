import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hint_settings.dart';
import '../services/hint_settings_service.dart';
import '../config/supabase_config.dart';

// デフォルトのヒント設定
final defaultHintSettings = HintSettings(
  id: '',
  userId: '',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// ヒント設定プロバイダー
final hintSettingsProvider = StateNotifierProvider<HintSettingsNotifier, HintSettings>((ref) {
  return HintSettingsNotifier();
});

class HintSettingsNotifier extends StateNotifier<HintSettings> {
  HintSettingsNotifier() : super(defaultHintSettings) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) {
        // ユーザーがログインしていない場合はデフォルト設定を使用
        return;
      }

      final settings = await HintSettingsService.getSettings(userId);
      if (settings != null) {
        state = settings;
      }
    } catch (e) {
      print('Error loading hint settings: $e');
      // エラー時はデフォルト設定を使用
    }
  }

  Future<void> updateSettings(HintSettings newSettings) async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) {
        // ユーザーがログインしていない場合はローカルのみ更新
        state = newSettings;
        return;
      }

      await HintSettingsService.saveSettings(newSettings);
      state = newSettings;
    } catch (e) {
      print('Error updating hint settings: $e');
    }
  }

  Future<void> updateDelaySeconds({
    int? initial,
    int? extended,
    int? keywords,
  }) async {
    final newSettings = state.copyWith(
      initialHintDelaySeconds: initial ?? state.initialHintDelaySeconds,
      extendedHintDelaySeconds: extended ?? state.extendedHintDelaySeconds,
      keywordsHintDelaySeconds: keywords ?? state.keywordsHintDelaySeconds,
      updatedAt: DateTime.now(),
    );
    await updateSettings(newSettings);
  }

  Future<void> updateOpacity(double opacity) async {
    final newSettings = state.copyWith(
      hintOpacity: opacity,
      updatedAt: DateTime.now(),
    );
    await updateSettings(newSettings);
  }

  Future<void> toggleHapticFeedback() async {
    final newSettings = state.copyWith(
      hapticFeedbackEnabled: !state.hapticFeedbackEnabled,
      updatedAt: DateTime.now(),
    );
    await updateSettings(newSettings);
  }

  Future<void> toggleVisualFeedback() async {
    final newSettings = state.copyWith(
      visualFeedbackEnabled: !state.visualFeedbackEnabled,
      updatedAt: DateTime.now(),
    );
    await updateSettings(newSettings);
  }
}
