import 'package:flutter/material.dart';

/// 主要遷移先ページ用の余白＋軽いフェードイン
/// ヘッダー下に呼吸余白を確保し、高級感のある初期表示を実現
class LuxuryPageBody extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const LuxuryPageBody({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  State<LuxuryPageBody> createState() => _LuxuryPageBodyState();
}

class _LuxuryPageBodyState extends State<LuxuryPageBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..forward();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.only(top: 16),
      child: FadeTransition(
        opacity: _animation,
        child: widget.child,
      ),
    );
  }
}
