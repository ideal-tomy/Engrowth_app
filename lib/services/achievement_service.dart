import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/achievement.dart';

/// バッジ/称号サービス
class AchievementService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 全バッジを取得
  Future<List<Achievement>> getAchievements() async {
    try {
      final response = await _supabase
          .from('achievements')
          .select()
          .order('condition_value', ascending: true);

      return (response as List)
          .map((json) => Achievement.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting achievements: $e');
      rethrow;
    }
  }

  /// ユーザーの獲得バッジを取得
  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    try {
      final response = await _supabase
          .from('user_achievements')
          .select()
          .eq('user_id', userId)
          .order('unlocked_at', ascending: false);

      return (response as List)
          .map((json) => UserAchievement.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting user achievements: $e');
      rethrow;
    }
  }

  /// ユーザーが獲得済みのバッジIDリストを取得
  Future<Set<String>> getUnlockedAchievementIds(String userId) async {
    try {
      final achievements = await getUserAchievements(userId);
      return achievements.map((a) => a.achievementId).toSet();
    } catch (e) {
      print('Error getting unlocked achievement IDs: $e');
      return {};
    }
  }

  /// バッジを解除
  Future<UserAchievement> unlockAchievement({
    required String userId,
    required String achievementId,
  }) async {
    try {
      final response = await _supabase
          .from('user_achievements')
          .insert({
            'user_id': userId,
            'achievement_id': achievementId,
          })
          .select()
          .single();

      return UserAchievement.fromJson(response);
    } catch (e) {
      print('Error unlocking achievement: $e');
      rethrow;
    }
  }

  /// 条件をチェックしてバッジを解除
  Future<List<String>> checkAndUnlockAchievements({
    required String userId,
    required int streakCount,
    required int sentenceCount,
    required int scenarioCount,
    required int hintFreeCount,
  }) async {
    try {
      final achievements = await getAchievements();
      final unlockedIds = await getUnlockedAchievementIds(userId);
      final newlyUnlocked = <String>[];

      for (final achievement in achievements) {
        if (unlockedIds.contains(achievement.id)) continue;

        bool shouldUnlock = false;
        switch (achievement.conditionType) {
          case 'streak':
            shouldUnlock = streakCount >= achievement.conditionValue;
            break;
          case 'sentence_count':
            shouldUnlock = sentenceCount >= achievement.conditionValue;
            break;
          case 'scenario_count':
            shouldUnlock = scenarioCount >= achievement.conditionValue;
            break;
          case 'hint_free_count':
            shouldUnlock = hintFreeCount >= achievement.conditionValue;
            break;
        }

        if (shouldUnlock) {
          await unlockAchievement(
            userId: userId,
            achievementId: achievement.id,
          );
          newlyUnlocked.add(achievement.id);
        }
      }

      return newlyUnlocked;
    } catch (e) {
      print('Error checking achievements: $e');
      return [];
    }
  }
}
