import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../config/supabase_config.dart';

class ImageUploadService {
  /// 例文画像をアップロード
  static Future<String> uploadSentenceImage({
    required String sentenceId,
    required File imageFile,
  }) async {
    try {
      // 1. 画像をリサイズ（複数サイズ生成）
      final originalBytes = await imageFile.readAsBytes();
      
      // Original (1920x1080)
      final originalResized = await _resizeImage(
        imageBytes: originalBytes,
        maxWidth: 1920,
        maxHeight: 1080,
        quality: 90,
      );
      
      // Medium (800x450)
      final mediumResized = await _resizeImage(
        imageBytes: originalBytes,
        maxWidth: 800,
        maxHeight: 450,
        quality: 85,
      );
      
      // Thumbnail (300x169)
      final thumbnailResized = await _resizeImage(
        imageBytes: originalBytes,
        maxWidth: 300,
        maxHeight: 169,
        quality: 80,
      );
      
      // 2. Supabase Storageにアップロード
      final bucketName = 'sentences-images';
      
      // Original
      await SupabaseConfig.client.storage
          .from(bucketName)
          .uploadBinary(
            '$sentenceId/original.jpg',
            originalResized,
          );
      
      // Medium
      await SupabaseConfig.client.storage
          .from(bucketName)
          .uploadBinary(
            '$sentenceId/medium.jpg',
            mediumResized,
          );
      
      // Thumbnail
      await SupabaseConfig.client.storage
          .from(bucketName)
          .uploadBinary(
            '$sentenceId/thumbnail.jpg',
            thumbnailResized,
          );
      
      // 3. 公開URLを取得（medium画像をデフォルトとして使用）
      final publicUrl = SupabaseConfig.client.storage
          .from(bucketName)
          .getPublicUrl('$sentenceId/medium.jpg');
      
      return publicUrl;
    } catch (e) {
      print('Error uploading sentence image: $e');
      rethrow;
    }
  }

  /// 単語画像をアップロード
  static Future<String> uploadWordImage({
    required String wordId,
    required File imageFile,
  }) async {
    try {
      final originalBytes = await imageFile.readAsBytes();
      
      // Original (800x800)
      final originalResized = await _resizeImage(
        imageBytes: originalBytes,
        maxWidth: 800,
        maxHeight: 800,
        quality: 90,
      );
      
      // Medium (400x400)
      final mediumResized = await _resizeImage(
        imageBytes: originalBytes,
        maxWidth: 400,
        maxHeight: 400,
        quality: 85,
      );
      
      // Thumbnail (200x200)
      final thumbnailResized = await _resizeImage(
        imageBytes: originalBytes,
        maxWidth: 200,
        maxHeight: 200,
        quality: 80,
      );
      
      final bucketName = 'words-images';
      
      // アップロード
      await SupabaseConfig.client.storage
          .from(bucketName)
          .uploadBinary(
            '$wordId/original.jpg',
            originalResized,
          );
      
      await SupabaseConfig.client.storage
          .from(bucketName)
          .uploadBinary(
            '$wordId/medium.jpg',
            mediumResized,
          );
      
      await SupabaseConfig.client.storage
          .from(bucketName)
          .uploadBinary(
            '$wordId/thumbnail.jpg',
            thumbnailResized,
          );
      
      final publicUrl = SupabaseConfig.client.storage
          .from(bucketName)
          .getPublicUrl('$wordId/medium.jpg');
      
      return publicUrl;
    } catch (e) {
      print('Error uploading word image: $e');
      rethrow;
    }
  }

  /// 画像をリサイズ
  static Future<Uint8List> _resizeImage({
    required Uint8List imageBytes,
    required int maxWidth,
    required int maxHeight,
    int quality = 85,
  }) async {
    try {
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception('画像のデコードに失敗');
      }
      
      final resizedImage = img.copyResize(
        originalImage,
        width: maxWidth,
        height: maxHeight,
        maintainAspect: true,
      );
      
      return Uint8List.fromList(
        img.encodeJpg(resizedImage, quality: quality),
      );
    } catch (e) {
      print('Error resizing image: $e');
      rethrow;
    }
  }

  /// 画像を削除
  static Future<void> deleteImage(String imageUrl) async {
    try {
      // URLからパスを抽出
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // /storage/v1/object/public/{bucket}/{path} の形式から抽出
      final bucketIndex = pathSegments.indexOf('public');
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        throw Exception('Invalid image URL format');
      }
      
      final bucketName = pathSegments[bucketIndex + 1];
      final filePath = pathSegments.sublist(bucketIndex + 2).join('/');
      
      // すべてのサイズを削除
      final basePath = filePath.replaceAll('/medium.jpg', '').replaceAll('/original.jpg', '').replaceAll('/thumbnail.jpg', '');
      
      final paths = [
        '$basePath/original.jpg',
        '$basePath/medium.jpg',
        '$basePath/thumbnail.jpg',
      ];
      
      for (final path in paths) {
        try {
          await SupabaseConfig.client.storage
              .from(bucketName)
              .remove([path]);
        } catch (e) {
          // ファイルが存在しない場合はスキップ
          print('Warning: Could not delete $path: $e');
        }
      }
    } catch (e) {
      print('Error deleting image: $e');
      rethrow;
    }
  }

  /// 画像URLを取得（サイズ指定）
  static String getImageUrl({
    required String bucketName,
    required String itemId,
    ImageSize size = ImageSize.medium,
  }) {
    String sizePath;
    switch (size) {
      case ImageSize.original:
        sizePath = 'original.jpg';
        break;
      case ImageSize.medium:
        sizePath = 'medium.jpg';
        break;
      case ImageSize.thumbnail:
        sizePath = 'thumbnail.jpg';
        break;
    }
    
    return SupabaseConfig.client.storage
        .from(bucketName)
        .getPublicUrl('$itemId/$sizePath');
  }
}

enum ImageSize {
  original,
  medium,
  thumbnail,
}
