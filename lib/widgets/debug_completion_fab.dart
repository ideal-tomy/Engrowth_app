import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/scenario_provider.dart';
import '../providers/story_provider.dart';
import '../services/learning_completion_orchestrator.dart';
import '../services/scenario_service.dart';
import '../services/story_service.dart';

/// kDebugMode限定：最寄り未クリアノードを完了シミュレートしてオーケストレーターを起動
/// 進捗ポップアップ・アンロック・オートスクロールの確認用
class DebugCompletionFab extends ConsumerWidget {
  final String track; // 'story' | 'scenario'

  const DebugCompletionFab({super.key, required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) return const SizedBox.shrink();

    return FloatingActionButton.small(
      heroTag: 'debug_completion_$track',
      onPressed: () => _onPressed(context, ref),
      backgroundColor: Colors.orange.shade700,
      child: const Icon(Icons.play_circle_outline, color: Colors.white, size: 20),
      tooltip: '完了シミュレート ($track)',
    );
  }

  Future<void> _onPressed(BuildContext context, WidgetRef ref) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ログインが必要です')),
        );
      }
      return;
    }

    try {
      if (track == 'story') {
        final targetId = await ref.read(firstIncompleteStoryIdProvider.future);
        if (targetId == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('すべてクリア済み（story）')),
            );
          }
          return;
        }
        final service = ref.read(storyServiceProvider);
        await service.saveStoryProgress(
          userId: userId,
          storySequenceId: targetId,
          completed: true,
        );
        ref.invalidate(storyProgressProvider(targetId));
        ref.invalidate(firstIncompleteStoryIdProvider);
        ref.invalidate(storySequencesByThemeProvider);
      } else {
        final targetId = await ref.read(firstIncompleteScenarioIdProvider.future);
        if (targetId == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('すべてクリア済み（scenario）')),
            );
          }
          return;
        }
        final service = ref.read(scenarioServiceProvider);
        final steps = await service.getScenarioSteps(targetId);
        final lastStepIndex = steps.isEmpty ? 0 : steps.length - 1;
        await service.updateProgress(
          userId: userId,
          scenarioId: targetId,
          stepIndex: lastStepIndex,
          completed: true,
        );
        ref.invalidate(userScenarioProgressProvider(targetId));
        ref.invalidate(firstIncompleteScenarioIdProvider);
        ref.invalidate(scenariosProvider);
      }

      if (context.mounted) {
        await LearningCompletionOrchestrator.onLearningCompleted(
          ref,
          context,
          progressTrack: track == 'story' ? 'story' : 'scenario',
          forceProgressPopup: true,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('シミュレート失敗: $e')),
        );
      }
    }
  }
}
