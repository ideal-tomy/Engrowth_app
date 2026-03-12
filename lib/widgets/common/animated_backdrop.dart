import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/engrowth_theme.dart';

/// Popup 用の背景ぼかしアニメーション。
/// 登場時: sigma 0 → EngrowthPopupTokens.backdropSigma へ Tween しつつ、暗いオーバーレイもフェードイン。
/// 退場時: sigma EngrowthPopupTokens.backdropSigma → 0 へ Tween しつつ、オーバーレイもフェードアウト。
class AnimatedBackdrop extends StatelessWidget {
  const AnimatedBackdrop({
    super.key,
    required this.child,
    this.duration,
    this.isExiting = false,
    this.exitDuration,
  });

  final Widget child;
  final Duration? duration;
  final bool isExiting;
  final Duration? exitDuration;

  @override
  Widget build(BuildContext context) {
    final effectiveDuration = isExiting
        ? (exitDuration ?? EngrowthPopupTokens.bridgeBlurExitDuration)
        : (duration ?? EngrowthPopupTokens.backdropDuration);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: isExiting ? EngrowthPopupTokens.backdropSigma : 0,
        end: isExiting ? 0 : EngrowthPopupTokens.backdropSigma,
      ),
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

