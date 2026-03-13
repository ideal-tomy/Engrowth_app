import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// チュートリアル用：擬似指オーバーレイ
/// ターゲットへ移動→タップ演出→onComplete
class SimulatedFingerOverlay extends StatefulWidget {
  final GlobalKey targetKey;
  final VoidCallback onComplete;
  final Duration moveDuration;
  final Duration tapDuration;

  const SimulatedFingerOverlay({
    super.key,
    required this.targetKey,
    required this.onComplete,
    this.moveDuration = const Duration(milliseconds: 400),
    this.tapDuration = const Duration(milliseconds: 150),
  });

  @override
  State<SimulatedFingerOverlay> createState() => _SimulatedFingerOverlayState();
}

class _SimulatedFingerOverlayState extends State<SimulatedFingerOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<Offset>? _positionAnim;
  Animation<double>? _tapScaleAnim;
  bool _initialized = false;
  bool _hapticFired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAndStart());
  }

  void _initAndStart() {
    if (!mounted) return;
    final box = widget.targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) {
      // レイアウト未完了時は短い遅延後にリトライ（初回自動遷移時の不具合対策）
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        final retryBox =
            widget.targetKey.currentContext?.findRenderObject() as RenderBox?;
        if (retryBox != null && retryBox.hasSize && retryBox.attached) {
          _startAnimation(retryBox);
        } else {
          widget.onComplete();
        }
      });
      return;
    }
    _startAnimation(box);
  }

  void _startAnimation(RenderBox box) {
    if (!mounted) return;
    final target = box.localToGlobal(Offset.zero);
    final size = box.size;
    final targetCenter = Offset(
      target.dx + size.width / 2,
      target.dy + size.height / 2,
    );

    final screenSize = MediaQuery.of(context).size;
    final start = Offset(screenSize.width / 2, screenSize.height * 0.3);

    final controller = AnimationController(
      vsync: this,
      duration: widget.moveDuration + widget.tapDuration,
    );

    final positionAnim = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: start, end: targetCenter)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ConstantTween(targetCenter),
        weight: 0.2,
      ),
    ]).animate(CurvedAnimation(
      parent: controller,
      curve: const Interval(0, 0.85, curve: Curves.linear),
    ));

    final tapScaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(1),
        weight: 0.85,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.85)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.075,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 1)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 0.075,
      ),
    ]).animate(controller);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    controller.addListener(() {
      if (!_hapticFired && controller.value >= 0.82) {
        _hapticFired = true;
        HapticFeedback.selectionClick();
      }
    });

    setState(() {
      _controller = controller;
      _positionAnim = positionAnim;
      _tapScaleAnim = tapScaleAnim;
      _initialized = true;
    });

    controller.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || _controller == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, _) {
        final pos = _positionAnim!.value;
        final scale = _tapScaleAnim!.value;
        return IgnorePointer(
          child: Stack(
            children: [
              Positioned(
                left: pos.dx - 24,
                top: pos.dy - 48,
                child: Transform.scale(
                  scale: scale,
                  child: _FingerPainter(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FingerPainter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(48, 72),
      painter: _FingerShapePainter(),
    );
  }
}

class _FingerShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8B4A0)
      ..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = Path();
    final w = size.width * 0.5;

    path.moveTo(size.width / 2 - w / 3, size.height - 8);
    path.quadraticBezierTo(
      size.width / 2 - w / 2, size.height * 0.5,
      size.width / 2 - w / 4, 12,
    );
    path.quadraticBezierTo(
      size.width / 2, 0,
      size.width / 2 + w / 4, 12,
    );
    path.quadraticBezierTo(
      size.width / 2 + w / 2, size.height * 0.5,
      size.width / 2 + w / 3, size.height - 8,
    );
    path.close();

    canvas.saveLayer(Rect.largest, Paint());
    canvas.translate(4, 4);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    canvas.drawPath(path, paint);

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final highlightPath = Path();
    highlightPath.moveTo(size.width / 2 - 4, 20);
    highlightPath.quadraticBezierTo(
      size.width / 2 - 2, 8,
      size.width / 2 + 4, 18,
    );
    highlightPath.lineTo(size.width / 2 + 6, size.height * 0.5);
    highlightPath.quadraticBezierTo(
      size.width / 2, size.height * 0.6,
      size.width / 2 - 6, size.height * 0.5,
    );
    highlightPath.close();
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
