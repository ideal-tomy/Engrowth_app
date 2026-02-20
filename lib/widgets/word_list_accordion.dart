import 'package:flutter/material.dart';
import '../models/word.dart';
import 'word_tile.dart';

/// 頭文字ごとのアコーディオン（折りたたみ時は3枚表示、ヘッダー矢印タップで展開）
class WordListAccordion extends StatelessWidget {
  final Map<String, List<Word>> grouped;
  final Set<String> expandedLetters;
  final ValueChanged<String> onToggle;
  final ScrollController? scrollController;
  final void Function(Map<String, double>)? onLetterOffsets;

  const WordListAccordion({
    super.key,
    required this.grouped,
    required this.expandedLetters,
    required this.onToggle,
    this.scrollController,
    this.onLetterOffsets,
  });

  static const int _previewCount = 3;
  static const int _crossAxisCount = 3;
  static const double _headerHeight = 34;
  static const double _horizontalPadding = 12;
  static const double _verticalPadding = 6;
  static const double _crossAxisSpacing = 8;
  static const double _mainAxisSpacing = 6;
  static const double _childAspectRatio = 1.5;
  static const double _sectionBottom = 4;

  @override
  Widget build(BuildContext context) {
    final letters = grouped.keys.toList()..sort();
    if (letters.isEmpty) return const SizedBox.shrink();

    final width = MediaQuery.sizeOf(context).width - _horizontalPadding * 2;
    final cellWidth = (width - _crossAxisSpacing * (_crossAxisCount - 1)) / _crossAxisCount;
    final cellHeight = cellWidth / _childAspectRatio;
    final rowHeight = cellHeight + _mainAxisSpacing;

    _reportLetterOffsets(context, letters, rowHeight);

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding, vertical: _verticalPadding),
      itemCount: letters.length,
      itemBuilder: (context, index) {
        final letter = letters[index];
        final words = grouped[letter]!;
        final expanded = expandedLetters.contains(letter);
        final showCount = expanded ? words.length : _previewCount.clamp(0, words.length);
        final displayList = words.take(showCount).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // セクションヘッダー（矢印タップで展開/折りたたみ）
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onToggle(letter),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Row(
                    children: [
                      Text(
                        letter.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        ' (${words.length})',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                        size: 22,
                        color: Colors.grey[700],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _crossAxisCount,
                crossAxisSpacing: _crossAxisSpacing,
                mainAxisSpacing: _mainAxisSpacing,
                childAspectRatio: _childAspectRatio,
              ),
              itemCount: displayList.length,
              itemBuilder: (context, i) => WordTile(word: displayList[i]),
            ),
            const SizedBox(height: _sectionBottom),
          ],
        );
      },
    );
  }

  void _reportLetterOffsets(BuildContext context, List<String> letters, double rowHeight) {
    if (onLetterOffsets == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      double offset = _verticalPadding;
      final map = <String, double>{};
      for (final letter in letters) {
        map[letter] = offset;
        final words = grouped[letter]!;
        final expanded = expandedLetters.contains(letter);
        final showCount = expanded ? words.length : _previewCount.clamp(0, words.length);
        final rows = (showCount / _crossAxisCount).ceil();
        final gridHeight = rows * rowHeight;
        offset += _headerHeight + gridHeight + _sectionBottom;
      }
      onLetterOffsets!(map);
    });
  }
}
