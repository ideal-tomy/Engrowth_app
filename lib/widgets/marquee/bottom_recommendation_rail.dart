import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/ui_experiments_provider.dart';
import 'marquee_rail_data.dart';

/// フッター上に表示するおすすめレール（1段）
/// 高さ34〜38dp、横スクロール可能
class BottomRecommendationRail extends ConsumerWidget {
  const BottomRecommendationRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(enableMarqueeRailProvider);
    if (!enabled) return const SizedBox.shrink();

    final items = ref.watch(marqueeRailItemsProvider);
    if (items.isEmpty) return const SizedBox.shrink();

    return const _BottomRecommendationRailBody();
  }
}

class _BottomRecommendationRailBody extends ConsumerWidget {
  const _BottomRecommendationRailBody();

  static const _railHeight = 36.0;
  static const _chipPaddingH = 10.0;
  static const _chipGap = 8.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(marqueeRailItemsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: _railHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(isDark ? 0.92 : 0.95),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: _chipGap),
        itemBuilder: (_, i) {
          final item = items[i];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(marqueeRailTapProvider.notifier).onTap(item);
                if (item.route != null) {
                  context.push(item.route!);
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: _chipPaddingH),
                constraints: const BoxConstraints(minWidth: 72, maxWidth: 130),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.4),
                  ),
                ),
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
