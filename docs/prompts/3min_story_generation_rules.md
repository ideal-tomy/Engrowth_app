# 3分英会話ストーリー生成ルール

AIに3分英会話を生成させる際、このドキュメントを参照させてください。Cursorで `@docs/prompts/3min_story_generation_rules.md` を指定して依頼します。

---

## 0. 趣旨（生成時に必ず守る）

- **3分英会話 = 1つのシチュエーションで、3分間続く「1本の会話」** である。断片的な30秒会話の寄せ集めではなく、**最初から最後まで一続きのやり取り**（約300〜450語）を書く。
- ユーザーはこの **3分の一続き** を音声で聴き・暗記し、似た場面で何を言えばよいかの慣れを通じて英会話を習得する。
- 1000単語リストを活用し、指定した単語レンジから **1ストーリーあたり10〜15語** を自然に組み込み、重複を抑えながら量産する。
- データ上は「チャンク」に分けて登録するが、**内容としては1本の3分会話を書いてから、流れの良いところで3〜5に分割**する。

---

## 1. ストーリー仕様

| 項目 | 仕様 |
|------|------|
| 長さ | **1本で** 3分程度（約300〜450語の会話文）。一続きの対話として成立させる。 |
| 単語 | 指定した単語リスト（1000単語）から **1ストーリーあたり10〜15語** を自然に組み込む。未使用の単語を優先する。 |
| 形式 | 会話形式（A/B の役割で発話を交互に）。1シチュエーションで最初から最後までつながる。 |

---

## 2. データ構造

### story_sequences（1ストーリー＝1行）

| カラム | 型 | 例 |
|--------|------|-----|
| title | TEXT | "カフェでの注文" |
| description | TEXT | "カフェでコーヒーを注文する会話" |
| total_duration_minutes | INTEGER | 3 |
| display_order | INTEGER | 0 |

### conversations（1ストーリーあたり3〜5チャンク）

**1ストーリー全体で約3分の一続きの会話**を、聴きやすく・練習しやすいように **3〜5個のチャンク** に分割する。各チャンクは30〜45秒程度の「塊」だが、**つなげると1本の3分会話**になる。

| カラム | 型 | 例 |
|--------|------|-----|
| story_sequence_id | UUID | （INSERT後取得） |
| story_order | INTEGER | 1, 2, 3... |
| title | TEXT | "挨拶と席の確認" |
| description | TEXT | "店に入り、席を案内される" |

### conversation_utterances（各会話の発話）

| カラム | 型 | 例 |
|--------|------|-----|
| conversation_id | UUID | （INSERT後取得） |
| speaker_role | TEXT | 'A', 'B', 'C', 'system' |
| utterance_order | INTEGER | 1, 2, 3... |
| english_text | TEXT | "Hello. I'd like a coffee, please." |
| japanese_text | TEXT | "こんにちは。コーヒーをください。" |

---

## 3. JSON出力スキーマ（中間形式）

生成時はまずJSONで出力し、その後SQLに変換する。

```json
{
  "story_sequence": {
    "title": "ストーリーのタイトル",
    "description": "ストーリーの概要",
    "total_duration_minutes": 3,
    "display_order": 0
  },
  "conversations": [
    {
      "story_order": 1,
      "title": "チャンク1のタイトル",
      "description": "チャンク1の説明"
    },
    {
      "story_order": 2,
      "title": "チャンク2のタイトル",
      "description": "チャンク2の説明"
    }
  ],
  "utterances": [
    {
      "conversation_index": 0,
      "speaker_role": "A",
      "utterance_order": 1,
      "english_text": "Hello.",
      "japanese_text": "こんにちは。"
    },
    {
      "conversation_index": 0,
      "speaker_role": "B",
      "utterance_order": 2,
      "english_text": "Hi! Welcome.",
      "japanese_text": "はい！いらっしゃいませ。"
    }
  ]
}
```

- `conversation_index`: 0-based。どのconversationに属するか。
- `speaker_role`: 'A', 'B', 'C', 'system' のいずれか。

---

## 4. SQL出力ルール

1. **story_sequences** を INSERT し、`RETURNING id` で得た UUID を変数（例: `seq_id`）に保持。
2. 各 **conversations** を INSERT（`story_sequence_id` に上記 UUID を設定）、`RETURNING id` で得た UUID を conversation ごとに保持。
3. **conversation_utterances** を INSERT（`conversation_id` に上記の各 conversation の UUID を紐付け）。

Supabase PostgreSQL では、`INSERT ... RETURNING id` の結果を次の INSERT で使うには、複数ステートメントを1つのトランザクションで実行するか、`WITH` 句（CTE）を使う。

### SQL例（CTE使用）

```sql
WITH new_sequence AS (
  INSERT INTO story_sequences (title, description, total_duration_minutes, display_order)
  VALUES ('カフェでの注文', 'カフェでコーヒーを注文する会話', 3, 0)
  RETURNING id
),
conv1 AS (
  INSERT INTO conversations (story_sequence_id, story_order, title, description)
  SELECT id, 1, '挨拶と席の確認', '店に入り、席を案内される'
  FROM new_sequence
  RETURNING id
),
-- conv2, conv3... 同様
utterances_batch AS (
  INSERT INTO conversation_utterances (conversation_id, speaker_role, utterance_order, english_text, japanese_text)
  SELECT id, 'A', 1, 'Hello.', 'こんにちは。' FROM conv1
  UNION ALL
  SELECT id, 'B', 2, 'Hi! Welcome.', 'はい！いらっしゃいませ。' FROM conv1
  -- ...
)
SELECT 1;
```

---

## 5. プロンプト例（Cursorへの依頼）

### 単一ストーリー生成

```
@words_slot_001_050.csv を参照して、このリストの単語を優先的に（まだ登場していない語を中心に）、3分程度（約300〜450語）の会話形式のストーリーを1本作成してください。

出力は以下を含めてください：
1. JSON形式（story_sequence + conversations + utterances）
2. Supabaseに流し込む INSERT SQL（story_sequences → conversations → conversation_utterances の順で実行できる形式）

@docs/prompts/3min_story_generation_rules.md のルールに従ってください。
```

### 一括生成（複数ストーリー）

```
@words_master_1000.csv を参照して、次の範囲でストーリーを3本生成してください：
- 1本目: 単語1〜15を使用
- 2本目: 単語16〜30を使用
- 3本目: 単語31〜45を使用

各ストーリーは3分程度（約300〜450語）、会話形式とし、指定範囲の単語を10〜15語ずつ自然に組み込んでください。

出力は各ストーリーについて、JSON と Supabase用 INSERT SQL を生成してください。
@docs/prompts/3min_story_generation_rules.md のルールに従ってください。
```

### 半自動プロンプト（テーマ・単語レンジ・本数指定）

**1本 = 3分間続く一続きの会話**になるよう、テーマ名・単語レンジ・本数だけ指定して、`seed_story_coffee_shop.sql` の構造を真似たSQLを量産する場合：

```
@Engrowthアプリ英単語データ - 本番用 (1).csv と @supabase/migrations/seed_story_coffee_shop.sql を参照してください。

次の条件で3分英会話を1本作成し、同じフォーマット（WITH〜INSERT〜UNION ALL）のSQLファイルを生成してください。

- テーマ: 【挨拶】
- 単語レンジ: 1番〜50番を重点的に使用
- ファイル名: seed_story_greeting_01.sql
- 会話の長さ・チャンク数・フォーマットは seed_story_coffee_shop.sql と全く同じにしてください。
```

複数本まとめて依頼する例：

```
@Engrowthアプリ英単語データ - 本番用 (1).csv と @seed_story_coffee_shop.sql を参照して、
テーマ「挨拶」で3本の3分英会話を作成してください。
- 1本目: 単語1〜50、seed_story_greeting_01.sql
- 2本目: 単語51〜100、seed_story_greeting_02.sql
- 3本目: 単語101〜150、seed_story_greeting_03.sql
構造とフォーマットは seed_story_coffee_shop.sql に準拠し、各ファイルを個別に出力してください。
```

---

## 6. 検証プロンプト（生成後）

```
この会話テキスト（または生成したutterances）の中で、指定した単語リストのどの単語が使われたか抽出してください。リストの形式で出力し、10〜15語入っているか確認できるようにしてください。
```
