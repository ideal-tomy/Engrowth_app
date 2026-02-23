import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/engrowth_theme.dart';

/// 正弦波上の1区間を描画（連続パス用）
/// 接線一致で滑らかS字曲線、太さ12・薄いシャドウ・クリア時は赤が流れるアニメーション
class ContinuousPathSegment extends StatefulWidget {
  final double fromX;
  final double toX;
  /// 区間先頭・末尾の接線傾き（dx/dy）。省略時は従来のベジェ
  final double? fromSlope;
  final double? toSlope;
  final double width;
  final double height;
  final bool isCleared;
  final bool animateToRed;

  const ContinuousPathSegment({
    super.key,
    required this.fromX,
    required this.toX,
    this.fromSlope,
    this.toSlope,
    required this.width,
    this.height = 52,
    this.isCleared = false,
    this.animateToRed = false,
  });

  @override
  State<ContinuousPathSegment> createState() => _ContinuousPathSegmentState();
}

class _ContinuousPathSegmentState extends State<ContinuousPathSegment>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _anim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    // 初回表示ではアニメしない（didUpdateWidget で「クリアした瞬間」のみ再生）
  }

  @override
  void didUpdateWidget(covariant ContinuousPathSegment oldWidget) {
    super.didUpdateWidget(oldWidget);
    final becameCleared = widget.isCleared && !oldWidget.isCleared;
    final shouldAnimate = widget.animateToRed && widget.isCleared && !oldWidget.animateToRed;
    if (becameCleared || shouldAnimate) {
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final progress = widget.animateToRed && widget.isCleared
            ? _anim.value
            : (widget.isCleared ? 1.0 : 0.0);
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: CustomPaint(
            painter: _ContinuousPathSegmentPainter(
              fromX: widget.fromX,
              toX: widget.toX,
              fromSlope: widget.fromSlope,
              toSlope: widget.toSlope,
              isCleared: widget.isCleared,
              redProgress: progress,
            ),
            size: Size(widget.width, widget.height),
          ),
        );
      },
    );
  }
}

class _ContinuousPathSegmentPainter extends CustomPainter {
  final double fromX;
  final double toX;
  final double? fromSlope;
  final double? toSlope;
  final bool isCleared;
  final double redProgress;

  _ContinuousPathSegmentPainter({
    required this.fromX,
    required this.toX,
    this.fromSlope,
    this.toSlope,
    required this.isCleared,
    this.redProgress = 0.0,
  });

  static const _strokeWidth = 12.0;
  static const _shadowBlur = 8.0;
  static const _shadowOffset = Offset(0, 2);

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);
    final centerX = size.width / 2;

    // シャドウ（銀道の下に薄い影）
    canvas.save();
    canvas.translate(_shadowOffset.dx, _shadowOffset.dy);
    final shadowPaint = Paint()
      ..color = EngrowthColors.silverShadow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _shadowBlur)
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // 道：銀ベース
    final silverPaint = Paint()
      ..color = EngrowthColors.silverBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, silverPaint);

    // クリア済み区間：赤が追いかける
    if (isCleared && redProgress > 0) {
      final redPaint = Paint()
        ..color = EngrowthColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      _drawPathSubset(canvas, path, redPaint, redProgress);
    }
  }

  Path _buildPath(Size size) {
    final path = Path();
    final h = size.height;
    path.moveTo(fromX, 0);
    // 接線一致で滑らかS字：接線 (fromSlope,1) / (toSlope,1) で制御点を決める
    if (fromSlope != null && toSlope != null) {
      final k = h / 3;
      final ctrl1X = fromX + fromSlope! * k;
      final ctrl1Y = k;
      final ctrl2X = toX - toSlope! * k;
      final ctrl2Y = h - k;
      path.cubicTo(ctrl1X, ctrl1Y, ctrl2X, ctrl2Y, toX, h);
    } else {
      final ctrl1X = fromX + (toX - fromX) * 0.25;
      final ctrl1Y = h * 0.35;
      final ctrl2X = toX - (toX - fromX) * 0.25;
      final ctrl2Y = h * 0.65;
      path.cubicTo(ctrl1X, ctrl1Y, ctrl2X, ctrl2Y, toX, h);
    }
    return path;
  }

  void _drawPathSubset(Canvas canvas, Path path, Paint paint, double t) {
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final length = metric.length;
      final extractPath = metric.extractPath(0.0, length * t);
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ContinuousPathSegmentPainter oldDelegate) =>
      oldDelegate.fromX != fromX ||
      oldDelegate.toX != toX ||
      oldDelegate.fromSlope != fromSlope ||
      oldDelegate.toSlope != toSlope ||
      oldDelegate.isCleared != isCleared ||
      oldDelegate.redProgress != redProgress;
}
