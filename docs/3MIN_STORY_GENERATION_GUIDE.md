# 3分英会話ストーリー生成ガイド

1000単語マスターリストを前提に、重複を抑えつつ3分英会話を生成し、Supabase に投入するまでの手順です。

## 3分英会話の趣旨（建て付け）

- **メイン**: **3分間続く1本の英会話**を、1つのシチュエーションで作成する。ユーザーはその一続きの会話を音声で聴き・暗記し、英会話に慣れて習得していく。
- **1ストーリー = 1シチュエーション = 約3分（300〜450語）の連続したやり取り**。例: 「カフェでの注文」「初めての挨拶」など、場面が一つに決まっている一続きの対話。
- **チャンク（分割）について**: データ上は1ストーリーを **3〜5個のチャンク**（conversations）に分けて登録している。**全部つなげると約3分の1本**になる。チャンクは「3分を一度に覚えにくい人向けに、区切って聴いたり練習したりする」ための分割であり、**本質はあくまで3分の一続きの会話**である。
- アプリの「3分ストーリー」では、**1枚のカード = 1本の3分ストーリー**。タップするとそのストーリーの最初（または続き）から再生でき、「次のパートを聴く」で最後まで聴けば3分通しになる。

## 前提

- 単語リスト: `Engrowthアプリ英単語データ - 本番用 (1).csv`（プロジェクトルート）または [assets/csv/words_master_1000.csv](../assets/csv/words_master_1000.csv)
- プロンプト定義: [docs/prompts/3min_story_generation_rules.md](prompts/3min_story_generation_rules.md)
- プロジェクトルール: [PROJECT_RULES.md](../PROJECT_RULES.md) の「3分英会話ストーリー生成」セクション
- DB: `story_sequences`, `conversations`, `conversation_utterances` テーブル（マイグレーション済み）

## クイックスタート

### 1. 単語リストの準備

**Engrowthアプリ英単語データを使用する場合（推奨）**:

```bash
# Engrowth CSV を words_master_1000.csv に変換
dart run scripts/import_engrowth_vocab.dart

# 使用台帳を生成
dart run scripts/build_vocab_ledger.dart
```

または、Engrowth CSV から直接台帳を生成:
```bash
dart run scripts/build_vocab_ledger.dart "Engrowthアプリ英単語データ - 本番用 (1).csv"
```

**手動で用意する場合**: `assets/csv/words_master_1000.csv` に `word,meaning,part_of_speech` 形式で1000語を登録し、`build_vocab_ledger.dart` を実行。

### 2. スロット分割（任意）

```bash
dart run scripts/split_words_into_slots.dart
```

`assets/csv/words_slot_001_050.csv` など50語単位のファイルが生成されます。

### 3. Cursorでストーリー生成

1. Cursorのチャットで `@assets/csv/words_slot_001_050.csv` と `@docs/prompts/3min_story_generation_rules.md` を指定
2. 次のプロンプトを送信:

```
このリストの単語を優先的に（まだ登場していない語を中心に）、3分程度（約300〜450語）の会話形式のストーリーを1本作成してください。

出力は以下を含めてください：
1. JSON形式（story_sequence + conversations + utterances）
2. Supabaseに流し込む INSERT SQL（story_sequences → conversations → conversation_utterances の順で実行できる形式）
```

### 4. 検証（任意）

生成後、次のプロンプトで使用単語を確認:

```
この会話テキストの中で、指定した単語リストのどの単語が使われたか抽出してください。
```

### 5. Supabaseへ投入

1. Supabase Dashboard → SQL Editor を開く
2. 生成された INSERT SQL を貼り付け、または `supabase/migrations/seed_story_*.sql` を実行
3. 1本ずつ実行し、一覧表示・再生・再開が崩れないか確認後、残りを投入

**注意**: 「3分ストーリー」として表示されるのは、**story_sequences に登録し、その story_sequence_id を付けた conversations（チャンク）だけ**です。30秒程度の単発会話を conversations にだけ入れても story_sequence_id が無いと3分ストーリー一覧には出ません。**必ず「1本の3分会話」として story_sequences 1件 + 複数 conversations（チャンク）をセットで投入**してください。

**9本一括投入の手順（推奨）**

1. Supabase Dashboard → SQL Editor を開く
2. 次の順に1本ずつ実行し、アプリで一覧・再生・再開を確認してから次へ：
   - 既存: `supabase/migrations/seed_story_coffee_shop.sql`（カフェ01）
   - 挨拶: `seed_story_greeting_01.sql`, `02.sql`, `03.sql`
   - ホテル: `seed_story_hotel_01.sql`, `02.sql`, `03.sql`
   - カフェ: `seed_story_cafe_02.sql`, `03.sql`
3. 全9本投入後、ストーリー一覧に表示されることを確認

## スロット管理

使用済みスロットを記録することで、重複を防ぎます。

- テンプレート: [docs/slot_usage_template.csv](slot_usage_template.csv)
- スプレッドシートにコピーして、「スロット番号・ストーリータイトル・使用単語リスト」を記録

## 一括生成

複数ストーリーを一度に生成する場合:

```
@words_master_1000.csv を参照して、次の範囲でストーリーを3本生成してください：
- 1本目: 単語1〜15を使用
- 2本目: 単語16〜30を使用
- 3本目: 単語31〜45を使用

各ストーリーは3分程度、会話形式とし、指定範囲の単語を10〜15語ずつ自然に組み込んでください。
出力は各ストーリーについて、JSON と Supabase用 INSERT SQL を生成してください。
```

## 雛形運用（差し替え項目リスト）

`seed_story_coffee_shop.sql` を基準に、次を差し替えて新規ストーリーを作成する。

| 項目 | 例 | 説明 |
|------|-----|------|
| ストーリータイトル | カフェでの注文 | story_sequences.title |
| ストーリー説明 | カフェでコーヒーとサンドイッチを... | story_sequences.description |
| 使用単語レンジ | 30-155 | コメント・検証用 |
| チャンク1〜4の title | 挨拶と注文の開始 等 | conversations.title |
| チャンク1〜4の description | 店に入り、注文を始める 等 | conversations.description |
| theme | 挨拶 / ホテル / カフェ | conversations.theme |
| situation_type | student | conversations.situation_type |
| 会話本文（A/B役） | english_text, japanese_text | conversation_utterances |

### 命名規約
- `seed_story_<theme>_<nn>.sql`（例: seed_story_greeting_01.sql, seed_story_hotel_02.sql）

### テーマ別単語レンジ割当（重複抑制）
- 挨拶01: 1-50、挨拶02: 51-100、挨拶03: 101-150
- ホテル01: 151-200、ホテル02: 201-250、ホテル03: 251-300
- カフェ01: 既存（30-155）、カフェ02: 301-350、カフェ03: 351-400

## 9本ストーリー検証結果（テーマ別3分英会話量産）

| ファイル | テーマ | 単語レンジ | 形式 | チャンク数 |
|----------|--------|------------|------|------------|
| seed_story_coffee_shop.sql | カフェ | 30-155 | OK | 4 |
| seed_story_greeting_01.sql | 挨拶 | 1-50 | OK | 4 |
| seed_story_greeting_02.sql | 挨拶 | 51-100 | OK | 4 |
| seed_story_greeting_03.sql | 挨拶 | 101-150 | OK | 4 |
| seed_story_hotel_01.sql | ホテル | 151-200 | OK | 4 |
| seed_story_hotel_02.sql | ホテル | 201-250 | OK | 4 |
| seed_story_hotel_03.sql | ホテル | 251-300 | OK | 4 |
| seed_story_cafe_02.sql | カフェ | 301-350 | OK | 4 |
| seed_story_cafe_03.sql | カフェ | 351-400 | OK | 4 |

**形式チェック**: story_sequences 1件、conversations 4件、utterance_order 連番、theme 一致済み。

## タスクチェックリスト

**85本分の進捗管理**: [docs/3MIN_STORY_TASK_CHECKLIST.md](3MIN_STORY_TASK_CHECKLIST.md)

シチュエーション別に完了チェック・次着手タスクが一覧化されています。順次進める際の参照用です。

### ファイル配置ルール

| 状態 | 保存先 |
|------|--------|
| 新規生成・未実行 | `supabase/migrations/seed_story_<theme>_<nn>.sql` |
| 実行済み・アーカイブ | `docs/archive/seed_stories/` |
| 雛形（参照用） | `docs/archive/seed_stories/seed_story_coffee_shop.sql` |

Supabaseで実行したSQLは `docs/archive/seed_stories/` へ移動し、**次に実行すべきSQLが migrations にだけ残る**ようにすると管理しやすくなります。

---

## 85本量産フロー（重複抑制・台帳運用）

全17シチュエーション × 各5本 = 85本を、Engrowth 1000語の網羅率を高めつつ非重要語の重複を抑えて生成する運用。

### 準備

1. **単語台帳を構築**

```bash
dart run scripts/build_vocab_ledger.dart
```

`assets/csv/words_usage_ledger.csv` が生成される（word_id, word, is_core, used_count, used_in_story_ids）。

2. **シチュエーション台帳の確認**

`docs/story_generation_manifest.csv` に全17シチュエーションが登録されている。

### 生成サイクル（1本ごと）

1. **プロンプト生成**

```bash
dart run scripts/generate_batch_prompt.dart <situation_id> <story_index>
```

例: `dart run scripts/generate_batch_prompt.dart 1 1` → greeting_biz の1本目

2. **CursorでSQLを生成**

出力されたプロンプトを Cursor に貼り付け、生成された SQL を `supabase/migrations/seed_story_<theme>_<nn>.sql` に保存。（雛形は `docs/archive/seed_stories/seed_story_coffee_shop.sql` を参照）

3. **検証**

```bash
dart run scripts/validate_story_batch.dart supabase/migrations/seed_story_<theme>_<nn>.sql
```

語数（300〜450）、チャンク数（3〜5）、utterance_order 連番を確認。NG なら生成をやり直す。

4. **Supabaseへ投入**

Supabase Dashboard → SQL Editor で該当 SQL を実行。アプリで一覧・再生・チャンク遷移を確認。実行後、必要に応じて `docs/archive/seed_stories/` へ移動。

5. **単語台帳を更新**

```bash
dart run scripts/word_allocator.dart <theme_slug> <story_index> --update <theme_slug>_<nn>
```

例: `dart run scripts/word_allocator.dart greeting_biz 1 --update greeting_biz_01`

これにより次回の割当で未使用語が優先される。

### テーマ単位の投入順序（推奨）

シチュエーション1→2→…→17 の順に、各テーマ5本を連続で生成・投入してから次テーマへ。同一テーマ内で文脈の一貫性を保ちやすい。

### タスク一覧の確認

```bash
dart run scripts/run_batch_generation.dart --list
```

85本分のタスク一覧が表示される。

### 量産用プロンプトテンプレート

[docs/prompts/3min_story_batch_generation_template.md](prompts/3min_story_batch_generation_template.md) を参照。

---

## 関連ファイル

- [docs/prompts/3min_story_generation_rules.md](prompts/3min_story_generation_rules.md) - AI向けルール定義
- [docs/prompts/3min_story_batch_generation_template.md](prompts/3min_story_batch_generation_template.md) - 量産用プロンプト
- [docs/story_generation_manifest.csv](story_generation_manifest.csv) - シチュエーション台帳
- [assets/csv/words_usage_ledger.csv](../assets/csv/words_usage_ledger.csv) - 単語使用台帳
- [assets/csv/README_WORDS_MASTER.md](../assets/csv/README_WORDS_MASTER.md) - 単語リストの説明
- [docs/archive/seed_stories/seed_story_coffee_shop.sql](archive/seed_stories/seed_story_coffee_shop.sql) - 基準雛形
