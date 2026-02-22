/// ストーリー生成用の単語配分を行う
///
/// ルール:
/// - 1ストーリーあたり10〜15語を割り当て
/// - 非重要語（word_id > 200）を優先、未使用語を最優先
/// - 非重要語の2回目以降の使用は低優先
/// - 重要語（top 200）は自然な会話のため必要に応じて再使用可
///
/// 使い方:
///   dart run scripts/word_allocator.dart <theme_slug> <story_index>
///   dart run scripts/word_allocator.dart <theme_slug> <story_index> --update <story_id>
///
/// 例:
///   dart run scripts/word_allocator.dart greeting_biz 1
///   dart run scripts/word_allocator.dart greeting_biz 1 --update greeting_biz_01

import 'dart:io';
import 'package:csv/csv.dart';

const String ledgerPath = 'assets/csv/words_usage_ledger.csv';
const int targetWordsPerStory = 12; // 10-15 の中央値
const int coreWordCount = 200;

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run scripts/word_allocator.dart <theme_slug> <story_index> [--update <story_id>]');
    exit(1);
  }

  final themeSlug = args[0];
  final storyIndex = int.tryParse(args.length > 1 ? args[1] : '1') ?? 1;
  var updateStoryId = '';
  if (args.length >= 4 && args[2] == '--update') {
    updateStoryId = args[3];
  }

  final file = File(ledgerPath);
  if (!await file.exists()) {
    print('ERROR: Run build_vocab_ledger.dart first');
    exit(1);
  }

  final content = await file.readAsString();
  final rows = const CsvToListConverter().convert(content);
  if (rows.length < 2) {
    print('ERROR: Ledger empty or no data');
    exit(1);
  }

  final header = rows[0];
  final dataRows = rows.skip(1).toList();

  // Parse ledger: word_id, word, meaning, part_of_speech, is_core, used_count, used_in_story_ids
  final ledger = <Map<String, dynamic>>[];
  for (final row in dataRows) {
    if (row.length < 7) continue;
    ledger.add({
      'word_id': int.tryParse(row[0].toString()) ?? 0,
      'word': row[1].toString().trim(),
      'meaning': row[2].toString().trim(),
      'part_of_speech': row[3].toString().trim(),
      'is_core': int.tryParse(row[4].toString()) ?? 0,
      'used_count': int.tryParse(row[5].toString()) ?? 0,
      'used_in_story_ids': row[6].toString().trim(),
    });
  }

  // Allocate: prefer unused non-core, then low-use non-core, then core
  final nonCore = ledger.where((e) => e['is_core'] == 0).toList();
  final core = ledger.where((e) => e['is_core'] == 1).toList();

  int usedCount(Map<String, dynamic> e) => e['used_count'] as int;

  nonCore.sort((a, b) {
    final ca = usedCount(a);
    final cb = usedCount(b);
    if (ca != cb) return ca.compareTo(cb);
    return (a['word_id'] as int).compareTo(b['word_id'] as int);
  });

  final allocated = <Map<String, dynamic>>[];
  var need = targetWordsPerStory;

  // First: unused non-core (used_count == 0)
  for (final e in nonCore) {
    if (need <= 0) break;
    if (usedCount(e) == 0) {
      allocated.add(e);
      need--;
    }
  }

  // Second: non-core with used_count == 1 (avoid over-reuse)
  if (need > 0) {
    for (final e in nonCore) {
      if (need <= 0) break;
      if (usedCount(e) == 1 && !allocated.any((a) => a['word_id'] == e['word_id'])) {
        allocated.add(e);
        need--;
      }
    }
  }

  // Third: core words (allow reuse)
  if (need > 0) {
    for (var i = 0; i < core.length && need > 0; i++) {
      allocated.add(core[i]);
      need--;
    }
  }

  // Output allocated words for prompt
  final words = allocated.map((e) => e['word'] as String).toList();
  print('ALLOCATED_WORDS=${words.join(',')}');
  print('WORD_RANGE=${allocated.isEmpty ? '' : '${allocated.first['word_id']}-${allocated.last['word_id']}'}');
  for (final w in words) {
    print(w);
  }

  if (updateStoryId.isNotEmpty) {
    for (final e in allocated) {
      e['used_count'] = (e['used_count'] as int) + 1;
      final ids = (e['used_in_story_ids'] as String).split(',').where((s) => s.isNotEmpty).toList();
      ids.add(updateStoryId);
      e['used_in_story_ids'] = ids.join(',');
    }
    // Write back ledger
    final outRows = [
      header,
      ...ledger.map((e) => [
            e['word_id'],
            e['word'],
            e['meaning'],
            e['part_of_speech'],
            e['is_core'],
            e['used_count'],
            e['used_in_story_ids'],
          ]),
    ];
    final csvContent = const ListToCsvConverter().convert(outRows);
    await File(ledgerPath).writeAsString(csvContent);
    print('UPDATED_LEDGER=true');
  }
}
