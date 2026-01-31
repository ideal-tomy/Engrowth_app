import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../lib/services/image_upload_service.dart';
import '../lib/services/supabase_service.dart';

/// 単語画像をバッチアップロードするスクリプト
/// 
/// 使用方法:
/// 1. images/words/ フォルダに画像ファイルを配置
/// 2. ファイル名は {word_id}.jpg 形式
/// 3. dart run scripts/upload_word_images.dart
Future<void> main() async {
  // 環境変数の読み込み
  await dotenv.load(fileName: ".env");
  
  // Supabase初期化
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  
  // 画像フォルダのパス
  final imagesDir = Directory('images/words');
  
  if (!await imagesDir.exists()) {
    print('❌ 画像フォルダが見つかりません: ${imagesDir.path}');
    print('📁 images/words/ フォルダを作成して画像を配置してください');
    exit(1);
  }
  
  // すべての単語を取得
  final words = await SupabaseService.getWords();
  print('📝 ${words.length}件の単語を取得しました');
  
  // 画像ファイルを取得
  final imageFiles = imagesDir
      .listSync()
      .whereType<File>()
      .where((file) {
        final ext = file.path.split('.').last.toLowerCase();
        return ext == 'jpg' || ext == 'jpeg' || ext == 'png';
      })
      .toList();
  
  if (imageFiles.isEmpty) {
    print('❌ 画像ファイルが見つかりません');
    exit(1);
  }
  
  print('🖼️  ${imageFiles.length}個の画像ファイルが見つかりました');
  
  // 画像をアップロード
  int successCount = 0;
  int errorCount = 0;
  
  for (final imageFile in imageFiles) {
    try {
      // ファイル名からIDを抽出（拡張子を除く）
      final fileName = imageFile.path.split(Platform.pathSeparator).last;
      final wordId = fileName.split('.').first;
      
      // 対応する単語を検索
      final word = words.firstWhere(
        (w) => w.id == wordId,
        orElse: () => throw Exception('単語が見つかりません: $wordId'),
      );
      
      print('📤 アップロード中: ${word.word}');
      
      // 画像をアップロード
      final imageUrl = await ImageUploadService.uploadWordImage(
        wordId: wordId,
        imageFile: imageFile,
      );
      
      // データベースを更新（wordsテーブルにimage_urlカラムがある場合）
      try {
        await Supabase.instance.client
            .from('words')
            .update({'image_url': imageUrl})
            .eq('id', wordId);
      } catch (e) {
        print('⚠️  データベース更新スキップ（image_urlカラムが存在しない可能性）: $e');
      }
      
      print('✅ アップロード成功: $wordId');
      successCount++;
    } catch (e) {
      print('❌ エラー: ${imageFile.path} - $e');
      errorCount++;
    }
  }
  
  print('\n📊 アップロード結果:');
  print('✅ 成功: $successCount件');
  print('❌ 失敗: $errorCount件');
  
  exit(errorCount > 0 ? 1 : 0);
}
