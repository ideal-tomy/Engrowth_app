import 'package:flutter/material.dart';
import '../theme/engrowth_theme.dart';

/// オートスクロール＋アンロック演出：進捗を見るで開いたとき次にやる場所へスクロールし、軽くパルス
class ScrollTargetWrapper extends StatefulWidget {
  final bool isTarget;
  final Widget child;
  final String? unlockSnackBarMessage;

  const ScrollTargetWrapper({
    super.key,
    required this.isTarget,
    required this.child,
    this.unlockSnackBarMessage,
  });

  @override
  State<ScrollTargetWrapper> createState() => _ScrollTargetWrapperState();
}

class _ScrollTargetWrapperState extends State<ScrollTargetWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: EngrowthElementTokens.switchDuration,
    );
    if (widget.isTarget) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToAndGlow();
      });
    }
  }

  @override
  void didUpdateWidget(covariant ScrollTargetWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTarget && !oldWidget.isTarget) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToAndGlow();
      });
    }
  }

  void _scrollToAndGlow() {
    if (!mounted || !widget.isTarget) return;
    final context = this.context;
    Scrollable.ensureVisible(
      context,
      duration: EngrowthElementTokens.switchDuration,
      curve: EngrowthElementTokens.switchCurveIn,
    );
    _glowController.forward(from: 0);
    if (widget.unlockSnackBarMessage != null) {
      Future.delayed(EngrowthElementTokens.switchDuration, () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.unlockSnackBarMessage!),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            backgroundColor: EngrowthColors.primary,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isTarget) return widget.child;
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final scale =
            1.0 + (_glowController.value * 0.08 * (1 - _glowController.value));
        final glow = _glowController.value * 12 * (1 - _glowController.value);
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: glow > 0
                  ? [
                      BoxShadow(
                        color: EngrowthColors.primary.withOpacity(0.4),
                        blurRadius: glow,
                        spreadRadius: glow * 0.5,
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
