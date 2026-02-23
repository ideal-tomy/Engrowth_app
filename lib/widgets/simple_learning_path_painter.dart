import 'package:flutter/material.dart';
import '../theme/engrowth_theme.dart';

/// points から各ノードまでの累積パス長を返す（index 0 は 0、index i は 0〜i 区間の長さ）
List<double> pathLengthsAtNodes(List<Offset> points) {
  if (points.length < 2) return points.isEmpty ? [] : [0.0];
  final lengths = <double>[0.0];
  var cumulative = 0.0;
  for (var i = 1; i < points.length; i++) {
    final prev = points[i - 1];
    final curr = points[i];
    final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
    final seg = Path()
      ..moveTo(prev.dx, prev.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, curr.dx, curr.dy);
    cumulative += seg.computeMetrics().first.length;
    lengths.add(cumulative);
  }
  return lengths;
}

/// Bプラン：一筆書きの道（quadraticBezierTo・中点制御）
/// 銀ベース＋クリア済み区間を赤で「インクが流れる」ように描画
class SimpleLearningPathPainter extends CustomPainter {
  /// ノード中心を通る座標リスト（上から順）
  final List<Offset> points;
  /// 道の描画進捗 0.0〜1.0（この割合まで赤で描画）
  final double redProgress;
  final double strokeWidth;
  /// 完了ノード→次ノードの区間を目立たせるためのハイライト
  final int? highlightSegmentIndex;
  final double highlightPulse;

  SimpleLearningPathPainter({
    required this.points,
    this.redProgress = 0.0,
    this.strokeWidth = 12.0,
    this.highlightSegmentIndex,
    this.highlightPulse = 0.0,
  });

  static const _shadowBlur = 8.0;
  static const _shadowOffset = Offset(0, 2);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final path = _buildPath();

    // シャドウ（銀道の下に薄い影）
    canvas.save();
    canvas.translate(_shadowOffset.dx, _shadowOffset.dy);
    final shadowPaint = Paint()
      ..color = EngrowthColors.silverShadow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _shadowBlur)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // 道：銀ベース（全体）
    final silverPaint = Paint()
      ..color = EngrowthColors.silverBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, silverPaint);

    // クリア済み：赤が手前から流れる（PathMetrics で長さの割合を描画）
    if (redProgress > 0) {
      final redPaint = Paint()
        ..color = EngrowthColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      _drawPathSubset(canvas, path, redPaint, redProgress.clamp(0.0, 1.0));
    }

    // 次コンテンツへのガイド線（点滅）
    final hi = highlightSegmentIndex;
    if (hi != null && hi >= 0 && hi + 1 < points.length) {
      final from = points[hi];
      final to = points[hi + 1];
      final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
      final guide = Path()
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo(mid.dx, mid.dy, to.dx, to.dy);
      final guidePaint = Paint()
        ..color = EngrowthColors.primary.withOpacity(0.35 + highlightPulse * 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(guide, guidePaint);
    }
  }

  Path _buildPath() {
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
      path.quadraticBezierTo(mid.dx, mid.dy, curr.dx, curr.dy);
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
  bool shouldRepaint(covariant SimpleLearningPathPainter oldDelegate) =>
      oldDelegate.points.length != points.length ||
      oldDelegate.redProgress != redProgress ||
      oldDelegate.highlightSegmentIndex != highlightSegmentIndex ||
      oldDelegate.highlightPulse != highlightPulse ||
      (points.length == oldDelegate.points.length &&
          points.asMap().entries.any((e) =>
              e.value != oldDelegate.points[e.key]));
}

/// 一筆書きの道＋クリア済みまで赤がゆっくり流れるアニメーション
class SimpleLearningPath extends StatefulWidget {
  final List<Offset> points;
  /// クリア済みノード数（0 = なし、1 = 最初のみ、…）
  final int clearedCount;
  final double width;
  final double height;
  final double strokeWidth;
  final int? highlightSegmentIndex;

  const SimpleLearningPath({
    super.key,
    required this.points,
    required this.clearedCount,
    required this.width,
    required this.height,
    this.strokeWidth = 12.0,
    this.highlightSegmentIndex,
  });

  @override
  State<SimpleLearningPath> createState() => _SimpleLearningPathState();
}

class _SimpleLearningPathState extends State<SimpleLearningPath>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _guideController;
  late Animation<double> _guidePulse;
  double _lastRedProgress = 0.0;

  double _targetProgress() {
    if (widget.points.length < 2) return 0.0;
    final lengths = pathLengthsAtNodes(widget.points);
    final total = lengths.isEmpty ? 1.0 : lengths.last;
    if (total <= 0) return 0.0;
    final targetIndex = widget.clearedCount.clamp(0, widget.points.length);
    if (targetIndex >= lengths.length) return 1.0;
    return (lengths[targetIndex] / total).clamp(0.0, 1.0);
  }

  static const _kFullFillSeconds = 3.0; // 全体が塗りつぶされるまでの秒数
  static const _kMinDurationMs = 400;

  void _startAnimation(double current, double target) {
    final span = (target - current).abs();
    if (span < 0.001) return;
    final durationMs = (span * _kFullFillSeconds * 1000).round().clamp(_kMinDurationMs, 30000);
    _controller.dispose();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );
    _animation = Tween<double>(begin: current, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    _controller.forward();
  }

  @override
  void initState() {
    super.initState();
    final target = _targetProgress();
    final durationMs = (target * _kFullFillSeconds * 1000).round().clamp(_kMinDurationMs, 30000);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );
    _animation = Tween<double>(begin: 0.0, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    _guideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _guidePulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _guideController, curve: Curves.easeInOut),
    );
    _lastRedProgress = target;
    if (target > 0) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant SimpleLearningPath oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points ||
        oldWidget.clearedCount != widget.clearedCount) {
      final target = _targetProgress();
      final current = _controller.isAnimating ? _animation.value : _lastRedProgress;
      _lastRedProgress = target;
      if ((target - current).abs() < 0.001) return;
      _startAnimation(current, target);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _guideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: Listenable.merge([_animation, _guidePulse]),
        builder: (context, _) {
          final redProgress =
              _controller.isAnimating ? _animation.value : _lastRedProgress;
          return CustomPaint(
            painter: SimpleLearningPathPainter(
              points: widget.points,
              redProgress: redProgress,
              strokeWidth: widget.strokeWidth,
              highlightSegmentIndex: widget.highlightSegmentIndex,
              highlightPulse: _guidePulse.value,
            ),
            size: Size(widget.width, widget.height),
          );
        },
      ),
    );
  }
}
