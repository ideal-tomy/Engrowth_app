import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/ui_experiments_provider.dart';
import 'marquee_rail_data.dart';

/// ヘッダー直下に表示するMarquee導線
/// 自動スクロール + 手動スクロール時一時停止 + 1.2秒後に再開
class HeaderMarqueeRail extends ConsumerWidget {
  const HeaderMarqueeRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(enableMarqueeRailProvider);
    if (!enabled) return const SizedBox.shrink();

    final items = ref.watch(marqueeRailItemsProvider);
    if (items.isEmpty) return const SizedBox.shrink();

    return _HeaderMarqueeRailBody(items: items);
  }
}

class _HeaderMarqueeRailBody extends StatefulWidget {
  final List<MarqueeRailItem> items;

  const _HeaderMarqueeRailBody({required this.items});

  @override
  State<_HeaderMarqueeRailBody> createState() => _HeaderMarqueeRailBodyState();
}

class _HeaderMarqueeRailBodyState extends State<_HeaderMarqueeRailBody> {
  static const _autoScrollSpeed = 18.0; // px/s
  static const _resumeDelay = Duration(milliseconds: 1200);
  static const _chipHeight = 32.0;
  static const _chipPaddingH = 12.0;
  static const _chipGap = 10.0;

  final _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  bool _userScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final isUserScrolling = _scrollController.position.isScrollingNotifier.value;
    if (isUserScrolling && !_userScrolling) {
      _autoScrollTimer?.cancel();
      setState(() => _userScrolling = true);
    }
  }

  void _startAutoScroll() {
    if (mounted && MediaQuery.disableAnimationsOf(context)) return;

    void scheduleResume() {
      Future.delayed(_resumeDelay, () {
        if (!mounted) return;
        final notifier = _scrollController.position.isScrollingNotifier;
        if (!notifier.value) {
          setState(() => _userScrolling = false);
          _tickAutoScroll();
        } else {
          scheduleResume();
        }
      });
    }

    _scrollController.position.isScrollingNotifier.addListener(() {
      if (!_scrollController.position.isScrollingNotifier.value &&
          _userScrolling) {
        scheduleResume();
      }
    });

    if (!_userScrolling && !MediaQuery.disableAnimationsOf(context)) {
      _tickAutoScroll();
    }
  }

  void _tickAutoScroll() {
    _autoScrollTimer?.cancel();
    if (!mounted ||
        _userScrolling ||
        !_scrollController.hasClients ||
        MediaQuery.disableAnimationsOf(context)) return;

    const interval = Duration(milliseconds: 100);
    final deltaPerTick = _autoScrollSpeed * interval.inMilliseconds / 1000;

    _autoScrollTimer = Timer.periodic(interval, (_) {
      if (!mounted ||
          _userScrolling ||
          !_scrollController.hasClients ||
          MediaQuery.disableAnimationsOf(context)) return;

      final pos = _scrollController.position;
      final newOffset = pos.pixels + deltaPerTick;
      final firstCopyWidth =
          (pos.maxScrollExtent + pos.viewportDimension) / 2;

      if (firstCopyWidth > 0 && newOffset >= firstCopyWidth) {
        _scrollController.jumpTo(newOffset - firstCopyWidth);
      } else {
        _scrollController.jumpTo(newOffset.clamp(0.0, pos.maxScrollExtent));
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final items = widget.items;
        final colorScheme = Theme.of(context).colorScheme;

        final duplicatedCount = items.length * 2;

        return SizedBox(
          height: _chipHeight + 12,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            physics: const BouncingScrollPhysics(),
            itemCount: duplicatedCount,
            separatorBuilder: (_, __) => const SizedBox(width: _chipGap),
            itemBuilder: (_, i) =>
                _buildChip(context, ref, items[i % items.length], colorScheme),
          ),
        );
      },
    );
  }

  Widget _buildChip(
    BuildContext context,
    WidgetRef ref,
    MarqueeRailItem item,
    ColorScheme colorScheme,
  ) {
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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: _chipPaddingH),
          constraints: const BoxConstraints(minWidth: 80, maxWidth: 140),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Text(
            item.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
