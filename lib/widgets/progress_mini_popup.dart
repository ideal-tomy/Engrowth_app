import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/analytics_provider.dart';
import '../theme/engrowth_theme.dart';

/// 学習完了後に控えめに表示する進捗ミニポップアップ
/// 「進捗マスが1つ進んだ」を伝え、続ける / 進捗を見る を選択可能
class ProgressMiniPopup extends ConsumerWidget {
  final String track; // 'scenario' | 'story'
  final BuildContext? parentContext; // 画面遷移用（dialogの外のcontext）

  const ProgressMiniPopup({
    super.key,
    required this.track,
    this.parentContext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = track == 'scenario' ? '/progress/scenario-board' : '/progress/story-board';
    final label = track == 'scenario' ? 'シナリオ' : '3分英会話';

    return AlertDialog(
      backgroundColor: EngrowthColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: EngrowthColors.silverBorder),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up, size: 40, color: EngrowthColors.primary),
          const SizedBox(height: 12),
          Text(
            '$labelの進捗が1マス進みました',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: EngrowthColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'すごろくで全体の進み具合を確認できます',
            style: TextStyle(
              fontSize: 13,
              color: EngrowthColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            ref.read(analyticsServiceProvider).logProgressPopupCtaViewBoard(track: track);
            Navigator.of(context).pop();
            final ctx = parentContext ?? context;
            if (ctx.mounted) ctx.push(route, extra: {'scrollToNext': true});
          },
          child: Text('進捗を見る', style: TextStyle(color: EngrowthColors.primary)),
        ),
        FilledButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            ref.read(analyticsServiceProvider).logProgressPopupCtaContinue(track: track);
            Navigator.of(context).pop();
          },
          child: const Text('続ける'),
        ),
      ],
    );
  }
}
