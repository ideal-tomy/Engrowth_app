import 'package:flutter/material.dart';

/// 学習画面の終了確認ダイアログ
/// StudyScreen / ScenarioStudyScreen などで共通利用
void showExitConfirmationDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('学習を終了しますか？'),
      content: const Text('途中で終了しても、進捗は保存されます。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            onConfirm();
          },
          child: const Text('終了'),
        ),
      ],
    ),
  );
}
