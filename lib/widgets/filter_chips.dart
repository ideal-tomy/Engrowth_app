import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/word_provider.dart';

class FilterChips extends ConsumerWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partOfSpeeches = ref.watch(partOfSpeechListProvider);
    final groups = ref.watch(wordGroupsProvider);
    final selectedPartOfSpeech = ref.watch(selectedPartOfSpeechProvider);
    final selectedGroup = ref.watch(selectedGroupProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 品詞フィルタ
          partOfSpeeches.when(
            data: (list) => Row(
              children: [
                const Text(
                  '品詞:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                ...list.map((pos) {
                  final isSelected = selectedPartOfSpeech == pos;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(pos),
                      selected: isSelected,
                      onSelected: (selected) {
                        ref.read(selectedPartOfSpeechProvider.notifier).state =
                            selected ? pos : null;
                      },
                    ),
                  );
                }),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 16),
          // グループフィルタ
          groups.when(
            data: (list) => Row(
              children: [
                const Text(
                  'グループ:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                ...list.map((group) {
                  final isSelected = selectedGroup == group;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(group),
                      selected: isSelected,
                      onSelected: (selected) {
                        ref.read(selectedGroupProvider.notifier).state =
                            selected ? group : null;
                      },
                    ),
                  );
                }),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
