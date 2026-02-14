# 画像アップロード クイックスタート

## 概要

Engrowthアプリで画像を表示するための最短手順です。

## 前提条件

- Supabaseプロジェクトが作成済み
- `.env`ファイルにSupabase認証情報が設定済み
- 画像ファイルが準備済み

## ステップ1: Supabase Storage設定（5分）

### 1.1 バケットの作成

1. Supabase Dashboard → Storage → New bucket
2. 以下の2つのバケットを作成：

**バケット1: `sentences-images`**
- Name: `sentences-images`
- Public bucket: ✅ チェック
- File size limit: 10MB

**バケット2: `words-images`**
- Name: `words-images`
- Public bucket: ✅ チェック
- File size limit: 10MB

### 1.2 ポリシーの設定

Supabase Dashboard → SQL Editorで `supabase_storage_setup.sql` を実行

## ステップ2: 画像ファイルの準備（10分）

### 2.1 フォルダ構造の作成

プロジェクトルートに以下のフォルダを作成：

```bash
mkdir images
mkdir images/sentences
mkdir images/words
```

### 2.2 画像ファイルの配置

**方法A: Group名ベース（推奨・簡単）**
1. **例文画像**: `images/sentences/{group}.png`
   - ファイル名はSupabaseの`sentences`テーブルの`group`カラムの値と一致
   - 例: `S-001.png`, `S-002.png`
   - **メリット**: 同じGroupの例文は同じ画像を共有、データベース更新不要

**方法B: 個別IDベース**
1. **例文画像**: `images/sentences/{sentence_id}.jpg`
   - ファイル名はSupabaseの`sentences`テーブルの`id`カラムの値と一致
   - 例: `550e8400-e29b-41d4-a716-446655440000.jpg`

2. **単語画像**: `images/words/{word_id}.jpg`
   - ファイル名はSupabaseの`words`テーブルの`id`カラムの値と一致
   - 例: `550e8400-e29b-41d4-a716-446655440000.jpg`

### 2.3 IDの確認方法

Supabase Dashboard → Table EditorでIDを確認：

```sql
-- 例文IDを確認
SELECT id, dialogue_en FROM sentences LIMIT 10;

-- 単語IDを確認
SELECT id, word FROM words LIMIT 10;
```

## ステップ3: 画像のアップロード（5分）

### 3.1 例文画像のアップロード

**Group名ベース（推奨）:**
```bash
dart run scripts/upload_group_images.dart
```

**個別IDベース:**
```bash
dart run scripts/upload_sentence_images.dart
```

### 3.2 単語画像のアップロード

```bash
dart run scripts/upload_word_images.dart
```

### 3.3 実行結果の確認

スクリプト実行後、以下のような出力が表示されます：

```
📝 100件の例文を取得しました
🖼️  50個の画像ファイルが見つかりました
📤 アップロード中: Hello, how are you?...
✅ アップロード成功: 550e8400-e29b-41d4-a716-446655440000
...

📊 アップロード結果:
✅ 成功: 50件
❌ 失敗: 0件
```

## ステップ4: 動作確認（5分）

### 4.1 アプリの起動

```bash
flutter run
```

### 4.2 確認項目

1. **例文リスト画面**
   - 例文カードに画像が表示される
   - 画像が正しく読み込まれる

2. **学習モード**
   - 学習カードに画像が表示される
   - 画像が正しく読み込まれる

3. **単語リスト画面**（将来の拡張）
   - 単語カードに画像が表示される

## トラブルシューティング

### エラー: "画像フォルダが見つかりません"

**解決方法**:
```bash
# フォルダを作成
mkdir -p images/sentences
mkdir -p images/words
```

### エラー: "例文が見つかりません"

**原因**: ファイル名のIDがデータベースのIDと一致していない

**解決方法**:
1. Supabase DashboardでIDを確認
2. ファイル名を正しいIDに変更

### エラー: "バケットが見つかりません"

**解決方法**:
1. Supabase Dashboardでバケットが作成されているか確認
2. バケット名が正確か確認（`sentences-images`, `words-images`）

### 画像が表示されない

**確認項目**:
1. データベースの`image_url`フィールドが更新されているか
2. 公開URLにブラウザでアクセスできるか
3. バケットが公開設定になっているか

## 次のステップ

画像のアップロードが完了したら：

1. アプリで画像が正しく表示されることを確認
2. 必要に応じて画像を最適化
3. 詳細な手順は `docs/IMAGE_UPLOAD_GUIDE.md` を参照
