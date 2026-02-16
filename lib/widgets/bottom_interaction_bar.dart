import 'package:flutter/material.dart';

/// 下部固定操作バーの共通レイアウト
/// 余白・安全領域・視認性・押下領域を統一
class BottomInteractionBar extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final Color? backgroundColor;
  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;

  const BottomInteractionBar({
    super.key,
    required this.child,
    this.gradient,
    this.backgroundColor,
    this.horizontalPadding = 20,
    this.topPadding = 16,
    this.bottomPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBottom = bottomPadding + MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: topPadding,
        bottom: effectiveBottom,
      ),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? backgroundColor : null,
      ),
      child: SafeArea(
        top: false,
        child: child,
      ),
    );
  }
}

/// 下部ボタンの最小タッチサイズ（推奨）
const double kMinTouchTargetHeight = 48.0;
