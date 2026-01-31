import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../lib/services/image_upload_service.dart';
import '../lib/services/supabase_service.dart';

/// 例文画像をバッチアップロードするスクリプト
/// 
/// 使用方法:
/// 1. images/sentences/ フォルダに画像ファイルを配置
/// 2. ファイル名は {sentence_id}.jpg 形式
/// 3. dart run scripts/upload_sentence_images.dart
Future<void> main() async {
  // 環境変数の読み込み
  await dotenv.load(fileName: ".env");
  
  // Supabase初期化
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  
  // 画像フォルダのパス
  final imagesDir = Directory('images/sentences');
  
  if (!await imagesDir.exists()) {
    print('❌ 画像フォルダが見つかりません: ${imagesDir.path}');
    print('📁 images/sentences/ フォルダを作成して画像を配置してください');
    exit(1);
  }
  
  // すべての例文を取得
  final sentences = await SupabaseService.getSentences();
  print('📝 ${sentences.length}件の例文を取得しました');
  
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
      final sentenceId = fileName.split('.').first;
      
      // 対応する例文を検索
      final sentence = sentences.firstWhere(
        (s) => s.id == sentenceId,
        orElse: () => throw Exception('例文が見つかりません: $sentenceId'),
      );
      
      print('📤 アップロード中: ${sentence.englishText.substring(0, sentence.englishText.length > 30 ? 30 : sentence.englishText.length)}...');
      
      // 画像をアップロード
      final imageUrl = await ImageUploadService.uploadSentenceImage(
        sentenceId: sentenceId,
        imageFile: imageFile,
      );
      
      // データベースを更新
      await Supabase.instance.client
          .from('sentences')
          .update({'image_url': imageUrl})
          .eq('id', sentenceId);
      
      print('✅ アップロード成功: $sentenceId');
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
