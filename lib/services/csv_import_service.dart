import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class CsvImportService {
  static Future<void> importWordsFromCsv(String csvContent) async {
    final lines = const CsvToListConverter().convert(csvContent);
    
    // ヘッダー行をスキップ
    if (lines.isEmpty) return;
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
      await SupabaseConfig.client
          .from('words')
          .upsert(words, onConflict: 'word_number');
      
      print('Imported ${words.length} words successfully');
    }
  }
  
  static Future<void> importWordsFromFile(String filePath) async {
    // ファイル読み込みは後で実装（path_provider使用）
    // 現時点では文字列として受け取る
  }
}
