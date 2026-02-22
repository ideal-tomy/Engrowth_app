/// 量産用プロンプトを生成する
///
/// manifest + word_allocator から、Cursorに渡すプロンプトを組み立てる。
///
/// 使い方:
///   dart run scripts/generate_batch_prompt.dart <situation_id> <story_index>
///   dart run scripts/generate_batch_prompt.dart 1 1
///
/// 出力: 標準出力にプロンプトを表示

import 'dart:io';
import 'package:csv/csv.dart';

const String manifestPath = 'docs/story_generation_manifest.csv';
const String ledgerPath = 'assets/csv/words_usage_ledger.csv';

void main(List<String> args) async {
  if (args.length < 2) {
    print('Usage: dart run scripts/generate_batch_prompt.dart <situation_id> <story_index>');
    exit(1);
  }

  final situationId = int.tryParse(args[0]) ?? 0;
  final storyIndex = int.tryParse(args[1]) ?? 1;
  if (situationId < 1 || situationId > 17) {
    print('ERROR: situation_id must be 1-17');
    exit(1);
  }

  final manifestFile = File(manifestPath);
  if (!await manifestFile.exists()) {
    print('ERROR: $manifestPath not found');
    exit(1);
  }

  final manifestContent = await manifestFile.readAsString();
  final manifestRows = const CsvToListConverter().convert(manifestContent);
  if (manifestRows.length < 2) {
    print('ERROR: manifest empty');
    exit(1);
  }

  final header = manifestRows[0];
  final idx = header.map((e) => e.toString().toLowerCase()).toList();
  final sid = idx.indexOf('situation_id');
  final ts = idx.indexOf('theme_slug');
  final tse = idx.indexOf('title_seed');
  final ose = idx.indexOf('overview_seed');

  if (sid < 0 || ts < 0 || tse < 0 || ose < 0) {
    print('ERROR: manifest missing columns');
    exit(1);
  }

  List<dynamic>? row;
  for (final r in manifestRows.skip(1)) {
    if (r.length > sid && int.tryParse(r[sid].toString()) == situationId) {
      row = r;
      break;
    }
  }

  if (row == null) {
    print('ERROR: situation_id $situationId not found');
    exit(1);
  }

  final themeSlug = row[ts].toString().trim();
  final titleSeed = row[tse].toString().trim();
  final overviewSeed = row[ose].toString().trim();

  // Run word allocator to get words
  final result = await Process.run(
    'dart',
    ['run', 'scripts/word_allocator.dart', themeSlug, storyIndex.toString()],
    runInShell: true,
  );

  var allocatedWords = '';
  if (result.exitCode == 0) {
    final lines = (result.stdout as String).split('\n');
    final wordLines = lines.where((l) {
      final s = l.trim();
      return s.isNotEmpty && !s.startsWith('ALLOCATED') && !s.startsWith('WORD_RANGE') && !s.startsWith('UPDATED');
    });
    allocatedWords = wordLines.join(', ');
  }

  if (allocatedWords.isEmpty) {
    allocatedWords = '(word_allocator が失敗した場合は手動で単語を指定してください)';
  }

  final nn = storyIndex.toString().padLeft(2, '0');

  final prompt = '''
@assets/csv/words_usage_ledger.csv と @docs/story_generation_manifest.csv と @docs/archive/seed_stories/seed_story_coffee_shop.sql を参照してください。

次の条件で3分英会話を1本作成してください。

- シチュエーション: 【$titleSeed】
- 概要: $overviewSeed
- theme_slug: $themeSlug
- 割当単語: 以下の単語を10〜15語、自然に会話に組み込んでください。
  $allocatedWords

- 出力:
  1. JSON形式（story_sequence + conversations + utterances）
  2. Supabase用 INSERT SQL（雛形の構造に準拠、conversations に situation_type, theme を含める）
  3. 検証出力（used_target_words, used_non_target_key_words, continuity_check）

- ファイル名: seed_story_${themeSlug}_$nn.sql
- 保存先: supabase/migrations/
- 会話の長さ・チャンク数・フォーマットは雛形と同様にしてください。

@docs/prompts/3min_story_generation_rules.md と @docs/prompts/3min_story_batch_generation_template.md のルールに従ってください。
''';

  print(prompt);
}
