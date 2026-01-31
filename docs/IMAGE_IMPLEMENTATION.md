# 画像実装設計

## 概要

Supabase Storageを使用した画像管理システムの実装設計です。

## アーキテクチャ

### 1. ストレージ構造

```
supabase-storage/
├── sentences/
│   ├── {sentence_id}/
│   │   ├── original.jpg
│   │   ├── thumbnail.jpg (300x300)
│   │   └── medium.jpg (800x450)
│   └── ...
└── words/
    ├── {word_id}/
    │   ├── original.jpg
    │   ├── thumbnail.jpg (200x200)
    │   └── medium.jpg (400x400)
    └── ...
```

### 2. 画像サイズ

#### 例文画像
- **Original**: 1920x1080 (16:9)
- **Medium**: 800x450 (16:9)
- **Thumbnail**: 300x169 (16:9)

#### 単語画像
- **Original**: 800x800 (1:1)
- **Medium**: 400x400 (1:1)
- **Thumbnail**: 200x200 (1:1)

### 3. 画像フォーマット

- **形式**: JPEG（写真）、PNG（イラスト）
- **品質**: JPEG 85%（バランス重視）
- **最適化**: WebP対応（オプション）

## Supabase Storage設定

### 1. バケット作成

```sql
-- Storageバケットの作成（Supabase Dashboardで実行）
-- sentences-images: 例文画像用
-- words-images: 単語画像用
```

### 2. ストレージポリシー

```sql
-- 公開読み取りポリシー
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING (bucket_id = 'sentences-images' OR bucket_id = 'words-images');

-- 認証済みユーザーのアップロード許可（将来の拡張用）
CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated' AND
  (bucket_id = 'sentences-images' OR bucket_id = 'words-images')
);
```

### 3. CORS設定

```javascript
// Supabase Dashboard → Storage → Settings
{
  "allowedOrigins": ["*"],
  "allowedMethods": ["GET", "HEAD"],
  "allowedHeaders": ["*"],
  "maxAge": 3600
}
```

## 実装要件

### 1. 画像アップロードサービス

```dart
class ImageUploadService {
  // 画像アップロード
  Future<String> uploadSentenceImage({
    required String sentenceId,
    required File imageFile,
  }) async {
    // 1. 画像リサイズ
    // 2. Supabase Storageにアップロード
    // 3. 公開URLを取得
    // 4. データベースにURLを保存
  }
  
  // 画像削除
  Future<void> deleteImage(String imageUrl) async {
    // 1. URLからパスを抽出
    // 2. Supabase Storageから削除
  }
}
```

### 2. 画像リサイズ

```yaml
# pubspec.yamlに追加
dependencies:
  image: ^4.0.17
```

```dart
import 'package:image/image.dart' as img;

Future<Uint8List> resizeImage({
  required Uint8List imageBytes,
  required int maxWidth,
  required int maxHeight,
  int quality = 85,
}) async {
  final originalImage = img.decodeImage(imageBytes);
  if (originalImage == null) throw Exception('画像のデコードに失敗');
  
  final resizedImage = img.copyResize(
    originalImage,
    width: maxWidth,
    height: maxHeight,
    maintainAspect: true,
  );
  
  return Uint8List.fromList(
    img.encodeJpg(resizedImage, quality: quality),
  );
}
```

### 3. 画像URL管理

```dart
// Sentenceモデルに追加
class Sentence {
  final String? imageUrl;
  final String? thumbnailUrl;
  final String? mediumImageUrl;
  
  // 画像URL取得ヘルパー
  String getDisplayImageUrl({bool useThumbnail = false}) {
    if (useThumbnail && thumbnailUrl != null) {
      return thumbnailUrl!;
    }
    return mediumImageUrl ?? imageUrl ?? '';
  }
}
```

### 4. 画像キャッシュ戦略

```dart
// cached_network_imageの設定
CachedNetworkImage(
  imageUrl: sentence.getDisplayImageUrl(),
  memCacheWidth: 800,
  memCacheHeight: 450,
  maxWidthDiskCache: 1200,
  maxHeightDiskCache: 675,
  cacheKey: 'sentence_${sentence.id}_medium',
  placeholder: (context, url) => ShimmerPlaceholder(),
  errorWidget: (context, url, error) => DefaultImage(),
)
```

## 画像生成ワークフロー

### 1. 画像生成オプション

#### オプションA: AI画像生成（DALL-E、Midjourney等）
- `image_prompt`フィールドを使用
- 外部APIで画像生成
- Supabase Storageにアップロード

#### オプションB: 手動アップロード
- 管理画面からアップロード
- バッチアップロードスクリプト

#### オプションC: ストック画像
- Unsplash、Pexels等のAPI
- 自動的に適切な画像を取得

### 2. バッチアップロードスクリプト

```dart
// scripts/upload_images.dart
Future<void> main() async {
  // 1. CSVから画像パスを読み込み
  // 2. 画像をリサイズ
  // 3. Supabase Storageにアップロード
  // 4. データベースを更新
}
```

## パフォーマンス最適化

### 1. 画像最適化

- **WebP形式**: 対応ブラウザで自動変換
- **遅延読み込み**: スクロール時に読み込み
- **プログレッシブJPEG**: 段階的表示

### 2. CDN活用

- Supabase Storageは自動的にCDN経由で配信
- キャッシュヘッダーの設定
- ETagの活用

### 3. プリロード戦略

```dart
// 次のページの画像をプリロード
void preloadNextPageImages(List<Sentence> sentences) {
  for (final sentence in sentences.take(5)) {
    precacheImage(
      CachedNetworkImageProvider(sentence.thumbnailUrl ?? ''),
      context,
    );
  }
}
```

## エラーハンドリング

### 1. 画像読み込み失敗

```dart
Widget buildImageWidget(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) {
    return DefaultImagePlaceholder();
  }
  
  return CachedNetworkImage(
    imageUrl: imageUrl,
    errorWidget: (context, url, error) {
      // エラーログ記録
      debugPrint('画像読み込みエラー: $url');
      return DefaultImagePlaceholder();
    },
  );
}
```

### 2. フォールバック画像

- デフォルト画像をアセットに配置
- カテゴリ別のデフォルト画像
- グラデーションプレースホルダー

## セキュリティ

### 1. 画像検証

- ファイル形式の検証（JPEG、PNGのみ）
- ファイルサイズ制限（10MB以下）
- 画像サイズの検証

### 2. アクセス制御

- 公開読み取りのみ許可
- アップロードは認証済みユーザーのみ（将来）

## 実装優先順位

### Phase 1: 基本実装
1. Supabase Storageバケット作成
2. 画像アップロードサービス実装
3. 画像表示の改善

### Phase 2: 最適化
4. 画像リサイズ機能
5. サムネイル生成
6. キャッシュ戦略の実装

### Phase 3: 高度な機能
7. バッチアップロードスクリプト
8. AI画像生成統合
9. 画像管理画面
