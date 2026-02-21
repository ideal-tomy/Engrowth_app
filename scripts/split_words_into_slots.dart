/// 1000単語マスターリストを50語単位のスロットCSVに分割するスクリプト
///
/// 使い方（プロジェクトルートで）:
///   dart run scripts/split_words_into_slots.dart
///
/// 入力: assets/csv/words_master_1000.csv
/// 出力: assets/csv/words_slot_001_050.csv, words_slot_051_100.csv, ...

import 'dart:io';
import 'package:csv/csv.dart';

const int slotSize = 50;
const String masterPath = 'assets/csv/words_master_1000.csv';

void main() async {
  final file = File(masterPath);
  if (!await file.exists()) {
    print('❌ $masterPath が見つかりません');
    exit(1);
  }

  final content = await file.readAsString();
  final rows = const CsvToListConverter().convert(content);

  if (rows.isEmpty) {
    print('❌ CSVが空です');
    exit(1);
  }

  final header = rows[0];
  final dataRows = rows.skip(1).where((r) => r.isNotEmpty && r.any((c) => c.toString().trim().isNotEmpty)).toList();

  if (dataRows.isEmpty) {
    print('❌ データ行がありません');
    exit(1);
  }

  final outputDir = file.parent;
  var slotStart = 1;
  var fileCount = 0;

  while (slotStart <= dataRows.length) {
    final slotEnd = (slotStart + slotSize - 1).clamp(1, dataRows.length);
    final slotRows = dataRows.skip(slotStart - 1).take(slotSize).toList();

    final slotFileName = 'words_slot_${slotStart.toString().padLeft(3, '0')}_${slotEnd.toString().padLeft(3, '0')}.csv';
    final slotPath = outputDir.path + Platform.pathSeparator + slotFileName;

    final csvContent = const ListToCsvConverter().convert([header, ...slotRows]);
    await File(slotPath).writeAsString(csvContent);

    print('✅ $slotFileName (${slotRows.length}語)');
    fileCount++;
    slotStart += slotSize;
  }

  print('\n📋 合計 $fileCount ファイルを生成しました');
}
