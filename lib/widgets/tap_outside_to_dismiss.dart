import 'package:flutter/material.dart';

/// 外側タップで閉じるオーバーレイ
/// ボトムシート・補助オーバーレイ・ガイド表示で統一利用
class TapOutsideToDismiss extends StatelessWidget {
  final Widget child;
  final VoidCallback onDismiss;
  final Color? barrierColor;
  final bool barrierDismissible;

  const TapOutsideToDismiss({
    super.key,
    required this.child,
    required this.onDismiss,
    this.barrierColor,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (barrierDismissible)
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: barrierColor ?? Colors.transparent,
              ),
            ),
          ),
        child,
      ],
    );
  }
}

/// モーダルオーバーレイ：外側タップで閉じる
/// showModalBottomSheet の barrierColor と併用する場合の補助
Widget buildDismissibleOverlay({
  required BuildContext context,
  required Widget child,
  required VoidCallback onDismiss,
  Color barrierColor = Colors.black54,
}) {
  return GestureDetector(
    onTap: onDismiss,
    behavior: HitTestBehavior.opaque,
    child: Container(
      color: barrierColor,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {}, // 子要素タップでは閉じない
        child: child,
      ),
    ),
  );
}
