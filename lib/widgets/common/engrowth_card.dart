import 'package:flutter/material.dart';

/// B05: 共通カードコンポーネント
/// 背景・角丸・余白・shadow を engrowth_theme 準拠で統一
class EngrowthCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const EngrowthCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveShadow = boxShadow ??
        [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ];

    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: effectiveShadow,
      ),
      child: child,
    );
  }
}
