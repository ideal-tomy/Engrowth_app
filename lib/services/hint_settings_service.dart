import '../config/supabase_config.dart';
import '../models/hint_settings.dart';

class HintSettingsService {
  /// ユーザーのヒント設定を取得
  static Future<HintSettings?> getSettings(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from('hint_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // 設定が存在しない場合はデフォルト設定を作成
        return await createDefaultSettings(userId);
      }

      return HintSettings.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching hint settings: $e');
      return null;
    }
  }

  /// デフォルト設定を作成
  static Future<HintSettings> createDefaultSettings(String userId) async {
    final defaultSettings = {
      'user_id': userId,
      'initial_hint_delay_seconds': 2,
      'extended_hint_delay_seconds': 6,
      'keywords_hint_delay_seconds': 10,
      'hint_opacity': 0.6,
      'hint_phases_enabled': ['initial', 'extended', 'keywords'],
      'haptic_feedback_enabled': true,
      'visual_feedback_enabled': true,
    };

    try {
      final response = await SupabaseConfig.client
          .from('hint_settings')
          .insert(defaultSettings)
          .select()
          .single();

      return HintSettings.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error creating default hint settings: $e');
      // エラー時はメモリ上のデフォルト設定を返す
      return HintSettings(
        id: '',
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// ヒント設定を保存
  static Future<void> saveSettings(HintSettings settings) async {
    try {
      await SupabaseConfig.client
          .from('hint_settings')
          .upsert(
            {
              'id': settings.id,
              'user_id': settings.userId,
              'initial_hint_delay_seconds': settings.initialHintDelaySeconds,
              'extended_hint_delay_seconds': settings.extendedHintDelaySeconds,
              'keywords_hint_delay_seconds': settings.keywordsHintDelaySeconds,
              'hint_opacity': settings.hintOpacity,
              'hint_phases_enabled': settings.hintPhasesEnabled,
              'haptic_feedback_enabled': settings.hapticFeedbackEnabled,
              'visual_feedback_enabled': settings.visualFeedbackEnabled,
              'updated_at': DateTime.now().toIso8601String(),
            },
            onConflict: 'user_id',
          );
    } catch (e) {
      print('Error saving hint settings: $e');
      rethrow;
    }
  }
}
