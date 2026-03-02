import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_stats_provider.dart';
import '../providers/sentence_provider.dart';
import '../providers/analytics_provider.dart';
import 'common/engrowth_card.dart';
import 'common/engrowth_cta.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final statsAsync = ref.watch(userStatsProvider);
    final recommendedAsync = ref.watch(recommendedSentenceProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: EngrowthCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 56, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'セッション完了！',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sessionLabel,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            statsAsync.when(
              data: (stats) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('\u{1F525}', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      '${stats.streakCount}日連続',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(height: 44),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            Text(
              '次にやること',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            EngrowthPrimaryButton(
              label: recommendedAsync.valueOrNull != null
                  ? 'もう1セット続ける'
                  : '学習を続ける',
              icon: Icons.play_arrow,
              onPressed: () {
                ref.read(analyticsServiceProvider).logNextTaskAccepted(nextType: 'study');
                Navigator.of(context).pop();
                if (onStartAnother != null) {
                  onStartAnother!();
                } else {
                  context.push('/study');
                }
              },
            ),
            const SizedBox(height: 10),
            EngrowthSecondaryButton(
              label: 'ホームへ',
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
