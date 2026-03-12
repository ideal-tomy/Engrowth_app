import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pattern_sprint_category.dart';
import '../services/pattern_sprint_service.dart';
import '../providers/pattern_sprint_provider.dart';
import '../theme/engrowth_theme.dart';
import 'common/animated_backdrop.dart';

/// パターンスプリント: 「どのパターンスクリプトでトレーニングしますか？」を表示し、
/// 2ステップで選択→即セッション開始するためのダイアログ。
/// 戻り値: 選択された prefix または null（キャンセル時）
class PatternSprintSelectionDialog extends ConsumerStatefulWidget {
  const PatternSprintSelectionDialog({super.key});

  @override
  ConsumerState<PatternSprintSelectionDialog> createState() =>
      _PatternSprintSelectionDialogState();
}

class _PatternSprintSelectionDialogState
    extends ConsumerState<PatternSprintSelectionDialog> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final maxH = height * EngrowthPopupTokens.largeHeightFraction;

    final categories = ref.watch(patternCategoriesProvider);
    final byCategory = ref.watch(patternByCategoryProvider);

    return AnimatedBackdrop(
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: maxH,
              ),
              child: Material(
                borderRadius: BorderRadius.circular(20),
                color: colorScheme.surface,
                child: AnimatedSwitcher(
                  duration: EngrowthPopupTokens.slideExitDuration,
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _step == 0
                      ? _buildStep0(context, colorScheme, textTheme, maxH)
                      : _buildStep1(
                          context,
                          colorScheme,
                          textTheme,
                          categories,
                          byCategory,
                          maxH,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep0(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    double maxH,
  ) {
    return Padding(
      key: const ValueKey<int>(0),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'どのパターンスクリプトでトレーニングしますか？',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() => _step = 1);
            },
            child: const Text('選択する'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    List<PatternSprintCategory> categories,
    Map<String, List<PatternDefinition>> byCategory,
    double maxH,
  ) {
    final items = <_SelectionItem>[];
    for (final cat in categories) {
      final patterns = byCategory[cat.id] ?? [];
      if (patterns.isEmpty) continue;
      final first = patterns.first;
      items.add(_SelectionItem(
        categoryName: cat.displayName,
        patternDisplayName: first.displayName,
        prefix: first.prefix,
      ));
    }

    return Padding(
      key: const ValueKey<int>(1),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'パターンを選択',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.play_circle_outline,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                  title: Text(
                    '${item.categoryName} — ${item.patternDisplayName}',
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop(item.prefix);
                  },
                ),
              )),
        ],
      ),
    );
  }
}

class _SelectionItem {
  final String categoryName;
  final String patternDisplayName;
  final String prefix;

  _SelectionItem({
    required this.categoryName,
    required this.patternDisplayName,
    required this.prefix,
  });
}
