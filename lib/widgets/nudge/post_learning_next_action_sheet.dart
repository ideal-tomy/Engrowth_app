import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/next_action_suggestion.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/next_action_provider.dart';

/// 学習完了後の次行動提案ボトムシート
/// 主CTA: 次の学習、副CTA: 進捗を見る
class PostLearningNextActionSheet extends ConsumerWidget {
  final String track;
  final BuildContext parentContext;

  const PostLearningNextActionSheet({
    super.key,
    required this.track,
    required this.parentContext,
  });

  static Future<void> show(
    BuildContext context, {
    required String track,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PostLearningNextActionSheet(
        track: track,
        parentContext: context,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final suggestionsAsync = ref.watch(nextActionSuggestionsProvider);
    final progressRoute =
        track == 'scenario' ? '/progress/scenario-board' : '/progress/story-board';
    final label = track == 'scenario' ? 'シナリオ' : '3分英会話';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.celebration, size: 40, color: colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            '$labelの進捗が1マス進みました',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          suggestionsAsync.when(
            data: (suggestions) {
              final first = suggestions.isNotEmpty ? suggestions.first : null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (first != null) ...[
                    _PrimaryCta(
                      suggestion: first,
                      onTap: () => _onNextLearningTap(context, ref, first),
                    ),
                    const SizedBox(height: 12),
                  ],
                  OutlinedButton.icon(
                    onPressed: () => _onProgressTap(context, ref, progressRoute),
                    icon: const Icon(Icons.trending_up, size: 20),
                    label: const Text('進捗を見る'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurface,
                      side: BorderSide(color: colorScheme.outlineVariant),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      ref.read(analyticsServiceProvider).logLearningHandoffAccepted(
                            choice: 'dismiss',
                            track: track,
                          );
                      Navigator.of(context).pop();
                    },
                    child: Text('閉じる', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  ),
                ],
              );
            },
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )),
            error: (_, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: () => _onProgressTap(context, ref, progressRoute),
                  icon: const Icon(Icons.trending_up, size: 20),
                  label: const Text('進捗を見る'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('閉じる', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onNextLearningTap(
    BuildContext context,
    WidgetRef ref,
    NextActionSuggestion suggestion,
  ) {
    HapticFeedback.selectionClick();
    ref.read(analyticsServiceProvider).logLearningHandoffAccepted(
          choice: 'next_learning',
          track: track,
          targetRoute: suggestion.route,
        );
    if (context.mounted) Navigator.of(context).pop();
    final ctx = parentContext;
    if (ctx.mounted) ctx.push(suggestion.route);
  }

  void _onProgressTap(
    BuildContext context,
    WidgetRef ref,
    String route,
  ) {
    HapticFeedback.selectionClick();
    ref.read(analyticsServiceProvider).logLearningHandoffAccepted(
          choice: 'progress_view',
          track: track,
          targetRoute: route,
        );
    if (context.mounted) Navigator.of(context).pop();
    final ctx = parentContext;
    if (ctx.mounted) ctx.push(route, extra: {'scrollToNext': true});
  }
}

class _PrimaryCta extends StatelessWidget {
  final NextActionSuggestion suggestion;
  final VoidCallback onTap;

  const _PrimaryCta({required this.suggestion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(suggestion.icon, size: 22, color: colorScheme.onPrimary),
      label: Text(suggestion.title),
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}
