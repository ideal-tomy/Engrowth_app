# 3分英会話ストーリー生成ガイド

1000単語マスターリストを前提に、重複を抑えつつ3分英会話を生成し、Supabase に投入するまでの手順です。

## 前提

- 単語リスト: [assets/csv/words_master_1000.csv](../assets/csv/words_master_1000.csv) に1000語を登録
- プロンプト定義: [docs/prompts/3min_story_generation_rules.md](prompts/3min_story_generation_rules.md)
- DB: `story_sequences`, `conversations`, `conversation_utterances` テーブル（マイグレーション済み）

## クイックスタート

### 1. 単語リストの準備

既存のDBからエクスポートするか、`assets/csv/words_master_1000.csv` に `word,meaning,part_of_speech` 形式で1000語を登録。

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
2. 生成された INSERT SQL を貼り付け
3. 実行

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

## 関連ファイル

- [docs/prompts/3min_story_generation_rules.md](prompts/3min_story_generation_rules.md) - AI向けルール定義
- [assets/csv/README_WORDS_MASTER.md](../assets/csv/README_WORDS_MASTER.md) - 単語リストの説明
