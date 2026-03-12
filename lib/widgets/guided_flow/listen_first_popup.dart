import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/engrowth_popup.dart';
import '../common/animated_backdrop.dart';
import '../../theme/engrowth_theme.dart';

/// Speak風ガイドフロー: 「まずは音声を最後まで聴いてください」ポップアップ
/// EngrowthPopup テンプレートを用いて実装する。
class ListenFirstPopup {
  const ListenFirstPopup._();

  /// モーダルで表示。OK・外側タップのいずれでも閉じられ、閉じたあと onDismiss を1回呼ぶ。
  /// [forNextStory] true のときは「学習を始める」ボタン表示（タップ＝閉じる＋音声開始のトリガーに）。
  /// [showDismissPermanentlyCheckbox] true のときは「今後このポップアップは表示しない」チェックボックスを表示し、
  /// チェック時は onDismiss(true) を呼ぶ（呼び出し元で永続化すること）。
  static Future<bool> show(
    BuildContext context, {
    String message = 'まずは音声を最後まで聴いてください',
    String? primaryLabel,
    bool forNextStory = false,
    required void Function(bool dismissPermanently) onDismiss,
    bool showDismissPermanentlyCheckbox = false,
    String? contentType,
    String? contentId,
    VoidCallback? onShown,
  }) async {
    HapticFeedback.selectionClick();
    WidgetsBinding.instance.addPostFrameCallback((_) => onShown?.call());

    final effectiveMessage = forNextStory ? '次の学習を始めましょう' : message;
    final effectiveLabel = primaryLabel ?? (forNextStory ? '学習を始める' : 'OK');

    if (showDismissPermanentlyCheckbox) {
      final result = await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.transparent,
        transitionDuration: EngrowthPopupTokens.backdropDuration,
        pageBuilder: (ctx, _, __) {
          return Center(
            child: _ListenFirstPopupWithCheckbox(
              message: effectiveMessage,
              subtitle: 'タップして閉じる（5秒で自動的に閉じます）',
              onDismiss: (v) => Navigator.of(ctx).pop(v),
            ),
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
      final dismissPermanently = result ?? false;
      onDismiss(dismissPermanently);
      return dismissPermanently;
    }

    await EngrowthPopup.show<void>(
      context,
      barrierDismissible: true,
      autoCloseAfter: const Duration(seconds: 5),
      hero: const Icon(Icons.headphones, size: 40),
      title: effectiveMessage,
      subtitle: 'タップして閉じる（5秒で自動的に閉じます）',
      primaryLabel: effectiveLabel,
      onPrimary: null,
      analyticsVariant: 'listen_first',
      analyticsSourceScreen: contentType,
    );
    onDismiss(false);
    return false;
  }
}

class _ListenFirstPopupWithCheckbox extends StatefulWidget {
  const _ListenFirstPopupWithCheckbox({
    required this.message,
    required this.subtitle,
    required this.onDismiss,
  });

  final String message;
  final String subtitle;
  final void Function(bool dismissPermanently) onDismiss;

  @override
  State<_ListenFirstPopupWithCheckbox> createState() =>
      _ListenFirstPopupWithCheckboxState();
}

class _ListenFirstPopupWithCheckboxState
    extends State<_ListenFirstPopupWithCheckbox> {
  bool _dismissPermanently = false;
  Timer? _autoCloseTimer;

  void _close(bool value) {
    _autoCloseTimer?.cancel();
    widget.onDismiss(value);
  }

  @override
  void initState() {
    super.initState();
    _autoCloseTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) _close(_dismissPermanently);
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final maxH = height * EngrowthPopupTokens.largeHeightFraction;

    return AnimatedBackdrop(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _close(_dismissPermanently),
              behavior: HitTestBehavior.opaque,
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () => _close(_dismissPermanently),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400, maxHeight: maxH),
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  color: colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.headphones, size: 40, color: colorScheme.primary),
                        const SizedBox(height: 16),
                        Text(
                          widget.message,
                          textAlign: TextAlign.center,
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          value: _dismissPermanently,
                          onChanged: (v) {
                            setState(() => _dismissPermanently = v ?? false);
                          },
                          title: Text(
                            '今後このポップアップは表示しない',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
