import 'package:flutter/material.dart';

import '../../theme/engrowth_theme.dart';

/// Phase B: 画面内切り替えをフェード + Y スライドで統一する Widget
/// AnimatedSwitcher をラップし、共通の duration/curve/offset を適用する
///
/// 使用例:
/// ```dart
/// FadeSlideSwitcher(
///   childKey: ValueKey(selectedIndex),
///   child: _buildContent(selectedIndex),
/// )
/// ```
class FadeSlideSwitcher extends StatelessWidget {
  /// 表示する子 Widget
  final Widget child;

  /// 切替を検知するための Key。変化時に transition が発火する
  final Key? childKey;

  /// 切替 duration（未指定時は EngrowthElementTokens を使用）
  final Duration? duration;

  /// 表示側の curve
  final Curve? switchInCurve;

  /// 非表示側の curve
  final Curve? switchOutCurve;

  /// Y 方向のスライド量（小振幅 0.02〜0.03）
  final double offsetY;

  /// 配置
  final Alignment alignment;

  /// false のときアニメーションを無効化（即時切替）
  final bool enabled;

  const FadeSlideSwitcher({
    super.key,
    required this.child,
    this.childKey,
    this.duration,
    this.switchInCurve,
    this.switchOutCurve,
    this.offsetY = EngrowthElementTokens.switchOffsetY,
    this.alignment = Alignment.center,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final dur = duration ?? EngrowthElementTokens.switchDuration;
    final inCurve = switchInCurve ?? EngrowthElementTokens.switchCurveIn;
    final outCurve = switchOutCurve ?? EngrowthElementTokens.switchCurveOut;

    final wrappedChild = childKey != null
        ? KeyedSubtree(key: childKey!, child: child)
        : child;

    if (!enabled) {
      return wrappedChild;
    }

    return AnimatedSwitcher(
      duration: dur,
      switchInCurve: inCurve,
      switchOutCurve: outCurve,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: alignment,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, offsetY),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: inCurve,
            )),
            child: child,
          ),
        );
      },
      child: wrappedChild,
    );
  }
}
