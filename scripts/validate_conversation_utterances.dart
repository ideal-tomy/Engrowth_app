/// conversation_utterances の品質検証スクリプト
///
/// 使い方（プロジェクトルートで）:
///   dart run scripts/validate_conversation_utterances.dart [CSVパス]
///
/// CSVパス未指定時は、conversation_utterances_rows.csv をカレントディレクトリから検索します。
/// 出力: audit_report.csv（conversation_id, utterance_id, classification, pattern_matched, notes）

import 'dart:io';
import 'package:csv/csv.dart';

void main(List<String> args) async {
  final csvPath = args.isNotEmpty
      ? args[0]
      : await _findDefaultCsv();

  if (csvPath == null || !await File(csvPath).exists()) {
    print('❌ CSVファイルが見つかりません。パスを指定してください。');
    print('   例: dart run scripts/validate_conversation_utterances.dart path/to/conversation_utterances_rows.csv');
    exit(1);
  }

  print('📂 読み込み: $csvPath');
  final content = await File(csvPath).readAsString();
  final rows = const CsvToListConverter().convert(content);

  if (rows.isEmpty) {
    print('⚠ データなし');
    exit(0);
  }

  final header = rows[0].map((e) => e.toString().trim().toLowerCase()).toList();
  final colId = header.indexOf('id');
  final colConversationId = header.indexOf('conversation_id');
  final colEnglish = header.indexOf('english_text');

  if (colId < 0 || colConversationId < 0 || colEnglish < 0) {
    print('❌ 必要なカラムが見つかりません: id, conversation_id, english_text');
    exit(1);
  }

  final report = <List<String>>[];
  report.add(['conversation_id', 'utterance_id', 'classification', 'pattern_matched', 'notes']);

  var okCount = 0;
  var reviseCount = 0;
  var rewriteCount = 0;

  for (var i = 1; i < rows.length; i++) {
    final row = rows[i];
    if (row.length <= colEnglish) continue;

    final id = row[colId].toString().trim();
    final conversationId = row[colConversationId].toString().trim();
    final english = row[colEnglish].toString().trim();

    if (english.isEmpty) continue;

    final result = _classify(english);
    switch (result.classification) {
      case 'OK':
        okCount++;
        break;
      case 'REVISE':
        reviseCount++;
        break;
      case 'REWRITE':
        rewriteCount++;
        break;
    }

    report.add([
      conversationId,
      id,
      result.classification,
      result.patternJoined,
      result.notes,
    ]);
  }

  final outPath = 'audit_report.csv';
  await File(outPath).writeAsString(const ListToCsvConverter().convert(report));
  print('✅ 出力: $outPath');

  print('');
  print('📊 集計:');
  print('   OK:      $okCount');
  print('   要修正:  $reviseCount');
  print('   全面改稿: $rewriteCount');
}

({String classification, String patternJoined, String notes}) _classify(String en) {
  final patterns = <String>[];
  String classification = 'OK';
  String notes = '';

  // 全面改稿候補: 単語羅列
  if (RegExp(r'^(Treat|Discover|Production|Trip|Evening)(\.\s|\.)?$', caseSensitive: false).hasMatch(en)) {
    patterns.add('word_salad_single');
    classification = 'REWRITE';
    notes = '単語羅列';
  }
  if (RegExp(r'\b(Treat|Discover|Production|Trip|Evening)\.\s+(Treat|Discover|Production|Trip|Evening)\.', caseSensitive: false).hasMatch(en)) {
    patterns.add('word_salad_chain');
    classification = 'REWRITE';
    notes = '単語羅列連鎖';
  }

  // 要修正: establish 誤用
  if (RegExp(r'\bestablish\b.*\b(user|account|access|support|transfer|complete)\b', caseSensitive: false).hasMatch(en)) {
    patterns.add('establish_misuse');
    if (classification == 'OK') classification = 'REVISE';
    notes = notes.isEmpty ? 'establish→set up' : '$notes; establish→set up';
  }

  // 要修正: direction 誤用
  if (RegExp(r'\bdirection\s+(is|to|for)\b', caseSensitive: false).hasMatch(en)) {
    patterns.add('direction_misuse');
    if (classification == 'OK') classification = 'REVISE';
    notes = notes.isEmpty ? 'direction→instructions/steps' : '$notes; direction→instructions';
  }

  // 要修正: reveal 誤用
  if (RegExp(r'\breveal\b.*\b(onto|on)\s+(the\s+)?(screen|list)', caseSensitive: false).hasMatch(en)) {
    patterns.add('reveal_misuse');
    if (classification == 'OK') classification = 'REVISE';
    notes = notes.isEmpty ? 'reveal→show/display' : '$notes; reveal→show';
  }

  // 要修正: Production 単独・文脈外
  if (RegExp(r'\bProduction\.\s|^Production\.|\.\s+Production\.', caseSensitive: true).hasMatch(en)) {
    patterns.add('production_misuse');
    if (classification == 'OK') classification = 'REVISE';
    notes = notes.isEmpty ? 'Production 削除または置換' : '$notes; Production誤用';
  }

  // 要修正: perform rest
  if (RegExp(r'\bperform\s+rest\b', caseSensitive: false).hasMatch(en)) {
    patterns.add('perform_rest');
    if (classification == 'OK') classification = 'REVISE';
    notes = notes.isEmpty ? 'perform rest→get some rest' : '$notes; perform rest誤用';
  }

  // 要修正: weight of symptoms
  if (RegExp(r'\bweight\s+of\s+symptoms\b', caseSensitive: false).hasMatch(en)) {
    patterns.add('weight_of_symptoms');
    if (classification == 'OK') classification = 'REVISE';
    notes = notes.isEmpty ? 'weight of symptoms→severity of symptoms' : '$notes; weight誤用';
  }

  return (
    classification: classification,
    patternJoined: patterns.join('; '),
    notes: notes,
  );
}

Future<String?> _findDefaultCsv() async {
  final candidates = [
    'conversation_utterances_rows.csv',
    'conversation_utterances.csv',
    'assets/csv/conversation_utterances_rows.csv',
  ];
  for (final p in candidates) {
    if (await File(p).exists()) return p;
  }
  return null;
}
