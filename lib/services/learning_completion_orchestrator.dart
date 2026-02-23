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
import '../providers/anonymous_conversion_provider.dart';
import '../providers/study_progress_prompt_provider.dart';
import '../widgets/achievement_unlock_dialog.dart';
import '../widgets/anonymous_conversion_dialog.dart';
import '../widgets/progress_mini_popup.dart';
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
  /// [progressTrack] 'scenario' | 'story' のときのみ進捗ミニポップアップを検討
  static Future<void> onLearningCompleted(
    WidgetRef ref,
    BuildContext context, {
    String? progressTrack,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    // バックエンド連携（DB未設定時はここで失敗するが処理は続行）
    try {
      final statsNotifier = ref.read(userStatsNotifierProvider.notifier);
      final statsService = ref.read(userStatsServiceProvider);

      await statsNotifier.updateStreak();
      await statsNotifier.incrementDailyDone();

      ref.read(analyticsServiceProvider).logStudyComplete();
      final stats = await statsService.getOrCreateUserStats(userId);
      if (stats.isMissionCompleted) {
        ref.read(analyticsServiceProvider).logMissionComplete();
      }

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

      final progressList = await SupabaseService.getUserProgress(userId);
      final masteredCount = progressList.where((p) => p.isMastered).length;
      final hintFreeCount = progressList
          .where((p) => p.isMastered && !p.usedHintToMaster)
          .length;

      final scenarioService = ScenarioService();
      final scenarios = await scenarioService.getScenarios();
      int completedScenarios = 0;
      for (final scenario in scenarios) {
        final progress = await scenarioService.getUserProgress(userId, scenario.id);
        if (progress?.isCompleted == true) {
          completedScenarios++;
        }
      }

      final achievementService = AchievementService();
      final newlyUnlocked = await achievementService.checkAndUnlockAchievements(
        userId: userId,
        streakCount: stats.streakCount,
        sentenceCount: masteredCount,
        scenarioCount: completedScenarios,
        hintFreeCount: hintFreeCount,
      );

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

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && user.isAnonymous) {
        final convNotifier = ref.read(anonymousConversionProvider.notifier);
        await convNotifier.onCompletion();
        if (await convNotifier.shouldShowPrompt() && context.mounted) {
          ref.read(analyticsServiceProvider).logAnonPromptShown();
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => const AnonymousConversionDialog(),
          );
        }
      }
    } catch (e) {
      print('LearningCompletionOrchestrator backend error: $e');
    }

    // 進捗ミニポップアップはDB失敗時も表示（UI確認のため）
    final track = progressTrack;
    if (track != null && (track == 'scenario' || track == 'story')) {
      try {
        final promptNotifier = ref.read(studyProgressPromptProvider.notifier);
        if (await promptNotifier.onCompleted(track) && context.mounted) {
          ref.read(analyticsServiceProvider).logProgressPopupShown(
                reason: 'adaptive',
                track: track,
              );
          await showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (ctx) => ProgressMiniPopup(
              track: track,
              parentContext: context,
            ),
          );
          if (context.mounted) {
            await promptNotifier.markShown(track);
          }
        }
      } catch (e) {
        print('LearningCompletionOrchestrator progress popup error: $e');
      }
    }

    try {
      ref.invalidate(userStatsProvider);
      ref.invalidate(userStatsNotifierProvider);
      ref.invalidate(userProgressProvider);
      ref.invalidate(masteredCountProvider);
      ref.invalidate(achievementsProvider);
      ref.invalidate(userAchievementsProvider);
      ref.invalidate(unlockedAchievementIdsProvider);
    } catch (_) {}
  }
}
