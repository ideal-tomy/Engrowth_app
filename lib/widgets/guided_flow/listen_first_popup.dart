import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/engrowth_popup.dart';

/// Speak風ガイドフロー: 「まずは音声を最後まで聴いてください」ポップアップ
/// EngrowthPopup テンプレートを用いて実装する。
class ListenFirstPopup {
  const ListenFirstPopup._();

  /// モーダルで表示。OK・外側タップのいずれでも閉じられ、閉じたあと onDismiss を1回呼ぶ。
  static Future<void> show(
    BuildContext context, {
    String message = 'まずは音声を最後まで聴いてください',
    required VoidCallback onDismiss,
    String? contentType,
    String? contentId,
    VoidCallback? onShown,
  }) async {
    HapticFeedback.selectionClick();
    WidgetsBinding.instance.addPostFrameCallback((_) => onShown?.call());

    await EngrowthPopup.show<void>(
      context,
      barrierDismissible: true,
      hero: const Icon(Icons.headphones, size: 40),
      title: message,
      subtitle: 'タップして閉じる',
      primaryLabel: 'OK',
      onPrimary: () => Navigator.of(context).pop(),
      analyticsVariant: 'listen_first',
      analyticsSourceScreen: contentType,
    );
    onDismiss();
  }
}
