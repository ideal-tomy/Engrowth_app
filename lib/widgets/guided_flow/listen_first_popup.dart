import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/engrowth_popup.dart';

/// Speak風ガイドフロー: 「まずは音声を最後まで聴いてください」ポップアップ
/// EngrowthPopup テンプレートを用いて実装する。
class ListenFirstPopup {
  const ListenFirstPopup._();

  /// モーダルで表示。OK・外側タップのいずれでも閉じられ、閉じたあと onDismiss を1回呼ぶ。
  /// [forNextStory] true のときは「学習を始める」ボタン表示（タップ＝閉じる＋音声開始のトリガーに）。
  static Future<void> show(
    BuildContext context, {
    String message = 'まずは音声を最後まで聴いてください',
    String? primaryLabel,
    bool forNextStory = false,
    required VoidCallback onDismiss,
    String? contentType,
    String? contentId,
    VoidCallback? onShown,
  }) async {
    HapticFeedback.selectionClick();
    WidgetsBinding.instance.addPostFrameCallback((_) => onShown?.call());

    final effectiveMessage = forNextStory ? '次の学習を始めましょう' : message;
    final effectiveLabel = primaryLabel ?? (forNextStory ? '学習を始める' : 'OK');

    await EngrowthPopup.show<void>(
      context,
      barrierDismissible: true,
      hero: const Icon(Icons.headphones, size: 40),
      title: effectiveMessage,
      subtitle: 'タップして閉じる',
      primaryLabel: effectiveLabel,
      onPrimary: null,
      analyticsVariant: 'listen_first',
      analyticsSourceScreen: contentType,
    );
    onDismiss();
  }
}
