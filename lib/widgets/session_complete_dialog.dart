import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_stats_provider.dart';
import '../providers/sentence_provider.dart';
import '../providers/analytics_provider.dart';
import '../theme/engrowth_theme.dart';

/// Quick30/Focus3 セッション完了時の習慣化ダイアログ
/// 達成感・連続日数・次タスクをワンタップで提案
class SessionCompleteDialog extends ConsumerWidget {
  final String sessionLabel;
  final VoidCallback? onStartAnother;

  const SessionCompleteDialog({
    super.key,
    required this.sessionLabel,
    this.onStartAnother,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);
    final recommendedAsync = ref.watch(recommendedSentenceProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: EngrowthColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 56, color: EngrowthColors.primary),
            const SizedBox(height: 16),
            Text(
              'セッション完了！',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: EngrowthColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sessionLabel,
              style: TextStyle(
                fontSize: 14,
                color: EngrowthColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            statsAsync.when(
              data: (stats) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('\u{1F525}', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      '${stats.streakCount}日連続',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: EngrowthColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(height: 44),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            const Text(
              '次にやること',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: EngrowthColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ref.read(analyticsServiceProvider).logNextTaskAccepted(nextType: 'study');
                  Navigator.of(context).pop();
                  if (onStartAnother != null) {
                    onStartAnother!();
                  } else {
                    context.push('/study');
                  }
                },
                icon: const Icon(Icons.play_arrow, size: 22),
                label: Text(
                  recommendedAsync.valueOrNull != null
                      ? 'もう1セット続ける'
                      : '学習を続ける',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: EngrowthColors.primary,
                  foregroundColor: EngrowthColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pop();
                  context.go('/home');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('ホームへ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
