import 'package:flutter/material.dart';
import '../theme/engrowth_theme.dart';

/// Nike Run Club風のリング型進捗インジケーター
/// その日の目標達成度を円形グラフで表現
class RingProgressIndicator extends StatelessWidget {
  final double progress;
  final String label;
  final String? sublabel;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;

  const RingProgressIndicator({
    super.key,
    required this.progress,
    this.label = '今日の達成',
    this.sublabel,
    this.size = 80,
    this.strokeWidth = 8,
    this.progressColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = progressColor ?? EngrowthColors.primary;
    final bg = backgroundColor ?? Colors.grey[300]!;
    final value = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: strokeWidth,
              backgroundColor: bg,
              valueColor: AlwaysStoppedAnimation<Color>(
                value >= 1.0 ? EngrowthColors.success : color,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: size * 0.12,
                  fontWeight: FontWeight.bold,
                  color: EngrowthColors.onSurface,
                ),
              ),
              if (sublabel != null) ...[
                const SizedBox(height: 2),
                Text(
                  sublabel!,
                  style: TextStyle(
                    fontSize: size * 0.1,
                    color: EngrowthColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
