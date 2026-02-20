import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/word_provider.dart';

class SortMenu extends ConsumerWidget {
  const SortMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortOrder = ref.watch(wordSortOrderProvider);

    return PopupMenuButton<WordSortOrder>(
      tooltip: 'ソート',
      onSelected: (value) {
        ref.read(wordSortOrderProvider.notifier).state = value;
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: WordSortOrder.alphabeticalAsc,
          child: Row(
            children: [
              Icon(Icons.sort_by_alpha, size: 20),
              SizedBox(width: 8),
              Text('アルファベット順 (A-Z)'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: WordSortOrder.alphabeticalDesc,
          child: Row(
            children: [
              Icon(Icons.sort_by_alpha, size: 20),
              SizedBox(width: 8),
              Text('アルファベット順 (Z-A)'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: WordSortOrder.dateAsc,
          child: Row(
            children: [
              Icon(Icons.access_time, size: 20),
              SizedBox(width: 8),
              Text('追加日順 (古い順)'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: WordSortOrder.dateDesc,
          child: Row(
            children: [
              Icon(Icons.access_time, size: 20),
              SizedBox(width: 8),
              Text('追加日順 (新着)'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort, size: 20),
            const SizedBox(width: 4),
            Text(_getSortLabel(sortOrder)),
          ],
        ),
      ),
    );
  }

  String _getSortLabel(WordSortOrder order) {
    switch (order) {
      case WordSortOrder.alphabeticalAsc:
        return 'A-Z';
      case WordSortOrder.alphabeticalDesc:
        return 'Z-A';
      case WordSortOrder.dateAsc:
        return '古い順';
      case WordSortOrder.dateDesc:
        return '新着';
      case WordSortOrder.studyCountAsc:
        return '学習回数↑';
      case WordSortOrder.studyCountDesc:
        return '学習回数↓';
    }
  }
}
