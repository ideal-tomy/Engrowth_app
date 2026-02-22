/// テーマ単位でストーリー投入サイクルを案内する
///
/// 指定テーマの5本について、投入順序・検証・台帳更新のコマンドを表示する。
///
/// 使い方:
///   dart run scripts/import_story_theme.dart <theme_slug>
///   dart run scripts/import_story_theme.dart greeting_biz
///
/// 出力: Supabase投入用SQLパス、検証コマンド、台帳更新コマンドの一覧

import 'dart:io';
import 'package:csv/csv.dart';

const String manifestPath = 'docs/story_generation_manifest.csv';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run scripts/import_story_theme.dart <theme_slug>');
    print('');
    print('Available theme_slugs: greeting_biz, greeting_student, selfintro_biz, selfintro_student,');
    print('  directions, flight, hotel, cafe, shopping, transport, business_email,');
    print('  presentation1, presentation2, bank, post, hospital, custom');
    exit(1);
  }

  final themeSlug = args[0];

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
  final themeCol = idx.indexOf('theme_slug');
  final titleCol = idx.indexOf('title_seed');
  if (themeCol < 0 || titleCol < 0) {
    print('ERROR: manifest missing columns');
    exit(1);
  }

  List<dynamic>? row;
  for (final r in rows.skip(1)) {
    if (r.length > themeCol && r[themeCol].toString().trim() == themeSlug) {
      row = r;
      break;
    }
  }

  if (row == null) {
    print('ERROR: theme_slug "$themeSlug" not found in manifest');
    exit(1);
  }

  final titleSeed = row[titleCol].toString().trim();

  print('=== Theme: $themeSlug ===');
  print('Title: $titleSeed');
  print('');
  print('1. Validate each SQL file:');
  for (var i = 1; i <= 5; i++) {
    final nn = i.toString().padLeft(2, '0');
    final file = 'supabase/migrations/seed_story_${themeSlug}_$nn.sql';
    print('   dart run scripts/validate_story_batch.dart $file');
  }
  print('');
  print('2. Import to Supabase (Dashboard -> SQL Editor):');
  for (var i = 1; i <= 5; i++) {
    final nn = i.toString().padLeft(2, '0');
    final file = 'supabase/migrations/seed_story_${themeSlug}_$nn.sql';
    print('   Run: $file');
  }
  print('');
  print('3. Update word ledger after each successful import:');
  for (var i = 1; i <= 5; i++) {
    final nn = i.toString().padLeft(2, '0');
    print('   dart run scripts/word_allocator.dart $themeSlug $i --update ${themeSlug}_$nn');
  }
  print('');
  print('4. Verify in app: 3分ストーリー一覧、再生、チャンク遷移');
}
