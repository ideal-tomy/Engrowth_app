# 画像アップロード手順書

## 概要

Engrowthアプリで使用する画像をSupabase Storageにアップロードするための手順書です。

## 前提条件

- Supabaseプロジェクトが作成済み
- Supabase Dashboardにアクセス可能
- 画像ファイルが準備済み

## ステップ1: フォルダ構造の準備

### 1.1 ローカルフォルダ構造

プロジェクトルートに以下のフォルダ構造を作成してください：

```
images/
├── sentences/
│   ├── {sentence_id}.jpg  (または .png)
│   └── ...
└── words/
    ├── {word_id}.jpg  (または .png)
    └── ...
```

### 1.2 画像ファイルの命名規則

#### 例文画像（2つの方法）

**方法A: 個別IDベース（推奨：個別画像の場合）**
- **ファイル名**: `{sentence_id}.jpg` または `{sentence_id}.png`
- **例**: `550e8400-e29b-41d4-a716-446655440000.jpg`
- **推奨サイズ**: 1920x1080 (16:9)
- **形式**: JPEG（推奨）またはPNG

**方法B: Group名ベース（推奨：グループ単位で同じ画像を使用する場合）**
- **ファイル名**: `{group}.png`
- **例**: `S-001.png`, `S-002.png`
- **推奨サイズ**: 1920x1080 (16:9)
- **形式**: PNG（推奨）またはJPEG
- **注意**: この方法の場合、`ImageURL`カラムが空でも自動的にGroup名から画像URLが生成されます

#### 単語画像
- **ファイル名**: `{word_id}.jpg` または `{word_id}.png`
- **例**: `550e8400-e29b-41d4-a716-446655440000.jpg`
- **推奨サイズ**: 800x800 (1:1)
- **形式**: JPEG（推奨）またはPNG

### 1.3 画像ファイルの準備

1. **例文画像の準備**
   - 各例文に対応する画像を用意
   - 画像は例文のシーンや状況を表現するもの
   - `image_prompt`フィールドを参考に画像を生成・選択

2. **単語画像の準備**
   - 各単語に対応する画像を用意
   - 単語の意味を視覚的に表現するもの
   - シンプルで分かりやすい画像が推奨

## ステップ2: Supabase Storage設定

### 2.1 バケットの作成

1. Supabase Dashboardにログイン
2. プロジェクトを選択
3. 左メニューから「Storage」をクリック
4. 「New bucket」ボタンをクリック
5. 以下の2つのバケットを作成：

#### バケット1: `sentences-images`
- **Name**: `sentences-images`
- **Public bucket**: ✅ チェック（公開バケット）
- **File size limit**: 10MB
- **Allowed MIME types**: `image/jpeg, image/png`

#### バケット2: `words-images`
- **Name**: `words-images`
- **Public bucket**: ✅ チェック（公開バケット）
- **File size limit**: 10MB
- **Allowed MIME types**: `image/jpeg, image/png`

### 2.2 ストレージポリシーの設定

**重要**: バケット作成後、必ずポリシーを設定してください。

プロジェクトルートの `supabase_storage_setup.sql` をSupabase Dashboard → SQL Editorで実行してください。

または、以下のSQLを直接実行：

```sql
-- 公開読み取りポリシー（sentences-images）
CREATE POLICY "Public Access for sentences-images"
ON storage.objects FOR SELECT
USING (bucket_id = 'sentences-images');

-- 公開読み取りポリシー（words-images）
CREATE POLICY "Public Access for words-images"
ON storage.objects FOR SELECT
USING (bucket_id = 'words-images');

-- 認証済みユーザーのアップロード許可
CREATE POLICY "Authenticated users can upload to sentences-images"
ON storage.objects FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated' AND
  bucket_id = 'sentences-images'
);

CREATE POLICY "Authenticated users can upload to words-images"
ON storage.objects FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated' AND
  bucket_id = 'words-images'
);
```

### 2.3 CORS設定（オプション）

Supabase Dashboard → Storage → Settings → CORS Configuration:

```json
{
  "allowedOrigins": ["*"],
  "allowedMethods": ["GET", "HEAD"],
  "allowedHeaders": ["*"],
  "maxAge": 3600
}
```

## ステップ3: 画像のアップロード方法

### 方法A: Supabase Dashboardから手動アップロード（推奨：少量の場合）

#### A-1: 個別IDベースの場合

1. Supabase Dashboard → Storage → `sentences-images`（または`words-images`）を開く
2. 「Upload file」ボタンをクリック
3. 画像ファイルを選択
4. ファイル名を`{sentence_id}.jpg`の形式に変更
5. 「Upload」をクリック
6. アップロード後、ファイルをクリックして公開URLをコピー
7. データベースの`image_url`フィールドを更新

#### A-2: Group名ベースの場合（推奨）

1. Supabase Dashboard → Storage → `sentences-images`を開く
2. 「Upload file」ボタンをクリック
3. 画像ファイルを選択
4. ファイル名を`{group}.png`の形式に変更（例: `S-001.png`）
5. 「Upload」をクリック
6. **注意**: この方法の場合、データベースの`image_url`フィールドを更新する必要はありません。アプリが自動的にGroup名から画像URLを生成します

### 方法B: バッチアップロードスクリプト（推奨：大量の場合）

#### 3.1 画像ファイルの配置

1. プロジェクトルートに以下のフォルダ構造を作成：
   ```
   images/
   ├── sentences/
   │   ├── {sentence_id}.jpg
   │   └── ...
   └── words/
       ├── {word_id}.jpg
       └── ...
   ```

2. 画像ファイルを配置
   - 例文画像: `images/sentences/{sentence_id}.jpg`
   - 単語画像: `images/words/{word_id}.jpg`
   - ファイル名はデータベースのIDと一致させる

3. **重要**: ファイル名のIDは、Supabaseの`sentences`テーブルまたは`words`テーブルの`id`カラムの値と完全に一致させる必要があります

#### 3.2 スクリプトの実行

**個別IDベースの場合:**
```bash
# 例文画像のアップロード（個別ID）
dart run scripts/upload_sentence_images.dart

# 単語画像のアップロード
dart run scripts/upload_word_images.dart
```

**Group名ベースの場合（推奨）:**
```bash
# 例文画像のアップロード（Group名）
dart run scripts/upload_group_images.dart
```

**注意**: Group名ベースのアップロードの場合、データベースの更新は不要です。アプリが自動的にGroup名から画像URLを生成します。

#### 3.3 スクリプトの動作

**個別IDベース（upload_sentence_images.dart）:**
1. `images/sentences/`フォルダから画像ファイルを読み込み
2. ファイル名からIDを抽出
3. データベースで対応する例文を検索
4. 画像を3つのサイズ（original, medium, thumbnail）にリサイズ
5. Supabase Storageにアップロード
6. データベースの`image_url`フィールドを更新

**Group名ベース（upload_group_images.dart）:**
1. `images/sentences/`フォルダから画像ファイルを読み込み
2. ファイル名からGroup名を抽出（例: `S-001.png` → `S-001`）
3. Supabase Storageに直接アップロード（`{group}.png`として保存）
4. **データベースの更新は不要**（アプリが自動的にGroup名からURLを生成）

#### 3.4 実行結果の確認

スクリプト実行後、以下の情報が表示されます：
- 成功したアップロード数
- 失敗したアップロード数
- エラーの詳細（失敗した場合）

## ステップ4: データベースの更新

### 4.1 自動更新（推奨）

バッチアップロードスクリプト（方法B）を使用した場合、データベースは自動的に更新されます。

### 4.2 手動更新（方法Aを使用した場合）

手動でアップロードした場合は、各例文の`image_url`フィールドを手動で更新する必要があります：

```sql
-- 例: 例文IDと画像URLのマッピング
UPDATE sentences
SET image_url = 'https://your-project.supabase.co/storage/v1/object/public/sentences-images/{sentence_id}/medium.jpg'
WHERE id = '{sentence_id}';
```

**注意**: スクリプトを使用した場合、画像は以下の構造で保存されます：
- `{sentence_id}/original.jpg` (1920x1080)
- `{sentence_id}/medium.jpg` (800x450) ← デフォルトで使用
- `{sentence_id}/thumbnail.jpg` (300x169)

### 4.3 単語テーブルの更新（将来の拡張）

```sql
-- 単語テーブルにimage_urlカラムを追加（まだない場合）
ALTER TABLE words
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- 画像URLを更新
UPDATE words
SET image_url = 'https://your-project.supabase.co/storage/v1/object/public/words-images/{word_id}/medium.jpg'
WHERE id = '{word_id}';
```

## ステップ5: 画像URLの確認

### 5.1 公開URLの形式

バッチアップロードスクリプトを使用した場合、画像は以下の構造で保存されます：

```
https://{project-ref}.supabase.co/storage/v1/object/public/{bucket-name}/{item-id}/{size}.jpg
```

例（mediumサイズ）：
```
https://abcdefghijklmnop.supabase.co/storage/v1/object/public/sentences-images/550e8400-e29b-41d4-a716-446655440000/medium.jpg
```

利用可能なサイズ：
- `original.jpg` - オリジナルサイズ
- `medium.jpg` - 中サイズ（デフォルトで使用）
- `thumbnail.jpg` - サムネイルサイズ

### 5.2 画像の確認

1. **ブラウザで確認**
   - 公開URLにアクセス
   - 画像が正しく表示されることを確認

2. **アプリで確認**
   - アプリを起動
   - 例文リストまたは単語リストで画像が表示されることを確認
   - 学習モードで画像が表示されることを確認

3. **データベースで確認**
   ```sql
   -- 画像URLが設定されている例文を確認
   SELECT id, dialogue_en, image_url 
   FROM sentences 
   WHERE image_url IS NOT NULL 
   LIMIT 10;
   ```

## トラブルシューティング

### 画像が表示されない

1. **公開URLが正しいか確認**
   - URLに`/public/`が含まれているか
   - バケット名が正しいか

2. **バケットが公開設定か確認**
   - Supabase Dashboard → Storage → バケット設定
   - 「Public bucket」が有効になっているか

3. **ファイル名が正しいか確認**
   - ファイル名に特殊文字が含まれていないか
   - 拡張子が正しいか（.jpg, .png）

4. **CORS設定を確認**
   - ブラウザのコンソールでエラーを確認
   - CORSエラーの場合は設定を見直す

### アップロードが失敗する

1. **ファイルサイズを確認**
   - 10MB以下であることを確認

2. **ファイル形式を確認**
   - JPEGまたはPNG形式であることを確認

3. **権限を確認**
   - ストレージポリシーが正しく設定されているか

## 画像の最適化

### 推奨設定

- **JPEG品質**: 85%（バランス重視）
- **PNG圧縮**: 最適化ツールを使用
- **画像サイズ**: 
  - 例文: 1920x1080（16:9）
  - 単語: 800x800（1:1）

### 画像最適化ツール

- **オンライン**: TinyPNG, Squoosh
- **コマンドライン**: ImageMagick, jpegoptim

## 次のステップ

画像のアップロードが完了したら：

1. アプリを起動して画像が表示されることを確認
2. 画像の読み込み速度を確認
3. 必要に応じて画像を最適化

## 注意事項

- 画像ファイルは適切なライセンスのものを使用してください
- 個人情報や機密情報が含まれる画像は使用しないでください
- 画像の著作権を確認してください
- ファイル名はデータベースのIDと完全に一致させる必要があります
- 画像ファイルのサイズは10MB以下にしてください
- JPEGまたはPNG形式のみサポートされています

## クイックスタート

### 最短手順（バッチアップロード）

1. **Supabase Storage設定**
   - Supabase Dashboardでバケット作成（`sentences-images`, `words-images`）
   - `supabase_storage_setup.sql`を実行

2. **画像ファイルの準備**
   ```bash
   # フォルダ作成
   mkdir -p images/sentences
   mkdir -p images/words
   
   # 画像ファイルを配置（ファイル名は{sentence_id}.jpg形式）
   # images/sentences/{sentence_id}.jpg
   # images/words/{word_id}.jpg
   ```

3. **アップロード実行**
   ```bash
   # 例文画像
   dart run scripts/upload_sentence_images.dart
   
   # 単語画像
   dart run scripts/upload_word_images.dart
   ```

4. **確認**
   - アプリを起動して画像が表示されることを確認
