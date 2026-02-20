import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/word_provider.dart';

/// 頭文字 A–Z のチップ（タップでその頭文字のセクションにスクロール）。常に画面上部に表示。
class FilterChips extends ConsumerWidget {
  final void Function(String letter)? onLetterTap;

  const FilterChips({super.key, this.onLetterTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(wordsGroupedByLetterProvider);

    return grouped.when(
      data: (map) {
        final letters = map.keys.toList()..sort();
        if (letters.isEmpty) return const SizedBox.shrink();

        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SizedBox(
            height: 40,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '頭文字:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  ...letters.map((char) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(
                          char.toUpperCase(),
                          style: const TextStyle(fontSize: 12),
                        ),
                        onSelected: (_) => onLetterTap?.call(char),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 40),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
