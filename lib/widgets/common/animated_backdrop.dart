import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/engrowth_theme.dart';

/// Popup 用の背景ぼかしアニメーション。
/// sigma 0 → EngrowthPopupTokens.backdropSigma へ Tween しつつ、暗いオーバーレイもフェードインする。
class AnimatedBackdrop extends StatelessWidget {
  const AnimatedBackdrop({
    super.key,
    required this.child,
    this.duration,
  });

  final Widget child;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    final effectiveDuration =
        duration ?? EngrowthPopupTokens.backdropDuration;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: EngrowthPopupTokens.backdropSigma),
      duration: effectiveDuration,
      curve: EngrowthPopupTokens.backdropCurve,
      builder: (context, sigma, _) {
        final opacity =
            (sigma / EngrowthPopupTokens.backdropSigma).clamp(0.0, 1.0);

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Container(
            color: Colors.black.withOpacity(0.4 * opacity),
            child: child,
          ),
        );
      },
    );
  }
}

