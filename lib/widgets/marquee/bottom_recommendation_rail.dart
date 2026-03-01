import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/ui_experiments_provider.dart';
import 'marquee_rail_data.dart';

/// フッター上に表示するおすすめレール（1段）
/// AnimationControllerで滑らかに自動スクロール
class BottomRecommendationRail extends ConsumerWidget {
  const BottomRecommendationRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(enableMarqueeRailProvider);
    if (!enabled) return const SizedBox.shrink();

    final items = ref.watch(marqueeRailItemsProvider);
    if (items.isEmpty) return const SizedBox.shrink();

    return _BottomRecommendationRailBody(items: items);
  }
}

class _BottomRecommendationRailBody extends StatefulWidget {
  final List<MarqueeRailItem> items;

  const _BottomRecommendationRailBody({required this.items});

  @override
  State<_BottomRecommendationRailBody> createState() =>
      _BottomRecommendationRailBodyState();
}

class _BottomRecommendationRailBodyState
    extends State<_BottomRecommendationRailBody>
    with SingleTickerProviderStateMixin {
  static const _railHeight = 36.0;
  static const _chipPaddingH = 10.0;
  static const _chipGap = 8.0;
  static const _autoScrollSpeed = 14.0; // px/s（ヘッダーより少しゆっくり）

  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  Duration _lastTickElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_onAnimationTick);

    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _onAnimationTick() {
    if (!_scrollController.hasClients ||
        MediaQuery.disableAnimationsOf(context)) return;

    final elapsed = _animationController.lastElapsedDuration;
    if (elapsed == null) return;

    final pos = _scrollController.position;
    final firstCopyWidth = (pos.maxScrollExtent + pos.viewportDimension) / 2;
    if (firstCopyWidth <= 0) return;

    final deltaSeconds = (elapsed - _lastTickElapsed).inMicroseconds / 1e6;
    _lastTickElapsed = elapsed;
    if (deltaSeconds <= 0 || deltaSeconds > 0.5) return;

    final pixelDelta = _autoScrollSpeed * deltaSeconds;
    final newOffset = pos.pixels + pixelDelta;

    if (newOffset >= firstCopyWidth) {
      _scrollController.jumpTo(newOffset - firstCopyWidth);
    } else {
      _scrollController.jumpTo(newOffset.clamp(0.0, pos.maxScrollExtent));
    }
  }

  void _startAutoScroll() {
    if (!mounted || MediaQuery.disableAnimationsOf(context)) return;
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.removeListener(_onAnimationTick);
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final items = widget.items;
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final duplicatedCount = items.length * 2;

        return Container(
          height: _railHeight,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(isDark ? 0.92 : 0.95),
          ),
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: duplicatedCount,
            separatorBuilder: (_, __) => const SizedBox(width: _chipGap),
            itemBuilder: (_, i) {
              final item = items[i % items.length];
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
      },
    );
  }
}
