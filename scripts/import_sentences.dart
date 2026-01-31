import 'dart:io';
import 'package:csv/csv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // 環境変数の読み込み
  await dotenv.load(fileName: ".env");
  
  // Supabase初期化
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  
  // CSVファイルのパス
  final csvFile = File('Engrowthアプリ英単語データ のコピー - 例文リスト02.csv');
  
  if (!await csvFile.exists()) {
    print('CSVファイルが見つかりません: ${csvFile.path}');
    exit(1);
  }
  
  final csvContent = await csvFile.readAsString();
  final lines = const CsvToListConverter().convert(csvContent);
  
  // ヘッダー行をスキップ
  if (lines.isEmpty) {
    print('CSVファイルが空です');
    exit(1);
  }
  
  final dataLines = lines.skip(1).toList();
  final sentences = <Map<String, dynamic>>[];
  
  for (final line in dataLines) {
    if (line.length < 8) continue;
    
    try {
      sentences.add({
        'group': line[0].toString().trim().isEmpty ? null : line[0].toString().trim(),
        'target_words': line[1].toString().trim().isEmpty ? null : line[1].toString().trim(),
        'scene_setting': line[2].toString().trim().isEmpty ? null : line[2].toString().trim(),
        'dialogue_en': line[3].toString().trim(),
        'dialogue_jp': line[4].toString().trim(),
        'category_tag': line[5].toString().trim().isEmpty ? null : line[5].toString().trim(),
        'image_prompt': line[6].toString().trim().isEmpty ? null : line[6].toString().trim(),
        'image_url': line[7].toString().trim().isEmpty ? null : line[7].toString().trim(),
        'difficulty': 1,
      });
    } catch (e) {
      print('Error parsing line: $line - $e');
      continue;
    }
  }
  
  // バッチでSupabaseに挿入
  if (sentences.isNotEmpty) {
    try {
      await Supabase.instance.client
          .from('sentences')
          .upsert(sentences);
      
      print('✅ ${sentences.length}件の例文をインポートしました');
    } catch (e) {
      print('❌ インポートエラー: $e');
      exit(1);
    }
  } else {
    print('インポートするデータがありません');
    exit(1);
  }
}
