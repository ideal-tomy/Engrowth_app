import '../config/supabase_config.dart';
import '../models/hint_phase.dart';
import '../models/learning_session.dart';

class LearningService {
  /// 学習ログを記録
  static Future<void> logLearning({
    required String userId,
    required String sentenceId,
    required String sessionId,
    required DateTime sessionStartTime,
    required HintPhase hintPhase,
    required int thinkingTimeSeconds,
    required bool usedHint,
    required bool mastered,
    required bool answerShown,
  }) async {
    try {
      await SupabaseConfig.client.from('learning_logs').insert({
        'user_id': userId,
        'sentence_id': sentenceId,
        'session_id': sessionId,
        'session_start_time': sessionStartTime.toIso8601String(),
        'hint_phase': hintPhase.value,
        'thinking_time_seconds': thinkingTimeSeconds,
        'used_hint': usedHint,
        'mastered': mastered,
        'answer_shown': answerShown,
      });
    } catch (e) {
      print('Error logging learning: $e');
      rethrow;
    }
  }

  /// 学習セッションを開始
  static String startSession({
    required String userId,
    required List<String> sentenceIds,
  }) {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// ヒント使用統計を取得
  static Future<Map<String, dynamic>> getHintStatistics(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .rpc('get_user_hint_statistics', params: {'p_user_id': userId})
          .single();

      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching hint statistics: $e');
      return {
        'total_sentences': 0,
        'sentences_with_hints': 0,
        'hint_usage_rate': 0.0,
        'avg_thinking_time': 0.0,
        'most_used_hint_phase': null,
      };
    }
  }

  /// ヒント使用統計ビューから取得
  static Future<List<Map<String, dynamic>>> getHintUsageStats({
    required String userId,
    String? sentenceId,
  }) async {
    try {
      var query = SupabaseConfig.client
          .from('hint_usage_stats')
          .select()
          .eq('user_id', userId);

      if (sentenceId != null) {
        query = query.eq('sentence_id', sentenceId);
      }

      final response = await query;
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching hint usage stats: $e');
      return [];
    }
  }
}
