/// 85本の3分ストーリー量産タスクを一覧表示する
///
/// 各タスクについて:
/// 1. generate_batch_prompt でプロンプト生成
/// 2. Cursor等でLLMにプロンプトを渡し、SQLを生成
/// 3. 生成後、validate_story_batch で検証
/// 4. 検証OKなら word_allocator --update で台帳更新
///
/// 使い方:
///   dart run scripts/run_batch_generation.dart
///   dart run scripts/run_batch_generation.dart --list
///   dart run scripts/run_batch_generation.dart --prompt <situation_id> <story_index>

import 'dart:io';
import 'package:csv/csv.dart';

const String manifestPath = 'docs/story_generation_manifest.csv';

void main(List<String> args) async {
  final listOnly = args.contains('--list');
  final promptIdx = args.indexOf('--prompt');

  if (promptIdx >= 0 && args.length > promptIdx + 2) {
    final sid = int.tryParse(args[promptIdx + 1]) ?? 0;
    final st = int.tryParse(args[promptIdx + 2]) ?? 1;
    await _runPrompt(sid, st);
    return;
  }

  final manifestFile = File(manifestPath);
  if (!await manifestFile.exists()) {
    print('ERROR: $manifestPath not found');
    exit(1);
  }

  final content = await manifestFile.readAsString();
  final rows = const CsvToListConverter().convert(content);
  if (rows.length < 2) {
    print('ERROR: manifest empty');
    exit(1);
  }

  final header = rows[0];
  final idx = header.map((e) => e.toString().toLowerCase()).toList();
  final sidCol = idx.indexOf('situation_id');
  final themeCol = idx.indexOf('theme_slug');
  final titleCol = idx.indexOf('title_seed');

  if (sidCol < 0 || themeCol < 0 || titleCol < 0) {
    print('ERROR: manifest missing columns');
    exit(1);
  }

  var count = 0;
  print('=== 3分ストーリー量産タスク一覧 (85本) ===\n');

  for (final row in rows.skip(1)) {
    if (row.length <= sidCol) continue;
    final situationId = int.tryParse(row[sidCol].toString()) ?? 0;
    final themeSlug = row[themeCol].toString().trim();
    final titleSeed = row[titleCol].toString().trim();

    for (var storyIndex = 1; storyIndex <= 5; storyIndex++) {
      count++;
      final nn = storyIndex.toString().padLeft(2, '0');
      final file = 'seed_story_${themeSlug}_$nn.sql';

      if (listOnly) {
        print('$count. situation=$situationId story=$storyIndex | $themeSlug | $file');
        print('   $titleSeed');
      } else {
        print('--- Task $count: $themeSlug #$storyIndex ---');
        print('   Situation ID: $situationId');
        print('   Output file: supabase/migrations/$file');
        print('   Prompt: dart run scripts/generate_batch_prompt.dart $situationId $storyIndex');
        print('   After generation: dart run scripts/word_allocator.dart $themeSlug $storyIndex --update ${themeSlug}_$nn');
        print('');
      }
    }
  }

  print('\nTotal: $count tasks');
  print('\nTo generate a single prompt:');
  print('  dart run scripts/generate_batch_prompt.dart <situation_id> <story_index>');
  print('\nTo validate generated SQL:');
  print('  dart run scripts/validate_story_batch.dart <path_to_sql>');
}

Future<void> _runPrompt(int situationId, int storyIndex) async {
  final result = await Process.run(
    'dart',
    ['run', 'scripts/generate_batch_prompt.dart', situationId.toString(), storyIndex.toString()],
    runInShell: true,
  );
  print(result.stdout);
  if (result.stderr.toString().isNotEmpty) {
    print(result.stderr);
  }
  exit(result.exitCode);
}
