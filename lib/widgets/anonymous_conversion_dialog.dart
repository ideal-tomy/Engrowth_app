import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/analytics_provider.dart';
import '../providers/anonymous_conversion_provider.dart';
import '../theme/engrowth_theme.dart';

/// 匿名ユーザー向け：アカウント作成促進ダイアログ
/// 学習完了3回ごとに表示。CTA: Google / メール / 後で
class AnonymousConversionDialog extends ConsumerWidget {
  const AnonymousConversionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: EngrowthColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: EngrowthColors.silverBorder),
      ),
      title: const Text('進捗を長期保存しませんか？'),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'アカウント作成で、すごろくの進捗や学習記録を端末を替えても引き継げます。'
              '翌日以降も続きから安心して学習できます。',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _onLater(context, ref),
          child: const Text('後で'),
        ),
        FilledButton.icon(
          onPressed: () => _onEmail(context, ref),
          icon: const Icon(Icons.email_outlined, size: 18),
          label: const Text('メールで作成'),
        ),
        FilledButton.icon(
          onPressed: () => _onGoogle(context, ref),
          icon: const Icon(Icons.g_mobiledata, size: 22),
          label: const Text('Googleで作成'),
        ),
      ],
    );
  }

  void _onLater(BuildContext context, WidgetRef ref) {
    HapticFeedback.selectionClick();
    ref.read(anonymousConversionProvider.notifier).markDismissed();
    ref.read(analyticsServiceProvider).logAnonPromptDismissed();
    Navigator.of(context).pop();
  }

  void _onEmail(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    ref.read(analyticsServiceProvider).logAnonPromptCtaEmail();
    Navigator.of(context).pop();
    context.push('/account');
  }

  void _onGoogle(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    ref.read(analyticsServiceProvider).logAnonPromptCtaGoogle();
    Navigator.of(context).pop();
    context.push('/account?provider=google');
  }
}
