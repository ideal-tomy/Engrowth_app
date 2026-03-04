import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/feedback_provider.dart';

/// B05: 共通CTAコンポーネント
/// primary / secondary の色・サイズ・タップフィードバックを統一
/// Phase A: 触覚は FeedbackService 経由で統一
enum EngrowthCtaVariant { primary, secondary }

class EngrowthPrimaryButton extends ConsumerWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;

  const EngrowthPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedback = ref.read(feedbackServiceProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.onPrimary,
            ),
          )
        : (icon != null
            ? FilledButton.icon(
                onPressed: onPressed == null
                    ? null
                    : () {
                        feedback.selection(trigger: 'cta_primary_selection');
                        onPressed!();
                      },
                icon: Icon(icon, size: 22),
                label: Text(label),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                  disabledForegroundColor: colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            : FilledButton(
                onPressed: onPressed == null
                    ? null
                    : () {
                        feedback.selection(trigger: 'cta_primary_selection');
                        onPressed!();
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                  disabledForegroundColor: colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(label),
              ));

    if (expanded) {
      return SizedBox(width: double.infinity, child: child);
    }
    return child;
  }
}

class EngrowthSecondaryButton extends ConsumerWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  const EngrowthSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedback = ref.read(feedbackServiceProvider);
    final child = OutlinedButton(
      onPressed: onPressed == null
          ? null
          : () {
              feedback.selection(trigger: 'cta_secondary_selection');
              onPressed!();
            },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(label),
    );

    if (expanded) {
      return SizedBox(width: double.infinity, child: child);
    }
    return child;
  }
}
