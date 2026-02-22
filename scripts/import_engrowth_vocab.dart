/// Engrowthアプリ英単語データ（本番用CSV）を words_master_1000.csv 形式に変換
///
/// 使い方:
///   dart run scripts/import_engrowth_vocab.dart
///
/// 入力: Engrowthアプリ英単語データ - 本番用 (1).csv（プロジェクトルート）
/// 出力: assets/csv/words_master_1000.csv

import 'dart:io';
import 'package:csv/csv.dart';

const String sourcePath = 'Engrowthアプリ英単語データ - 本番用 (1).csv';
const String destPath = 'assets/csv/words_master_1000.csv';

void main() async {
  final file = File(sourcePath);
  if (!await file.exists()) {
    print('ERROR: $sourcePath not found (place it in project root)');
    exit(1);
  }

  final content = await file.readAsString();
  final rows = const CsvToListConverter().convert(content);

  if (rows.isEmpty || rows.length < 2) {
    print('ERROR: CSV is empty or has no data rows');
    exit(1);
  }

  final outRows = <List<dynamic>>[
    ['word', 'meaning', 'part_of_speech'],
  ];

  for (final row in rows.skip(1)) {
    if (row.length >= 4) {
      final word = row[1].toString().trim();
      final meaning = row[2].toString().trim();
      final pos = row[3].toString().trim();
      if (word.isNotEmpty) {
        outRows.add([word, meaning, pos]);
      }
    }
  }

  final csvContent = const ListToCsvConverter().convert(outRows);
  await File(destPath).writeAsString(csvContent);

  print('OK: ${outRows.length - 1} words written to $destPath');
}
