import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/analytics_provider.dart';
import '../widgets/result/unified_result_content.dart';

/// B06: 主要完了導線用のフルスクリーンリザルト画面
class UnifiedResultScreen extends ConsumerWidget {
  final String flow;
  final String title;
  final String? subtitle;
  final int? count;
  final String? countSuffix;
  final String? primaryRoute;
  final String primaryCtaLabel;
  final IconData? primaryCtaIcon;

  const UnifiedResultScreen({
    super.key,
    required this.flow,
    required this.title,
    this.subtitle,
    this.count,
    this.countSuffix,
    this.primaryRoute,
    this.primaryCtaLabel = 'もう1セット続ける',
    this.primaryCtaIcon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: UnifiedResultContent(
              title: title,
              subtitle: subtitle,
              count: count,
              countSuffix: countSuffix,
              useCard: true,
              onShown: () {
                ref.read(analyticsServiceProvider).logResultShown(
                      surface: 'screen',
                      flow: flow,
                    );
              },
              onPrimaryCta: () {
                HapticFeedback.selectionClick();
                ref.read(analyticsServiceProvider).logResultCtaTapped(
                      surface: 'screen',
                      flow: flow,
                      cta: 'primary',
                    );
                ref.read(analyticsServiceProvider).logNextTaskAccepted(
                      nextType: flow == 'study' ? 'study' : 'next',
                    );
                if (primaryRoute != null) {
                  context.push(primaryRoute!);
                } else {
                  context.push('/study');
                }
              },
              primaryCtaLabel: primaryCtaLabel,
              primaryCtaIcon: primaryCtaIcon ?? Icons.play_arrow,
              onSecondaryCta: () {
                HapticFeedback.selectionClick();
                ref.read(analyticsServiceProvider).logResultCtaTapped(
                      surface: 'screen',
                      flow: flow,
                      cta: 'home',
                    );
                context.go('/home');
              },
              secondaryCtaLabel: 'ホームへ',
            ),
          ),
        ),
      ),
    );
  }
}
