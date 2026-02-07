# 画像表示の動作確認手順

## 概要

例文一覧で画像が正しく表示されることを確認するための手順です。

## 実装内容

### 1. 自動画像URL生成

- `ImageURL`カラムが空の場合、`Group`名（例: `S-001`）から自動的に画像URLを生成
- 生成されるURL: `https://{project}.supabase.co/storage/v1/object/public/sentences-images/{group}.png`
- 例: `https://abcdefghijklmnop.supabase.co/storage/v1/object/public/sentences-images/S-001.png`

### 2. プレースホルダー表示

- Supabase Storageに画像が存在しない場合、おしゃれなプレースホルダーを表示
- グラデーション背景 + パターン + アイコン

## 動作確認手順

### ステップ1: Supabase Storageに画像をアップロード

#### 方法A: Group名ベース（推奨）

1. **画像ファイルの準備**
   ```bash
   # フォルダに画像を配置
   # ファイル名: {group}.png（例: S-001.png）
   images/sentences/S-001.png
   images/sentences/S-002.png
   ```

2. **アップロード実行**
   ```bash
   dart run scripts/upload_group_images.dart
   ```

#### 方法B: Supabase Dashboardから手動アップロード

1. Supabase Dashboard → Storage → `sentences-images`
2. 「Upload file」をクリック
3. 画像ファイルを選択
4. ファイル名を`{group}.png`に変更（例: `S-001.png`）
5. 「Upload」をクリック

### ステップ2: アプリで確認

1. **アプリを起動**
   ```bash
   flutter run
   ```

2. **例文リスト画面で確認**
   - 例文リスト画面を開く
   - Group名が設定されている例文のカードに画像が表示されることを確認
   - `ImageURL`カラムが空でも画像が表示されることを確認

3. **学習モードで確認**
   - 学習モードを開く
   - 画像が正しく表示されることを確認

### ステップ3: プレースホルダーの確認

画像が存在しないGroupの場合：

1. **画像をアップロードしないGroupの例文を確認**
   - 例文リストで、画像がアップロードされていないGroupの例文を探す
   - プレースホルダー（グラデーション背景）が表示されることを確認

2. **画像URLが空の例文を確認**
   - `ImageURL`カラムが空で、`Group`も空の例文
   - プレースホルダーが表示されることを確認

## 確認項目チェックリスト

- [ ] Supabase Storageに画像がアップロードされている
- [ ] 例文リストで画像が表示される
- [ ] `ImageURL`カラムが空でもGroup名から画像が表示される
- [ ] 学習モードで画像が表示される
- [ ] 画像が存在しない場合、プレースホルダーが表示される
- [ ] プレースホルダーがおしゃれなデザインで表示される
- [ ] 画像の読み込み中にスケルトンUIが表示される

## トラブルシューティング

### 画像が表示されない

1. **Supabase Storageを確認**
   - バケット`sentences-images`が存在するか
   - 画像ファイルが正しくアップロードされているか
   - ファイル名が`{group}.png`形式か（例: `S-001.png`）

2. **データベースを確認**
   ```sql
   -- Group名を確認
   SELECT id, "group", dialogue_en FROM sentences LIMIT 10;
   ```

3. **URLを確認**
   - ブラウザで直接URLにアクセスして画像が表示されるか
   - URL形式: `https://{project}.supabase.co/storage/v1/object/public/sentences-images/{group}.png`

### プレースホルダーが表示されない

- 画像URLが空で、Group名も空の場合は、プレースホルダーが表示されます
- 画像の読み込みエラー時にもプレースホルダーが表示されます

## 画像URLの優先順位

アプリは以下の順序で画像URLを決定します：

1. **`image_url`カラムが設定されている場合**
   - そのURLをそのまま使用

2. **`image_url`が空で、`group`が設定されている場合**
   - Group名から自動生成: `{supabase_url}/storage/v1/object/public/sentences-images/{group}.png`

3. **どちらも空の場合**
   - プレースホルダーを表示

## 次のステップ

画像表示が確認できたら：

1. 残りの画像を順次アップロード
2. 画像の最適化（必要に応じて）
3. パフォーマンスの確認
