# 便利フレーズ（センテンス）のセットアップ

## 概要

「道を尋ねる」「接客」など、こう言いたいときに便利なフレーズを検索できる機能です。センテンス一覧画面で、日本語の意図（道を尋ねる、接客）で検索すると対応する英語フレーズが表示されます。

## データ投入方法

### 方法1: SQLで投入（推奨）

Supabase Dashboard → SQL Editor で以下を実行：

```bash
# プロジェクトの migration ファイルを参照
supabase/migrations/database_useful_phrases_sentences.sql
```

または SQL Editor に直接以下を貼り付けて実行：

```sql
INSERT INTO sentences (id, dialogue_en, dialogue_jp, category_tag, scene_setting, target_words, "group", difficulty, created_at)
VALUES
  (uuid_generate_v4(), 'Excuse me, where is the nearest station?', 'すみません、最寄りの駅はどこですか？', '道を尋ねる', '街中', 'train station / where is', '便利フレーズ', 1, NOW()),
  -- ... (ファイル参照)
```

### 方法2: CSVでインポート

1. `assets/csv/useful_phrases_sentences.csv` を用意
2. Supabase Dashboard → Table Editor → `sentences` を選択
3. Import data from CSV でアップロード
4. カラムマッピング: dialogue_en, dialogue_jp, category_tag, scene_setting, target_words, group を対応付け

※ id, created_at は Supabase が自動生成する場合があります。CSV に含めない場合はデフォルトが使われます。

## 検索の仕組み

- **category_tag**: 「道を尋ねる」「接客」など意図を表すタグ。検索ヒット＆カテゴリチップでフィルタ可能
- **scene_setting**: シーン（街中、店舗など）
- **target_words**: 重要単語・キーワード

## カスタムフレーズの追加

sentences テーブルに以下のカラムでレコードを追加：

| カラム | 説明 | 例 |
|--------|------|-----|
| dialogue_en | 英語文 | Excuse me, where is ~? |
| dialogue_jp | 日本語訳 | すみません、～はどこですか？ |
| category_tag | 意図タグ（検索ヒット） | 道を尋ねる, 接客 |
| scene_setting | シーン | 街中, 店舗 |
| target_words | 重要単語 | where is / station |
| group | グループ名 | 便利フレーズ |
