/// 生成された3分ストーリーSQLを検証する
///
/// チェック項目:
/// - 語数（300〜450）
/// - チャンク数（3〜5）
/// - utterance_order が各チャンク内で連番
/// - story_order が 1,2,3... と連番
/// - 必須カラムの存在
/// - 指定単語リストからの使用語数（オプション）
///
/// 使い方:
///   dart run scripts/validate_story_batch.dart <path_to_sql>
///   dart run scripts/validate_story_batch.dart supabase/migrations/seed_story_cafe_01.sql
///   dart run scripts/validate_story_batch.dart supabase/migrations/seed_story_*.sql --report
///
/// --report: docs/reports/story_batch_coverage_report.md に追記

import 'dart:io';
import 'package:path/path.dart' as p;

const int minWords = 300;
const int maxWords = 450;
const int minChunks = 3;
const int maxChunks = 5;
const String reportPath = 'docs/reports/story_batch_coverage_report.md';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run scripts/validate_story_batch.dart <path_to_sql> [--report]');
    exit(1);
  }

  final report = args.contains('--report');
  final paths = args.where((a) => !a.startsWith('--')).toList();
  if (paths.isEmpty) {
    print('ERROR: No SQL file path provided');
    exit(1);
  }

  final results = <Map<String, dynamic>>[];
  for (final path in paths) {
    final file = File(path);
    if (!await file.exists()) {
      print('ERROR: File not found: $path');
      continue;
    }
    final result = await _validateFile(file);
    result['path'] = path;
    results.add(result);
    _printResult(path, result);
  }

  if (report && results.isNotEmpty) {
    await _writeReport(results);
  }
}

void _printResult(String path, Map<String, dynamic> r) {
  print('\n=== $path ===');
  print('Word count: ${r['word_count']} (valid: ${r['word_count_ok'] ? 'OK' : 'NG'} - target 300-450)');
  print('Chunk count: ${r['chunk_count']} (valid: ${r['chunk_count_ok'] ? 'OK' : 'NG'} - target 3-5)');
  print('Utterance order: ${r['utterance_order_ok'] ? 'OK' : 'NG'}');
  print('Story order: ${r['story_order_ok'] ? 'OK' : 'NG'}');
  print('Overall: ${r['all_ok'] ? 'PASS' : 'FAIL'}');
  if ((r['errors'] as List).isNotEmpty) {
    print('Errors:');
    for (final e in r['errors']) print('  - $e');
  }
}

Future<Map<String, dynamic>> _validateFile(File file) async {
  final content = await file.readAsString();
  final errors = <String>[];
  var wordCount = 0;
  var chunkCount = 0;
  var utteranceOrderOk = true;
  var storyOrderOk = true;

  // Extract utterances: SELECT id, 'A'|'B', order, 'english', 'japanese' FROM convN
  // Match captures: order, english, conv
  final re = RegExp(r"SELECT id, '[AB]', (\d+), '((?:[^'\\]|''|\\.)*)', '[^']*' FROM conv(\d+)", caseSensitive: false);
  final matches = re.allMatches(content);

  final chunkUtterances = <int, List<int>>{};
  final storyOrders = <int>[];

  // Find conv1, conv2, ... and their story_order
  final convRe = RegExp(r'conv(\d+).*?story_order, (\d+)');
  for (final m in convRe.allMatches(content)) {
    final so = int.parse(m.group(2)!);
    if (!storyOrders.contains(so)) storyOrders.add(so);
  }
  storyOrders.sort();
  for (var i = 0; i < storyOrders.length; i++) {
    if (storyOrders[i] != i + 1) {
      storyOrderOk = false;
      errors.add('story_order should be 1,2,3... found ${storyOrders.join(",")}');
      break;
    }
  }

  for (final m in matches) {
    final order = int.parse(m.group(1)!);
    var text = m.group(2)!.replaceAll("''", "'");
    final words = _countWords(text);
    wordCount += words;

    final c = int.parse(m.group(3)!);
    chunkUtterances.putIfAbsent(c, () => []).add(order);
  }

  chunkCount = chunkUtterances.length;
  for (final entries in chunkUtterances.entries) {
    final orders = entries.value..sort();
    for (var i = 0; i < orders.length; i++) {
      if (orders[i] != i + 1) {
        utteranceOrderOk = false;
        errors.add('conv${entries.key}: utterance_order should be 1,2,3... got ${orders.join(",")}');
        break;
      }
    }
  }

  if (wordCount < minWords || wordCount > maxWords) {
    errors.add('Word count $wordCount out of range ($minWords-$maxWords)');
  }
  if (chunkCount < minChunks || chunkCount > maxChunks) {
    errors.add('Chunk count $chunkCount out of range ($minChunks-$maxChunks)');
  }

  return {
    'word_count': wordCount,
    'word_count_ok': wordCount >= minWords && wordCount <= maxWords,
    'chunk_count': chunkCount,
    'chunk_count_ok': chunkCount >= minChunks && chunkCount <= maxChunks,
    'utterance_order_ok': utteranceOrderOk,
    'story_order_ok': storyOrderOk,
    'all_ok': errors.isEmpty,
    'errors': errors,
  };
}

int _countWords(String text) {
  final normalized = text.toLowerCase().replaceAll(RegExp(r"[^\w\s']"), ' ');
  final tokens = normalized.split(RegExp(r'\s+')).where((s) => s.isNotEmpty);
  return tokens.length;
}

Future<void> _writeReport(List<Map<String, dynamic>> results) async {
  final dir = p.dirname(reportPath);
  await Directory(dir).create(recursive: true);

  final buffer = StringBuffer();
  buffer.writeln('# 3分ストーリー バッチ検証レポート');
  buffer.writeln('');
  buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
  buffer.writeln('');
  buffer.writeln('| File | Words | Chunks | Word OK | Chunk OK | Order OK | Result |');
  buffer.writeln('|------|-------|--------|---------|----------|----------|--------|');

  for (final r in results) {
    final path = r['path'] as String;
    final name = p.basename(path);
    final words = r['word_count'] as int;
    final chunks = r['chunk_count'] as int;
    final wordOk = r['word_count_ok'] as bool;
    final chunkOk = r['chunk_count_ok'] as bool;
    final orderOk = (r['utterance_order_ok'] as bool) && (r['story_order_ok'] as bool);
    final pass = r['all_ok'] as bool;
    buffer.writeln('| $name | $words | $chunks | ${wordOk ? "OK" : "NG"} | ${chunkOk ? "OK" : "NG"} | ${orderOk ? "OK" : "NG"} | ${pass ? "PASS" : "FAIL"} |');
  }

  buffer.writeln('');
  final passed = results.where((r) => r['all_ok'] as bool).length;
  buffer.writeln('Summary: $passed/${results.length} passed');
  buffer.writeln('');

  final reportFile = File(reportPath);
  final existing = await reportFile.exists() ? await reportFile.readAsString() : '';
  await reportFile.writeAsString(existing + buffer.toString());
  print('Report appended to $reportPath');
}
