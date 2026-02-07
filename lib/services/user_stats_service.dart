import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_stats.dart';

/// ユーザー統計情報サービス
/// ストリーク、日次ミッションの管理
class UserStatsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// ユーザー統計を取得（存在しない場合は作成）
  Future<UserStats> getOrCreateUserStats(String userId) async {
    try {
      // 既存の統計を取得
      final response = await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        return UserStats.fromJson(response);
      }

      // 存在しない場合は作成
      final today = DateTime.now();
      final newStats = {
        'user_id': userId,
        'streak_count': 0,
        'last_study_date': null,
        'daily_goal_count': 3,
        'daily_done_count': 0,
        'daily_reset_date': today.toIso8601String().split('T')[0],
        'timezone': 'Asia/Tokyo',
      };

      final insertResponse = await _supabase
          .from('user_stats')
          .insert(newStats)
          .select()
          .single();

      return UserStats.fromJson(insertResponse);
    } catch (e) {
      print('Error getting user stats: $e');
      rethrow;
    }
  }

  /// ストリークを更新
  Future<UserStats> updateStreak(String userId) async {
    try {
      final stats = await getOrCreateUserStats(userId);
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      
      DateTime? lastStudyDate;
      if (stats.lastStudyDate != null) {
        lastStudyDate = DateTime(
          stats.lastStudyDate!.year,
          stats.lastStudyDate!.month,
          stats.lastStudyDate!.day,
        );
      }

      int newStreak = stats.streakCount;

      if (lastStudyDate == null) {
        // 初回学習
        newStreak = 1;
      } else if (lastStudyDate == todayDate) {
        // 今日既に学習済み
        newStreak = stats.streakCount;
      } else {
        final daysDiff = todayDate.difference(lastStudyDate).inDays;
        if (daysDiff == 1) {
          // 連続学習
          newStreak = stats.streakCount + 1;
        } else {
          // 連続が途切れた
          newStreak = 1;
        }
      }

      final response = await _supabase
          .from('user_stats')
          .update({
            'streak_count': newStreak,
            'last_study_date': todayDate.toIso8601String().split('T')[0],
          })
          .eq('user_id', userId)
          .select()
          .single();

      return UserStats.fromJson(response);
    } catch (e) {
      print('Error updating streak: $e');
      rethrow;
    }
  }

  /// 日次ミッションをリセット（必要に応じて）
  Future<UserStats> resetDailyMissionIfNeeded(String userId) async {
    try {
      final stats = await getOrCreateUserStats(userId);
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      
      DateTime? resetDate;
      if (stats.dailyResetDate != null) {
        resetDate = DateTime(
          stats.dailyResetDate!.year,
          stats.dailyResetDate!.month,
          stats.dailyResetDate!.day,
        );
      }

      // 今日がリセット日でない場合、リセット
      if (resetDate != todayDate) {
        final response = await _supabase
            .from('user_stats')
            .update({
              'daily_done_count': 0,
              'daily_reset_date': todayDate.toIso8601String().split('T')[0],
            })
            .eq('user_id', userId)
            .select()
            .single();

        return UserStats.fromJson(response);
      }

      return stats;
    } catch (e) {
      print('Error resetting daily mission: $e');
      rethrow;
    }
  }

  /// 日次ミッションの進捗を更新
  Future<UserStats> incrementDailyDone(String userId, {int count = 1}) async {
    try {
      // まずリセットが必要かチェック
      await resetDailyMissionIfNeeded(userId);

      final response = await _supabase
          .rpc('increment_daily_done', params: {
            'p_user_id': userId,
            'p_count': count,
          })
          .single();

      // RPCが存在しない場合は直接更新
      if (response == null) {
        final stats = await getOrCreateUserStats(userId);
        final newCount = stats.dailyDoneCount + count;
        
        final updateResponse = await _supabase
            .from('user_stats')
            .update({
              'daily_done_count': newCount,
            })
            .eq('user_id', userId)
            .select()
            .single();

        return UserStats.fromJson(updateResponse);
      }

      return UserStats.fromJson(response);
    } catch (e) {
      // RPCが存在しない場合のフォールバック
      try {
        final stats = await getOrCreateUserStats(userId);
        final newCount = stats.dailyDoneCount + count;
        
        final updateResponse = await _supabase
            .from('user_stats')
            .update({
              'daily_done_count': newCount,
            })
            .eq('user_id', userId)
            .select()
            .single();

        return UserStats.fromJson(updateResponse);
      } catch (e2) {
        print('Error incrementing daily done: $e2');
        rethrow;
      }
    }
  }

  /// 日次目標を更新
  Future<UserStats> updateDailyGoal(String userId, int goalCount) async {
    try {
      final response = await _supabase
          .from('user_stats')
          .update({
            'daily_goal_count': goalCount,
          })
          .eq('user_id', userId)
          .select()
          .single();

      return UserStats.fromJson(response);
    } catch (e) {
      print('Error updating daily goal: $e');
      rethrow;
    }
  }
}
