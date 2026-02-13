/// 会話形式CSVを conversations + conversation_utterances にインポートするスクリプト
///
/// 使い方（プロジェクトルートで）:
///   dart run scripts/import_conversations_from_csv.dart
///   （カフェ・ホテルのCSVを自動検出）
///
/// または ファイルパスを指定:
///   dart run scripts/import_conversations_from_csv.dart "Engrowthアプリ英単語データ - カフェ・レストラン編.csv"
///
/// 必要なテーブル: conversations, conversation_utterances（database_conversation_migration.sql 実行済み）
/// 注意: Flutter非依存の純粋Dartで実行（supabase + dotenv パッケージ使用）

import 'dart:io';
import 'package:csv/csv.dart';
import 'package:supabase/supabase.dart';
import 'package:dotenv/dotenv.dart';

void main(List<String> args) async {
  final env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
  final url = env['SUPABASE_URL'];
  final anonKey = env['SUPABASE_ANON_KEY'];
  if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
    print('❌ .env に SUPABASE_URL と SUPABASE_ANON_KEY を設定してください');
    exit(1);
  }

  final client = SupabaseClient(url, anonKey);

  // インポート対象CSV（引数 or デフォルト2ファイル）
  final csvPaths = args.isNotEmpty
      ? args
      : [
          'Engrowthアプリ英単語データ - カフェ・レストラン編.csv',
          'Engrowthアプリ英単語データ - ホテル・宿泊.csv',
        ];

  for (final path in csvPaths) {
    final file = File(path);
    if (!await file.exists()) {
      print('⚠ スキップ: $path （ファイルが見つかりません）');
      continue;
    }

    final theme = _themeFromFilename(path);
    final situationType = _situationTypeFromFilename(path);

    print('\n📂 処理中: $path');
    print('   theme: $theme, situation_type: $situationType');

    final content = await file.readAsString();
    final rows = const CsvToListConverter().convert(content);

    if (rows.isEmpty) {
      print('   ⚠ データなし');
      continue;
    }

    final header = rows[0].map((e) => e.toString().trim()).toList();
    final colScenario = header.indexOf('Scenario_ID');
    final colOrder = header.indexOf('Order');
    final colRole = header.indexOf('Role');
    final colTextEn = header.indexOf('Text_EN');
    final colTextJp = header.indexOf('Text_JP');

    if (colScenario == -1 || colOrder == -1 || colRole == -1 || colTextEn == -1 || colTextJp == -1) {
      print('   ❌ 必要なカラムが見つかりません。Scenario_ID, Order, Role, Text_EN, Text_JP が必要です。');
      continue;
    }

    // Scenario_ID でグループ化
    final grouped = <String, List<List>>{};
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length <= colScenario) continue;

      final scenarioId = row[colScenario].toString().trim();
      if (scenarioId.isEmpty || scenarioId == 'Scenario_ID') continue;

      grouped.putIfAbsent(scenarioId, () => []).add(row);
    }

    for (final entry in grouped.entries) {
      final scenarioId = entry.key;
      final utterances = entry.value;

      // Orderでソート
      utterances.sort((a, b) {
        final o1 = int.tryParse(a[colOrder].toString()) ?? 0;
        final o2 = int.tryParse(b[colOrder].toString()) ?? 0;
        return o1.compareTo(o2);
      });

      final title = '${_humanizeScenarioId(scenarioId)} - $theme';

      try {
        final convResp = await client.from('conversations').insert({
          'title': title,
          'description': '$theme の会話シナリオ',
          'situation_type': situationType,
          'theme': theme,
        }).select('id').single();

        final conversationId = convResp['id'] as String;

        final utteranceRows = <Map<String, dynamic>>[];
        for (var i = 0; i < utterances.length; i++) {
          final row = utterances[i];
          final textEn = row.length > colTextEn ? row[colTextEn].toString().trim() : '';
          final textJp = row.length > colTextJp ? row[colTextJp].toString().trim() : '';
          if (textEn.isEmpty) continue;

          utteranceRows.add({
            'conversation_id': conversationId,
            'speaker_role': row.length > colRole ? row[colRole].toString().trim() : 'A',
            'utterance_order': i + 1,
            'english_text': textEn,
            'japanese_text': textJp.isEmpty ? '' : textJp,
          });
        }

        if (utteranceRows.isNotEmpty) {
          await client.from('conversation_utterances').insert(utteranceRows);
          print('   ✅ $scenarioId: 会話1件 + 発話${utteranceRows.length}件');
        } else {
          await client.from('conversations').delete().eq('id', conversationId);
          print('   ⚠ $scenarioId: 有効な発話がなかったためスキップ');
        }
      } catch (e) {
        print('   ❌ $scenarioId エラー: $e');
      }
    }
  }

  print('\n✅ インポート完了');
}

String _themeFromFilename(String path) {
  if (path.contains('カフェ') || path.contains('レストラン')) return 'カフェ・レストラン';
  if (path.contains('ホテル') || path.contains('宿泊')) return 'ホテル・宿泊';
  return 'その他';
}

String _situationTypeFromFilename(String path) {
  if (path.contains('カフェ') || path.contains('レストラン')) return 'daily';
  if (path.contains('ホテル') || path.contains('宿泊')) return 'travel';
  return 'daily';
}

String _humanizeScenarioId(String id) {
  if (id.startsWith('CAFE_')) return 'カフェ シーン${id.substring(5)}';
  if (id.startsWith('HOTEL_')) return 'ホテル シーン${id.substring(6)}';
  return id;
}
