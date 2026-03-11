import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/analytics_provider.dart';
import '../providers/sentence_provider.dart';
import '../providers/user_stats_provider.dart';
import 'common/engrowth_popup.dart';

/// Quick30/Focus3 セッション完了時の習慣化ダイアログ
/// EngrowthPopup テンプレートを用いて、高級感のある演出と次アクション提示を行う。
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
    final colorScheme = Theme.of(context).colorScheme;

    Widget? streakChip;
    statsAsync.when(
      data: (stats) {
        streakChip = Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 24)),
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
        );
      },
      loading: () {},
      error: (_, __) {},
    );

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (streakChip != null) streakChip!,
        const SizedBox(height: 16),
        Text(
          '次にやること',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    return EngrowthPopup(
      hero: const Icon(Icons.check_circle, size: 56),
      title: 'セッション完了！',
      subtitle: sessionLabel,
      body: body,
      primaryLabel: recommendedAsync.valueOrNull != null
          ? 'もう1セット続ける'
          : '学習を続ける',
      onPrimary: () {
        ref
            .read(analyticsServiceProvider)
            .logNextTaskAccepted(nextType: 'study');
        Navigator.of(context).pop();
        if (onStartAnother != null) {
          onStartAnother!();
        } else {
          context.push('/study');
        }
      },
      secondaryLabel: 'ホームへ',
      onSecondary: () {
        Navigator.of(context).pop();
        context.go('/home');
      },
      analyticsVariant: 'session_complete',
      analyticsSourceScreen: 'session',
    );
  }
}
