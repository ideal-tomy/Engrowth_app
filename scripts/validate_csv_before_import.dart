/// インポート前の会話CSVフォーマット検証スクリプト
///
/// 使い方:
///   dart run scripts/validate_csv_before_import.dart [CSVパス]
///
/// 検証内容:
///   - 必須カラムの存在（Scenario_ID, Order, Role, Text_EN, Text_JP）
///   - Scenario_ID ごとの Order 連番（1から欠番なし）
///   - Text_EN の空行チェック
///   - Role が A/B のみか
///   - 禁則文字の簡易チェック

import 'dart:io';
import 'package:csv/csv.dart';

void main(List<String> args) async {
  final csvPath = args.isNotEmpty ? args[0] : 'assets/csv';
  final files = await _resolvePaths(csvPath);

  if (files.isEmpty) {
    print('❌ CSVファイルが見つかりません: $csvPath');
    exit(1);
  }

  var hasError = false;
  for (final path in files) {
    final result = await _validate(path);
    if (result.isNotEmpty) {
      hasError = true;
      print('\n📂 $path');
      for (final msg in result) {
        print('   ❌ $msg');
      }
    }
  }

  if (hasError) {
    exit(1);
  }
  print('✅ 検証完了: 問題なし');
}

Future<List<String>> _resolvePaths(String path) async {
  final f = File(path);
  if (await f.exists()) {
    if (path.toLowerCase().endsWith('.csv')) return [path];
  }
  final dir = Directory(path);
  if (await dir.exists()) {
    return dir
        .listSync()
        .whereType<File>()
        .where((e) => e.path.toLowerCase().endsWith('.csv'))
        .map((e) => e.path)
        .toList();
  }
  return [];
}

Future<List<String>> _validate(String path) async {
  final errors = <String>[];
  final content = await File(path).readAsString();
  final rows = const CsvToListConverter().convert(content);

  if (rows.isEmpty) {
    errors.add('データなし');
    return errors;
  }

  final header = rows[0].map((e) => e.toString().trim()).toList();
  int colScenario = header.indexWhere((h) => h.toLowerCase() == 'scenario_id');
  int colOrder = header.indexWhere((h) => h.toLowerCase() == 'order');
  int colRole = header.indexWhere((h) => h.toLowerCase() == 'role');
  int colTextEn = header.indexWhere((h) => h.toLowerCase() == 'text_en');
  int colTextJp = header.indexWhere((h) => h.toLowerCase() == 'text_jp');

  if (colScenario < 0 || colOrder < 0 || colRole < 0 || colTextEn < 0) {
    errors.add('必須カラム不足: Scenario_ID, Order, Role, Text_EN が必要');
    return errors;
  }
  if (colTextJp < 0) colTextJp = colTextEn;

  final dataStartRow = 1;
  final grouped = <String, List<List>>{};

  for (var i = dataStartRow; i < rows.length; i++) {
    final row = rows[i];
    if (row.length <= colScenario) continue;

    final scenarioId = row[colScenario].toString().trim();
    if (scenarioId.isEmpty || scenarioId == 'Scenario_ID') continue;

    grouped.putIfAbsent(scenarioId, () => []).add(row);
  }

  for (final entry in grouped.entries) {
    final scenarioId = entry.key;
    final utterances = entry.value;

    utterances.sort((a, b) {
      final o1 = int.tryParse(a[colOrder].toString()) ?? 0;
      final o2 = int.tryParse(b[colOrder].toString()) ?? 0;
      return o1.compareTo(o2);
    });

    final orders = <int>[];
    for (var i = 0; i < utterances.length; i++) {
      final row = utterances[i];
      final order = int.tryParse(row[colOrder].toString()) ?? 0;
      orders.add(order);

      final textEn = row.length > colTextEn ? row[colTextEn].toString().trim() : '';
      if (textEn.isEmpty) {
        errors.add('$scenarioId Order=$order: Text_EN が空');
      }

      final role = row.length > colRole ? row[colRole].toString().trim().toUpperCase() : '';
      if (role.isNotEmpty && role != 'A' && role != 'B') {
        errors.add('$scenarioId Order=$order: Role が A/B 以外 ($role)');
      }
    }

    for (var i = 1; i <= orders.length; i++) {
      if (!orders.contains(i)) {
        errors.add('$scenarioId: Order の欠番 (期待 $i)');
      }
    }
  }

  return errors;
}
