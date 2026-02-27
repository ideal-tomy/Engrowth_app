/// 会話形式CSVを conversations + conversation_utterances にインポートするスクリプト
///
/// 使い方（プロジェクトルートで）:
///   dart run scripts/import_conversations_from_csv.dart
///   （assets/csv 内の会話CSVを自動検出）
///
/// 上書きインポート（既存会話を全削除してから投入）:
///   dart run scripts/import_conversations_from_csv.dart --replace
///
/// または ファイルパスを指定:
///   dart run scripts/import_conversations_from_csv.dart "assets/csv/Engrowthアプリ英単語データ - アパレル 01： 試着とサイズ探し.csv"
///
/// 必要なテーブル: conversations, conversation_utterances（database_conversation_migration.sql 実行済み）
/// 注意: Flutter非依存の純粋Dartで実行（supabase + dotenv パッケージ使用）
/// --replace 時は DELETE ポリシーが必要（SUPABASE_CONVERSATION_UPDATE_RUNBOOK.md 参照）

import 'dart:io';
import 'package:csv/csv.dart';
import 'package:supabase/supabase.dart';
import 'package:dotenv/dotenv.dart';

void main(List<String> args) async {
  final env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
  final url = env['SUPABASE_URL'];
  var serviceKey = env['SUPABASE_SERVICE_ROLE_KEY'];
  var anonKey = env['SUPABASE_ANON_KEY'];
  // --replace 時は service_role を推奨（DELETE 権限）
  final doReplace = args.contains('--replace');
  final filteredArgs = args.where((a) => a != '--replace').toList();

  if (url == null || url.isEmpty) {
    print('❌ .env に SUPABASE_URL を設定してください');
    exit(1);
  }
  if (serviceKey == null || serviceKey.isEmpty) serviceKey = anonKey;
  if (anonKey == null || anonKey.isEmpty) {
    print('❌ .env に SUPABASE_ANON_KEY または SUPABASE_SERVICE_ROLE_KEY を設定してください');
    exit(1);
  }

  final key = doReplace && (env['SUPABASE_SERVICE_ROLE_KEY'] ?? '').isNotEmpty
      ? env['SUPABASE_SERVICE_ROLE_KEY']!
      : anonKey!;
  final client = SupabaseClient(url, key);

  // インポート対象CSV（引数 or assets/csv 内の全CSV）
  final List<String> csvPaths = filteredArgs.isNotEmpty
      ? filteredArgs
      : await _findCsvFilesInAssets();

  if (csvPaths.isEmpty) {
    print('❌ インポート対象のCSVファイルが見つかりません（assets/csv を確認してください）');
    exit(1);
  }

  if (doReplace) {
    print('⚠ --replace 指定: 既存の会話データを全削除してからインポートします');
    try {
      final convs = await client.from('conversations').select('id');
      final ids = (convs as List).map((r) => r['id'] as String).toList();
      if (ids.isNotEmpty) {
        for (var i = 0; i < ids.length; i += 100) {
          final chunk = ids.skip(i).take(100).toList();
          await client.from('conversation_utterances').delete().inFilter('conversation_id', chunk);
          await client.from('conversations').delete().inFilter('id', chunk);
        }
        print('   ${ids.length} 件の会話を削除しました');
      } else {
        print('   削除対象なし（テーブルは空）');
      }
    } catch (e) {
      print('   ❌ 削除エラー: $e');
      print('   → RLS で DELETE が許可されていない場合は、Supabase Dashboard で手動削除するか');
      print('   → .env に SUPABASE_SERVICE_ROLE_KEY を設定してください');
      exit(1);
    }
  }

  print('📋 対象: ${csvPaths.length} ファイル');

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
    int colScenario = header.indexOf('Scenario_ID');
    int colOrder = header.indexOf('Order');
    int colRole = header.indexOf('Role');
    int colTextEn = header.indexOf('Text_EN');
    int colTextJp = header.indexOf('Text_JP');

    int dataStartRow = 1;
    if (colScenario == -1 || colOrder == -1 || colRole == -1 || colTextEn == -1 || colTextJp == -1) {
      // ヘッダー行がない場合: 標準カラム順序を想定
      if (header.length >= 5 && RegExp(r'^[A-Za-z0-9]+_\d+').hasMatch(header[0].toString())) {
        colScenario = 0;
        colOrder = 1;
        colRole = 2;
        colTextEn = 3;
        colTextJp = 4;
        dataStartRow = 0;
      } else {
        print('   ❌ 必要なカラムが見つかりません。Scenario_ID, Order, Role, Text_EN, Text_JP が必要です。');
        continue;
      }
    }

    // Scenario_ID でグループ化
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

      // Orderでソート
      utterances.sort((a, b) {
        final o1 = int.tryParse(a[colOrder].toString()) ?? 0;
        final o2 = int.tryParse(b[colOrder].toString()) ?? 0;
        return o1.compareTo(o2);
      });

      final title = _buildTitle(scenarioId, theme);

      try {
        final convResp = await client.from('conversations').insert({
          'title': title,
          'description': '$theme の会話練習',
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

Future<List<String>> _findCsvFilesInAssets() async {
  final csvDir = Directory('assets/csv');
  if (!await csvDir.exists()) return [];
  final exclude = ['words_master', 'words_slot', 'words_usage_ledger', 'useful_phrases'];
  final files = csvDir
      .listSync()
      .whereType<File>()
      .where((f) {
        final name = f.path.split(RegExp(r'[/\\]')).last.toLowerCase();
        if (!name.endsWith('.csv')) return false;
        return !exclude.any((e) => name.contains(e));
      })
      .map((f) => f.path)
      .toList();
  files.sort();
  return files;
}

String _themeFromFilename(String path) {
  final name = path.split(RegExp(r'[/\\]')).last;
  final match = RegExp(r'Engrowthアプリ英単語データ\s*-\s*(.+?)\.csv').firstMatch(name);
  if (match != null) {
    final full = match.group(1) ?? '';
    if (full.contains('：')) return full.split('：').first.trim();
    if (RegExp(r'\d+').hasMatch(full)) {
      return full.replaceFirst(RegExp(r'\s*\d+\s*.*'), '').trim();
    }
    return full.trim();
  }
  if (name.contains('カフェ') || name.contains('レストラン')) return 'カフェ・レストラン';
  if (name.contains('ホテル') || name.contains('宿泊')) return 'ホテル・宿泊';
  if (name.contains('空港')) return '空港';
  return 'その他';
}

String _situationTypeFromFilename(String path) {
  final name = path.split(RegExp(r'[/\\]')).last;
  if (name.contains('ホテル') || name.contains('宿泊') || name.contains('空港') ||
      name.contains('交通') || name.contains('入国') || name.contains('免税')) {
    return 'travel';
  }
  return 'daily';
}

/// アプリ表示用のタイトルを生成（テーマ＋番号）
String _buildTitle(String scenarioId, String theme) {
  final num = RegExp(r'(\d+)$').firstMatch(scenarioId)?.group(1) ?? '1';
  final themeLabel = _normalizeThemeForDisplay(theme);
  return '$themeLabel $num';
}

String _normalizeThemeForDisplay(String theme) {
  if (theme.contains('道') || theme.contains('案内')) return '道案内';
  if (theme.contains('挨拶')) return '挨拶';
  if (theme.contains('自己紹介')) return '自己紹介';
  if (theme.contains('飛行機') || theme.contains('空港')) return '空港';
  if (theme.contains('ホテル') || theme.contains('宿泊')) return 'ホテル';
  if (theme.contains('カフェ') || theme.contains('レストラン')) return 'カフェ・レストラン';
  if (theme.contains('アパレル')) return 'アパレル';
  if (theme.contains('スーパー')) return 'スーパー';
  if (theme.contains('ベーカリー') || theme.contains('デリ')) return 'ベーカリー';
  if (theme.contains('ドラッグ')) return 'ドラッグストア';
  if (theme.contains('病院')) return '病院';
  if (theme.contains('銀行')) return '銀行';
  if (theme.contains('郵便') || theme.contains('宅急便')) return '郵便局・宅急便';
  if (theme.contains('土産') || theme.contains('雑貨')) return 'お土産・雑貨';
  if (theme.contains('マーケット')) return 'マーケット';
  if (theme.contains('交通') || theme.contains('免税')) return theme;
  return theme;
}

String _humanizeScenarioId(String id) {
  if (id.startsWith('CAFE_')) return 'カフェ シーン${id.substring(5)}';
  if (id.startsWith('HOTEL_')) return 'ホテル シーン${id.substring(6)}';
  if (id.startsWith('AIRPORT_')) return '空港 シーン${id.substring(8)}';
  if (id.startsWith('AP_')) return 'アパレル シーン${id.substring(3)}';
  if (id.startsWith('AP2_')) return 'アパレル シーン${id.substring(4)}';
  if (id.startsWith('SHOP01_')) return 'スーパー シーン${id.substring(7)}';
  if (id.startsWith('SHOP02_')) return 'スーパー シーン${id.substring(7)}';
  if (id.startsWith('MEDICAL_')) return '病院 シーン${id.substring(8)}';
  if (id.startsWith('DRUG_')) return 'ドラッグストア シーン${id.substring(5)}';
  if (id.startsWith('DRUG_BEAUTY_')) return 'ドラッグストア シーン${id.substring(12)}';
  if (id.startsWith('BK_')) return 'ベーカリー シーン${id.substring(3)}';
  if (id.startsWith('MK_')) return 'マーケット シーン${id.substring(4)}';
  if (id.startsWith('TRANSIT_')) return '交通 シーン${id.substring(8)}';
  if (id.startsWith('TF_')) return '免税 シーン${id.substring(3)}';
  if (id.startsWith('SG_')) return 'お土産 シーン${id.substring(3)}';
  if (id.startsWith('GR_')) return '挨拶 シーン${id.substring(3)}';
  if (id.startsWith('SI_')) return '自己紹介 シーン${id.substring(3)}';
  if (id.startsWith('BA_')) return '銀行 シーン${id.substring(3)}';
  if (id.startsWith('POST_')) return '郵便局 シーン${id.substring(5)}';
  if (id.startsWith('DR_')) return '道案内 シーン${id.substring(3)}';
  return id;
}
