import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// チュートリアル用：学習開始前に「何をするか」を説明するポップアップ
/// 指オーバーレイ完了後に表示。フェードインし、読む時間を考慮した秒数で自然に消える。
/// ユーザーアクションは不要（タップで早期閉じも可能）
class LearningIntroDialog extends StatefulWidget {
  const LearningIntroDialog({
    super.key,
    required this.title,
    required this.body,
    required this.onStart,
    this.autoDismissDuration = const Duration(seconds: 5),
  });

  final String title;
  final String body;
  final Future<void> Function() onStart;
  final Duration autoDismissDuration;

  /// モーダルで表示。フェードイン後、指定秒数で自動閉じて onStart を呼ぶ
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String body,
    required Future<void> Function() onStart,
    Duration autoDismissDuration = const Duration(seconds: 5),
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black38,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: LearningIntroDialog(
          title: title,
          body: body,
          onStart: onStart,
          autoDismissDuration: autoDismissDuration,
        ),
      ),
    );
  }

  @override
  State<LearningIntroDialog> createState() => _LearningIntroDialogState();
}

class _LearningIntroDialogState extends State<LearningIntroDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    _scheduleAutoDismiss();
  }

  void _scheduleAutoDismiss() {
    Future.delayed(widget.autoDismissDuration, () {
      if (mounted) _dismissAndStart();
    });
  }

  Future<void> _dismissAndStart() async {
    if (!mounted) return;
    HapticFeedback.selectionClick();
    Navigator.of(context).pop();
    await widget.onStart();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: _dismissAndStart,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: GestureDetector(
            onTap: _dismissAndStart,
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
                    Text(
                      widget.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.body,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
