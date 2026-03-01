import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/ui_experiments_provider.dart';
import 'marquee_rail_data.dart';

/// ヘッダー直下に表示するMarquee導線
/// AnimationController（Ticker）で画面更新と同期し滑らかに自動スクロール
/// 手動スクロール時は一時停止し、1.2秒後に再開
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

class _HeaderMarqueeRailBodyState extends State<_HeaderMarqueeRailBody>
    with SingleTickerProviderStateMixin {
  static const _autoScrollSpeed = 18.0; // px/s（60fps想定で0.3px/frame）
  static const _resumeDelay = Duration(milliseconds: 500);
  static const _chipHeight = 32.0;
  static const _chipPaddingH = 12.0;
  static const _chipGap = 10.0;

  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  bool _userScrolling = false;
  Duration _lastTickElapsed = Duration.zero;
  Timer? _resumeCheckTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // 画面更新と同期するTickerで滑らかにスクロール（フレームレート非依存）
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_onAnimationTick);

    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final isUserScrolling = _scrollController.position.isScrollingNotifier.value;
    if (isUserScrolling && !_userScrolling) {
      _animationController.stop();
      _resumeCheckTimer?.cancel();
      setState(() => _userScrolling = true);
      _startResumeCheck();
    }
  }

  void _startResumeCheck() {
    _resumeCheckTimer?.cancel();
    _resumeCheckTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted || !_scrollController.hasClients) return;
      final notifier = _scrollController.position.isScrollingNotifier;
      if (!notifier.value && _userScrolling) {
        _resumeCheckTimer?.cancel();
        Future.delayed(_resumeDelay, () {
          if (!mounted) return;
          _doResume();
        });
      }
    });
  }

  void _doResume() {
    if (!mounted || !_scrollController.hasClients) return;
    if (!_userScrolling) return;
    final pos = _scrollController.position;
    final firstCopyWidth = (pos.maxScrollExtent + pos.viewportDimension) / 2;
    if (firstCopyWidth > 0) {
      final phase = pos.pixels % firstCopyWidth;
      _animationController.value = phase / firstCopyWidth;
    }
    _lastTickElapsed = Duration.zero;
    setState(() => _userScrolling = false);
    _animationController.repeat();
  }

  void _onAnimationTick() {
    if (!_scrollController.hasClients ||
        _userScrolling ||
        MediaQuery.disableAnimationsOf(context)) return;

    final elapsed = _animationController.lastElapsedDuration;
    if (elapsed == null) return;

    final pos = _scrollController.position;
    final firstCopyWidth = (pos.maxScrollExtent + pos.viewportDimension) / 2;
    if (firstCopyWidth <= 0) return;

    // 経過時間ベースでフレームレート非依存のスクロール
    final deltaSeconds = (elapsed - _lastTickElapsed).inMicroseconds / 1e6;
    _lastTickElapsed = elapsed;
    if (deltaSeconds <= 0) return;
    if (deltaSeconds > 0.5) return;
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
    if (!_userScrolling) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _resumeCheckTimer?.cancel();
    _animationController.removeListener(_onAnimationTick);
    _animationController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final items = widget.items;
        final duplicatedCount = items.length * 2;

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final colorScheme = Theme.of(context).colorScheme;

        return SizedBox(
          height: _chipHeight + 12,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            physics: const BouncingScrollPhysics(),
            itemCount: duplicatedCount,
            separatorBuilder: (_, __) => const SizedBox(width: _chipGap),
            itemBuilder: (_, i) => _buildChip(
              context,
              ref,
              items[i % items.length],
              isDark,
              colorScheme.onSurface,
            ),
          ),
        );
      },
    );
  }

  Widget _buildChip(
    BuildContext context,
    WidgetRef ref,
    MarqueeRailItem item,
    bool isDark,
    Color textColor,
  ) {
    final bg = MarqueeCategoryColors.tabBackground(item.category, isDark);
    final colorScheme = Theme.of(context).colorScheme;

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
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Text(
            item.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
