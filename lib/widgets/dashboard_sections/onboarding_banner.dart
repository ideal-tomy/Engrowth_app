import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../theme/engrowth_theme.dart';

/// 初回体験未完了時に表示するバナー
class OnboardingBanner extends ConsumerWidget {
  const OnboardingBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedAsync = ref.watch(onboardingCompletedProvider);

    return completedAsync.when(
      data: (completed) {
        if (completed) return const SizedBox.shrink();
        return _OnboardingBannerContent(
          onTap: () {
            HapticFeedback.selectionClick();
            ref.read(analyticsServiceProvider).logDailyReportCardShown(status: 'onboarding_prompt');
            context.push('/onboarding');
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _OnboardingBannerContent extends StatelessWidget {
  final VoidCallback onTap;

  const _OnboardingBannerContent({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 40,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '初回体験をはじめる',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '30秒会話・録音・提出の流れを体験',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
