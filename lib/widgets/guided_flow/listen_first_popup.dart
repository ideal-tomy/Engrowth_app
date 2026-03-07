import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/engrowth_theme.dart';

/// Speak風ガイドフロー: 「まずは音声を最後まで聴いてください」ポップアップ
/// タップで閉じ、閉じた後に再生ボタンを出現させるトリガーとして使用
class ListenFirstPopup extends StatefulWidget {
  const ListenFirstPopup({
    super.key,
    this.message = 'まずは音声を最後まで聴いてください',
    required this.onDismiss,
    this.contentType,
    this.contentId,
    this.onShown,
  });

  final String message;
  final VoidCallback onDismiss;
  final String? contentType;
  final String? contentId;
  final VoidCallback? onShown;

  /// モーダルで表示。タップで閉じると onDismiss を呼ぶ
  static Future<void> show(
    BuildContext context, {
    String message = 'まずは音声を最後まで聴いてください',
    required VoidCallback onDismiss,
    String? contentType,
    String? contentId,
    VoidCallback? onShown,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: ListenFirstPopup(
          message: message,
          onDismiss: onDismiss,
          contentType: contentType,
          contentId: contentId,
          onShown: onShown,
        ),
      ),
    );
  }

  @override
  State<ListenFirstPopup> createState() => _ListenFirstPopupState();
}

class _ListenFirstPopupState extends State<ListenFirstPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: EngrowthElementTokens.switchDuration,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: EngrowthElementTokens.switchCurveIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, EngrowthElementTokens.switchOffsetY),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: EngrowthElementTokens.switchCurveIn,
    ));
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onShown?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (!mounted) return;
    HapticFeedback.selectionClick();
    Navigator.of(context).pop();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: _dismiss,
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: GestureDetector(
              onTap: _dismiss,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.headphones,
                        size: 40,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.message,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'タップして閉じる',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
