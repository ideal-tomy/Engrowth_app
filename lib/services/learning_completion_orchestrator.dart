import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/progress_provider.dart';
import '../providers/user_stats_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/analytics_provider.dart';
import '../services/user_stats_service.dart';
import '../services/achievement_service.dart';
import '../services/scenario_service.dart';
import '../services/supabase_service.dart';
import '../widgets/achievement_unlock_dialog.dart';
import '../widgets/streak_milestone_dialog.dart';

/// 学習完了時の共通ハンドラ
/// 全モード（例文学習・シナリオ学習・会話学習）で同一順序で実行:
/// 1. updateStreak
/// 2. incrementDailyDone
/// 3. checkAndUnlockAchievements
/// 4. 新規解除演出表示
/// 5. provider refresh
class LearningCompletionOrchestrator {
  LearningCompletionOrchestrator._();

  /// 学習完了時に呼び出す
  /// [ref] RiverpodのWidgetRef（ConsumerStateから取得）
  /// [context] ダイアログ表示用のBuildContext
  static Future<void> onLearningCompleted(WidgetRef ref, BuildContext context) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final statsNotifier = ref.read(userStatsNotifierProvider.notifier);
      final statsService = ref.read(userStatsServiceProvider);

      // 1. ストリーク更新
      await statsNotifier.updateStreak();

      // 2. 日次ミッション進捗
      await statsNotifier.incrementDailyDone();

      // 2.5  analytics
      ref.read(analyticsServiceProvider).logStudyComplete();
      final stats = await statsService.getOrCreateUserStats(userId);
      if (stats.isMissionCompleted) {
        ref.read(analyticsServiceProvider).logMissionComplete();
      }

      // 3. 統計取得（ストリーク更新後）

      // 3.5 ストリークマイルストーン（7日/30日）演出
      const milestones = [7, 30];
      if (milestones.contains(stats.streakCount) && context.mounted) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => StreakMilestoneDialog(streakDays: stats.streakCount),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(context);
        }
      }

      // 進捗情報
      final progressList = await SupabaseService.getUserProgress(userId);
      final masteredCount = progressList.where((p) => p.isMastered).length;
      final hintFreeCount = progressList
          .where((p) => p.isMastered && !p.usedHintToMaster)
          .length;

      // シナリオ完了数
      final scenarioService = ScenarioService();
      final scenarios = await scenarioService.getScenarios();
      int completedScenarios = 0;
      for (final scenario in scenarios) {
        final progress = await scenarioService.getUserProgress(userId, scenario.id);
        if (progress?.isCompleted == true) {
          completedScenarios++;
        }
      }

      // 4. バッジ解除チェック
      final achievementService = AchievementService();
      final newlyUnlocked = await achievementService.checkAndUnlockAchievements(
        userId: userId,
        streakCount: stats.streakCount,
        sentenceCount: masteredCount,
        scenarioCount: completedScenarios,
        hintFreeCount: hintFreeCount,
      );

      // 5. 新規解除演出表示（キューで順次表示）
      if (newlyUnlocked.isNotEmpty) {
        final achievements = await ref.read(achievementsProvider.future);
        for (final achievementId in newlyUnlocked) {
          if (!context.mounted) break;
          final achievement = achievements.firstWhere((a) => a.id == achievementId);
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AchievementUnlockDialog(achievement: achievement),
          );
          await Future.delayed(const Duration(seconds: 2));
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop(context);
          }
        }
      }

      // 6. provider refresh
      ref.invalidate(userStatsProvider);
      ref.invalidate(userStatsNotifierProvider);
      ref.invalidate(userProgressProvider);
      ref.invalidate(masteredCountProvider);
      ref.invalidate(achievementsProvider);
      ref.invalidate(userAchievementsProvider);
      ref.invalidate(unlockedAchievementIdsProvider);
    } catch (e) {
      print('LearningCompletionOrchestrator error: $e');
    }
  }
}
