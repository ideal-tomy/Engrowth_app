import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/analytics_provider.dart';
import '../../theme/engrowth_theme.dart';
import 'animated_backdrop.dart';
import 'engrowth_popup.dart';
import 'engrowth_card.dart';
import 'engrowth_cta.dart';
import 'stagger_reveal.dart';

/// カルーセル内の1ページ分のコンテンツ定義
class EngrowthPopupPage {
  const EngrowthPopupPage({
    this.customChild,
    this.hero,
    this.title,
    this.subtitle,
    this.body,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.autoAdvanceAfter,
  });

  /// 指定時は hero/title/body 等を無視し、このウィジェットを表示（例: StoryStudy 埋め込み）
  final Widget? customChild;

  final Widget? hero;
  final String? title;
  final String? subtitle;
  final Widget? body;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  /// このページで自動で次へ進むまでの時間（指定時はタイマーで次ページへ）
  final Duration? autoAdvanceAfter;
}

/// 複数ページをスライド切替で表示するポップアップカルーセル。
/// 背景ぼかしは1回だけ、ページ切替は下方向フェードアウト／下からスライドインで実施。
class EngrowthPopupCarousel extends ConsumerStatefulWidget {
  const EngrowthPopupCarousel({
    super.key,
    required this.pages,
    this.size = EngrowthPopupSize.medium,
    this.onDismiss,
    this.analyticsSourceScreen,
    /// 埋め込みコンテンツ（例: StoryStudyScreen）から「次へ」を依頼するためのコールバックを渡す用
    this.advanceCallbackNotifier,
    this.onAutoAdvanceFromPage,
  });

  final List<EngrowthPopupPage> pages;
  final EngrowthPopupSize size;
  final VoidCallback? onDismiss;
  final String? analyticsSourceScreen;
  final ValueNotifier<VoidCallback?>? advanceCallbackNotifier;
  /// 自動送り（タイマー）で次ページへ進んだときに呼ばれる。引数は進む前のページ index。
  final void Function(int fromIndex)? onAutoAdvanceFromPage;

  static const int _slideOffsetPx = 30;
  static const int _totalTransitionMs = 1300;
  static const int _exitDurationMs = 600;
  static const int _enterStartMs = 400;
  static const int _enterDurationMs = 900;

  static Future<T?> show<T>(
    BuildContext context, {
    required List<EngrowthPopupPage> pages,
    EngrowthPopupSize size = EngrowthPopupSize.medium,
    VoidCallback? onDismiss,
    String? analyticsSourceScreen,
    ValueNotifier<VoidCallback?>? advanceCallbackNotifier,
    void Function(int fromIndex)? onAutoAdvanceFromPage,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: EngrowthPopupTokens.backdropDuration,
      pageBuilder: (context, _, __) {
        return Center(
          child: EngrowthPopupCarousel(
            pages: pages,
            size: size,
            onDismiss: onDismiss,
            analyticsSourceScreen: analyticsSourceScreen,
            advanceCallbackNotifier: advanceCallbackNotifier,
            onAutoAdvanceFromPage: onAutoAdvanceFromPage,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  ConsumerState<EngrowthPopupCarousel> createState() =>
      _EngrowthPopupCarouselState();
}

class _EngrowthPopupCarouselState extends ConsumerState<EngrowthPopupCarousel>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int? _previousIndex;
  late AnimationController _transitionController;
  Timer? _autoAdvanceTimer;

  @override
  void initState() {
    super.initState();
    widget.advanceCallbackNotifier?.value = _goToNext;
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: EngrowthPopupCarousel._totalTransitionMs),
    );
    _transitionController.addListener(() {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(analyticsServiceProvider).logEvent(
            eventType: 'popup_carousel_shown',
            eventProperties: {
              'size': widget.size.name,
              'page_count': widget.pages.length,
              if (widget.analyticsSourceScreen != null)
                'source_screen': widget.analyticsSourceScreen!,
            },
          );
    });

    _startAutoAdvanceIfNeeded();
  }

  void _startAutoAdvanceIfNeeded() {
    _autoAdvanceTimer?.cancel();
    if (_currentIndex >= widget.pages.length) return;
    final page = widget.pages[_currentIndex];
    final duration = page.autoAdvanceAfter;
    if (duration == null) return;
    _autoAdvanceTimer = Timer(duration, () {
      if (!mounted) return;
      _goToNext(trigger: 'auto');
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _transitionController.dispose();
    super.dispose();
  }

  void _goToNext({String trigger = 'cta'}) {
    _autoAdvanceTimer?.cancel();
    if (trigger == 'auto') {
      widget.onAutoAdvanceFromPage?.call(_currentIndex);
    }
    if (_currentIndex >= widget.pages.length - 1) {
      _dismiss();
      return;
    }
    _previousIndex = _currentIndex;
    _currentIndex++;
    ref.read(analyticsServiceProvider).logEvent(
          eventType: 'popup_carousel_page_changed',
          eventProperties: {
            'from_index': _previousIndex,
            'to_index': _currentIndex,
            'trigger': trigger,
          },
        );
    _transitionController.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() {
        _previousIndex = null;
        _transitionController.reset();
      });
      _startAutoAdvanceIfNeeded();
    });
    setState(() {});
  }

  void _dismiss() {
    ref.read(analyticsServiceProvider).logEvent(
          eventType: 'popup_carousel_dismissed',
          eventProperties: {
            'at_page_index': _currentIndex,
            'dismiss_reason': 'user',
          },
        );
    Navigator.of(context).pop();
    widget.onDismiss?.call();
  }

  double _paddingForSize(EngrowthPopupSize size) {
    switch (size) {
      case EngrowthPopupSize.small:
        return 24;
      case EngrowthPopupSize.medium:
        return 20;
      case EngrowthPopupSize.large:
        return EngrowthPopupTokens.largePaddingH;
    }
  }

  BoxConstraints? _constraintsForSize(
    EngrowthPopupSize size,
    MediaQueryData mediaQuery,
  ) {
    final height = mediaQuery.size.height;
    switch (size) {
      case EngrowthPopupSize.small:
        return null;
      case EngrowthPopupSize.medium:
        return BoxConstraints(
          maxHeight: height * EngrowthPopupTokens.mediumHeightFraction,
        );
      case EngrowthPopupSize.large:
        return BoxConstraints(
          maxHeight: height * EngrowthPopupTokens.largeHeightFraction,
        );
    }
  }

  Widget _buildPageContent(BuildContext context, EngrowthPopupPage page) {
    if (page.customChild != null) {
      return page.customChild!;
    }
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final children = <Widget>[];

    if (page.hero != null) {
      children.add(Center(child: page.hero!));
    }
    if (page.title != null) {
      children.add(Text(
        page.title!,
        textAlign: TextAlign.center,
        style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
      ));
    }
    if (page.subtitle != null) {
      children.add(Text(
        page.subtitle!,
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ));
    }
    if (page.body != null) {
      children.add(page.body!);
    }
    if (page.primaryLabel != null || page.secondaryLabel != null) {
      children.add(const SizedBox(height: 8));
    }
    if (page.primaryLabel != null) {
      children.add(EngrowthPrimaryButton(
        label: page.primaryLabel!,
        onPressed: () {
          page.onPrimary?.call();
          _goToNext(trigger: 'cta');
        },
      ));
    }
    if (page.secondaryLabel != null) {
      children.add(const SizedBox(height: 8));
      children.add(EngrowthSecondaryButton(
        label: page.secondaryLabel!,
        onPressed: page.onSecondary,
      ));
    }

    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      if (i != children.length - 1) spaced.add(const SizedBox(height: 12));
    }

    return StaggerReveal(
      play: true,
      once: false,
      children: spaced,
    );
  }

  Widget _buildCardForIndex(int index) {
    final page = widget.pages[index];
    final mediaQuery = MediaQuery.of(context);
    final paddingH = _paddingForSize(widget.size);
    final constraints = _constraintsForSize(widget.size, mediaQuery);

    if (page.customChild != null) {
      Widget child = page.customChild!;
      if (constraints != null) {
        child = ConstrainedBox(
          constraints: constraints,
          child: child,
        );
      }
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: paddingH),
        child: child,
      );
    }

    Widget content = _buildPageContent(context, page);
    if (constraints != null) {
      content = SingleChildScrollView(child: content);
    }

    Widget card = EngrowthCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(24),
      child: constraints != null
          ? ConstrainedBox(
              constraints: constraints,
              child: content,
            )
          : content,
    );

    if (constraints != null) {
      card = ConstrainedBox(
        constraints: constraints,
        child: card,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingH),
      child: card,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final slidePx = EngrowthPopupCarousel._slideOffsetPx.toDouble();

    Widget currentChild = _buildCardForIndex(_currentIndex);
    if (_previousIndex != null) {
      final t = _transitionController.value;
      const totalMs = EngrowthPopupCarousel._totalTransitionMs;
      const exitMs = EngrowthPopupCarousel._exitDurationMs;
      const enterStartMs = EngrowthPopupCarousel._enterStartMs;
      const enterMs = EngrowthPopupCarousel._enterDurationMs;

      final exitT = (t * totalMs / exitMs).clamp(0.0, 1.0);
      final enterT = ((t * totalMs - enterStartMs) / enterMs).clamp(0.0, 1.0);

      currentChild = Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: Offset(0, slidePx * exitT),
            child: Opacity(
              opacity: 1 - exitT,
              child: _buildCardForIndex(_previousIndex!),
            ),
          ),
          Transform.translate(
            offset: Offset(0, slidePx * (1 - enterT)),
            child: Opacity(
              opacity: enterT,
              child: _buildCardForIndex(_currentIndex),
            ),
          ),
        ],
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: AnimatedBackdrop(
        child: Stack(
          alignment: Alignment.center,
          children: [
            currentChild,
            Positioned(
              top: mediaQuery.padding.top + 8,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _dismiss,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
