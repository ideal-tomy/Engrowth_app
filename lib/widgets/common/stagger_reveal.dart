import 'package:flutter/material.dart';

import '../../theme/engrowth_theme.dart';

/// Phase B: 複数要素を時間差で段階表示する Widget
/// 初回表示時に物語性を持たせ、唐突な出現を避ける
///
/// 使用例:
/// ```dart
/// StaggerReveal(
///   children: [
///     Text('見出し'),
///     Text('要点'),
///     EngrowthPrimaryButton(label: '次へ', onPressed: () {}),
///   ],
/// )
/// ```
class StaggerReveal extends StatefulWidget {
  /// 段階表示する子 Widget のリスト（4–6 要素目安）
  final List<Widget> children;

  /// 1 要素あたりの遅延
  final Duration baseDelay;

  /// 各要素のアニメーション duration
  final Duration itemDuration;

  /// アニメーション curve
  final Curve curve;

  /// Y 方向のスライド量
  final double offsetY;

  /// false のときアニメーションを開始しない
  final bool play;

  /// true のとき初回のみアニメーション（再表示時は即時表示）
  final bool once;

  const StaggerReveal({
    super.key,
    required this.children,
    this.baseDelay = EngrowthStaggerTokens.itemDelay,
    this.itemDuration = EngrowthStaggerTokens.itemDuration,
    this.curve = EngrowthStaggerTokens.staggerCurve,
    this.offsetY = EngrowthStaggerTokens.staggerOffsetY,
    this.play = true,
    this.once = true,
  });

  @override
  State<StaggerReveal> createState() => _StaggerRevealState();
}

class _StaggerRevealState extends State<StaggerReveal>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _opacities;
  late List<Animation<Offset>> _offsets;
  bool _hasPlayed = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    final n = widget.children.length;
    if (n == 0) {
      _controllers = [];
      _opacities = [];
      _offsets = [];
      return;
    }
    _controllers = List.generate(
      n,
      (_) => AnimationController(
        vsync: this,
        duration: widget.itemDuration,
      ),
    );
    _opacities = List.generate(
      n,
      (i) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controllers[i], curve: widget.curve),
      ),
    );
    _offsets = List.generate(
      n,
      (i) => Tween<Offset>(
        begin: Offset(0, widget.offsetY),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _controllers[i], curve: widget.curve),
      ),
    );
  }

  @override
  void didUpdateWidget(StaggerReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length ||
        oldWidget.baseDelay != widget.baseDelay ||
        oldWidget.itemDuration != widget.itemDuration) {
      for (final c in _controllers) {
        c.dispose();
      }
      _initAnimations();
      _hasPlayed = false;
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _startAnimations() {
    if (!widget.play || (widget.once && _hasPlayed)) return;
    _hasPlayed = true;
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(widget.baseDelay * i, () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) {
      return const SizedBox.shrink();
    }
    if (!widget.play) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.children,
      );
    }

    if (widget.once && _hasPlayed) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.children,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _startAnimations());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(widget.children.length, (i) {
        return FadeTransition(
          opacity: _opacities[i],
          child: SlideTransition(
            position: _offsets[i],
            child: widget.children[i],
          ),
        );
      }),
    );
  }
}
