# 3分英会話 量産用プロンプトテンプレート

本テンプレートは [3min_story_generation_rules.md](3min_story_generation_rules.md) をベースに、85本量産のための必須出力・単語配分・検証項目を追加したものです。

---

## 1. ベースルール

[3min_story_generation_rules.md](3min_story_generation_rules.md) の **0. 趣旨** および **1. ストーリー仕様** に従う。

- 1本 = 3分間続く一続きの会話（約300〜450語）
- 会話形式（A/B 役割）
- 1ストーリーあたり指定単語から10〜15語を自然に組み込む
- チャンクは3〜5個に分割（流れの良いところで区切る）

---

## 2. 単語割当の取得

生成前に以下のコマンドで割当単語を取得する:

```bash
dart run scripts/word_allocator.dart <theme_slug> <story_index>
```

例: `dart run scripts/word_allocator.dart greeting_biz 1`

出力の単語リストを **必ず10〜15語** 自然に会話に組み込む。未使用語を最優先し、重要語（top200）は自然な会話のため必要に応じて再使用可。

---

## 3. 必須出力（生成後）

各ストーリー生成後、以下のブロックを **必ず** 出力する。

```markdown
## 検証出力

### used_target_words
（今回意図的に組み込んだ10〜15語のリスト。カンマ区切り）
例: hello, coffee, please, order, menu, thank, welcome, seat, water, sandwich, bill, pay

### used_non_target_key_words
（重要語以外で、指定リストに含まれないが偶発的に使った語。重複把握用。該当なければ空）
例: （空） または item, receipt

### continuity_check
（3分一続き性の自己チェック結果）
- [OK] 冒頭・中盤・終盤が一つの会話としてつながっている
- [OK] チャンク間のつなぎが自然
- [OK] 語数は300〜450の範囲
```

---

## 4. Cursorプロンプト（量産用）

### 単一ストーリー生成

```
@assets/csv/words_usage_ledger.csv と @docs/story_generation_manifest.csv を参照してください。

次の条件で3分英会話を1本作成してください。

- シチュエーション: 【{title_seed}】（{overview_seed}）
- theme_slug: {theme_slug}
- 割当単語: 以下の単語を10〜15語、自然に会話に組み込んでください。
  {allocated_words}

- 出力:
  1. JSON形式（story_sequence + conversations + utterances）
  2. Supabase用 INSERT SQL（seed_story_coffee_shop.sql の構造に準拠）
  3. 検証出力（used_target_words, used_non_target_key_words, continuity_check）

- ファイル名: seed_story_{theme_slug}_{nn}.sql
- 会話の長さ・チャンク数・フォーマットは seed_story_coffee_shop.sql と同様にしてください。

@docs/prompts/3min_story_generation_rules.md と @docs/prompts/3min_story_batch_generation_template.md のルールに従ってください。
```

### 差し替え項目

| プレースホルダ | 説明 | 例 |
|----------------|------|-----|
| {title_seed} | manifest の title_seed | ビジネスシーンでの初対面の挨拶と会話 |
| {overview_seed} | manifest の overview_seed | 新しいプロジェクトチームに... |
| {theme_slug} | manifest の theme_slug | greeting_biz |
| {allocated_words} | word_allocator の出力 | hello, coffee, please, ... |
| {nn} | 2桁の通し番号 | 01, 02, 03, 04, 05 |

---

## 5. 台帳更新

生成・検証OK後、以下のコマンドで単語使用台帳を更新する:

```bash
dart run scripts/word_allocator.dart <theme_slug> <story_index> --update <story_id>
```

例: `dart run scripts/word_allocator.dart greeting_biz 1 --update greeting_biz_01`

---

## 6. 雛形参照

SQLの雛形は [supabase/migrations/seed_story_coffee_shop.sql](../../supabase/migrations/seed_story_coffee_shop.sql) に準拠する。

- story_sequences: title, description, total_duration_minutes, display_order
- conversations: story_sequence_id, story_order, title, description, situation_type, theme
- conversation_utterances: conversation_id, speaker_role, utterance_order, english_text, japanese_text
