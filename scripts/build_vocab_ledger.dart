/// 1000単語マスターから使用台帳（words_usage_ledger.csv）を生成
///
/// 使い方:
///   dart run scripts/build_vocab_ledger.dart
///   dart run scripts/build_vocab_ledger.dart "Engrowthアプリ英単語データ - 本番用 (1).csv"
///
/// 入力:
///   - 引数指定時: Engrowth形式CSV（番号,単語,意味,品詞,Group）
///   - 未指定時: assets/csv/words_master_1000.csv（word,meaning,part_of_speech）
/// 出力: assets/csv/words_usage_ledger.csv
///   - word_id: 1-based
///   - is_core: 1 = 上位200語（重要語・再出現許容）、0 = それ以外
///   - used_count: 使用回数（初期0）
///   - used_in_story_ids: 使用したストーリーID（カンマ区切り、初期空）

import 'dart:io';
import 'package:csv/csv.dart';

const String defaultMasterPath = 'assets/csv/words_master_1000.csv';
const String ledgerPath = 'assets/csv/words_usage_ledger.csv';
const int coreWordCount = 200;

void main(List<String> args) async {
  final customPath = args.isNotEmpty ? args[0] : null;
  final sourcePath = customPath ?? defaultMasterPath;

  final file = File(sourcePath);
  if (!await file.exists()) {
    print('ERROR: $sourcePath not found');
    exit(1);
  }

  final content = await file.readAsString();
  final rows = const CsvToListConverter().convert(content);

  if (rows.isEmpty) {
    print('ERROR: CSV is empty');
    exit(1);
  }

  final header = rows[0].map((c) => c.toString().toLowerCase()).join(',');
  final isEngrowthFormat = header.contains('単語') || header.contains('単语');

  List<List<dynamic>> dataRows;
  if (isEngrowthFormat) {
    dataRows = rows
        .skip(1)
        .where((r) => r.length >= 4 && r[1].toString().trim().isNotEmpty)
        .toList();
  } else {
    dataRows = rows
        .skip(1)
        .where((r) => r.isNotEmpty && r.any((c) => c.toString().trim().isNotEmpty))
        .toList();
  }

  if (dataRows.isEmpty) {
    print('ERROR: No data rows');
    exit(1);
  }

  final ledgerRows = <List<dynamic>>[
    ['word_id', 'word', 'meaning', 'part_of_speech', 'is_core', 'used_count', 'used_in_story_ids'],
  ];

  for (var i = 0; i < dataRows.length; i++) {
    final row = dataRows[i];
    final wordId = i + 1;
    String word, meaning, pos;
    if (isEngrowthFormat) {
      word = row.length > 1 ? row[1].toString().trim() : '';
      meaning = row.length > 2 ? row[2].toString().trim() : '';
      pos = row.length > 3 ? row[3].toString().trim() : '';
    } else {
      word = row.length > 0 ? row[0].toString().trim() : '';
      meaning = row.length > 1 ? row[1].toString().trim() : '';
      pos = row.length > 2 ? row[2].toString().trim() : '';
    }
    final isCore = wordId <= coreWordCount ? 1 : 0;
    ledgerRows.add([wordId, word, meaning, pos, isCore, 0, '']);
  }

  final csvContent = const ListToCsvConverter().convert(ledgerRows);
  await File(ledgerPath).writeAsString(csvContent);

  final coreCount = dataRows.length < coreWordCount ? dataRows.length : coreWordCount;
  final nonCoreCount = dataRows.length - coreCount;
  print('OK: $ledgerPath created (from ${isEngrowthFormat ? "Engrowth format" : "words_master"})');
  print('   Total words: ${dataRows.length}');
  print('   Core (top 200): $coreCount');
  print('   Non-core: $nonCoreCount');
}
