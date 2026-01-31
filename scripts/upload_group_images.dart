import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Group名ベースで例文画像をアップロードするスクリプト
/// 
/// 使用方法:
/// 1. images/sentences/ フォルダに画像ファイルを配置
/// 2. ファイル名は {group}.png 形式（例: S-001.png）
/// 3. dart run scripts/upload_group_images.dart
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
  
  // 画像ファイルを取得（Group名形式: {group}.png）
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
    print('📝 ファイル名は {group}.png 形式にしてください（例: S-001.png）');
    exit(1);
  }
  
  print('🖼️  ${imageFiles.length}個の画像ファイルが見つかりました');
  
  // 画像をアップロード
  int successCount = 0;
  int errorCount = 0;
  final bucketName = 'sentences-images';
  
  for (final imageFile in imageFiles) {
    try {
      // ファイル名からGroup名を抽出（拡張子を除く）
      final fileName = imageFile.path.split(Platform.pathSeparator).last;
      final groupName = fileName.split('.').first;
      
      print('📤 アップロード中: $groupName');
      
      // 画像を読み込み
      final imageBytes = await imageFile.readAsBytes();
      
      // Supabase Storageにアップロード
      await Supabase.instance.client.storage
          .from(bucketName)
          .uploadBinary(
            '$groupName.png',
            imageBytes,
          );
      
      print('✅ アップロード成功: $groupName.png');
      successCount++;
    } catch (e) {
      print('❌ エラー: ${imageFile.path} - $e');
      errorCount++;
    }
  }
  
  print('\n📊 アップロード結果:');
  print('✅ 成功: $successCount件');
  print('❌ 失敗: $errorCount件');
  print('\n💡 注意: Group名ベースのアップロードの場合、データベースの更新は不要です。');
  print('   アプリが自動的にGroup名から画像URLを生成します。');
  
  exit(errorCount > 0 ? 1 : 0);
}
