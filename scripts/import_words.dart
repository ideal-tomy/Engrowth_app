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
  final csvFile = File('Engrowthアプリ英単語データ - 4語制限.csv');
  
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
  final words = <Map<String, dynamic>>[];
  
  for (final line in dataLines) {
    if (line.length < 5) continue;
    
    try {
      final wordNumber = int.tryParse(line[0].toString()) ?? 0;
      if (wordNumber == 0) continue;
      
      words.add({
        'word_number': wordNumber,
        'word': line[1].toString().trim(),
        'meaning': line[2].toString().trim(),
        'part_of_speech': line[3].toString().trim().isEmpty 
            ? null 
            : line[3].toString().trim(),
        'word_group': line[4].toString().trim().isEmpty 
            ? null 
            : line[4].toString().trim(),
      });
    } catch (e) {
      print('Error parsing line: $line - $e');
      continue;
    }
  }
  
  // バッチでSupabaseに挿入
  if (words.isNotEmpty) {
    try {
      await Supabase.instance.client
          .from('words')
          .upsert(words, onConflict: 'word_number');
      
      print('✅ ${words.length}件の単語をインポートしました');
    } catch (e) {
      print('❌ インポートエラー: $e');
      exit(1);
    }
  } else {
    print('インポートするデータがありません');
    exit(1);
  }
}
