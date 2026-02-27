# CSVインポートガイド（会話形式データ）

## 添付CSVの構造

| CSVカラム | 説明 | 例 |
|-----------|------|-----|
| Scenario_ID | シナリオ識別子 | CAFE_01, HOTEL_01 |
| Order | 発話順 | 1, 2, 3... |
| Role | 話者 | A, B |
| Text_EN | 英語テキスト | "Hello. I would like a coffee, please." |
| Text_JP | 日本語テキスト | こんにちは。コーヒーをください。 |
| Hint_Word | ヒント用単語 | would like / coffee |
| Image_Prompt | 画像生成プロンプト | A customer standing at... |

---

## アプリのテーブル構成との比較

### ❌ words テーブルには**合いません**
- words: `word_number`, `word`, `meaning`, `part_of_speech`, `word_group`
- 会話形式のCSVは単語リストではないため、そのままでは使えません。

### ⚠️ sentences テーブル（例文モード用）
- 期待カラム: `group`, `target_words`, `dialogue_en`, `dialogue_jp`, `image_prompt`, `scene_setting`, `category_tag`, `image_url`
- マッピング例: Scenario_ID→group, Text_EN→dialogue_en, Text_JP→dialogue_jp, Hint_Word→target_words, Image_Prompt→image_prompt
- **1行＝1発話**として登録可能ですが、会話のつながり（A/Bの交互）は sentences では管理しません。

### ✅ conversations + conversation_utterances（会話学習モード用）
- 会話形式に**最も適合**します。
- **conversations**: 1シナリオ＝1会話（title, situation_type, theme など）
- **conversation_utterances**: 各発話（speaker_role, utterance_order, english_text, japanese_text）

---

## Supabase テーブルエディタからCSVをアップする場合

### 制限事項
- **1回のインポートで1テーブル**のみ対象
- `conversations` と `conversation_utterances` は**親子関係**のため、一括CSVアップロードでは**そのまま会話形式で反映できません**
- 会話を正しく登録するには、先に `conversations` を作成し、続けて `conversation_utterances` を作成する必要があります

### 推奨方法
1. **インポートスクリプトを使う**（`scripts/import_conversations_from_csv.dart` を実行）
2. スクリプトが以下を行います:
   - CSVを解析
   - Scenario_ID ごとに `conversations` を1件作成
   - 各発話を `conversation_utterances` に登録（conversation_id で紐付け）

---

## カラム名マッピング（スクリプト使用時）

| CSV | conversations | conversation_utterances |
|-----|---------------|-------------------------|
| Scenario_ID | title の元（例: CAFE_01 → "カフェ シーン1"） | - |
| - | situation_type | - |
| - | theme | - |
| Order | - | utterance_order |
| Role | - | speaker_role |
| Text_EN | - | english_text |
| Text_JP | - | japanese_text |

---

## 結論

- **テーブルエディタでCSVをそのままアップロードするだけでは、会話形式として正しく反映されません。**
- 会話形式で反映させるには、`scripts/import_conversations_from_csv.dart` でのインポートを推奨します。

---

## インポート手順（スクリプト使用）

### 1. 前提条件
- `database_conversation_migration.sql` を Supabase SQL Editor で実行済み
- `.env` に `SUPABASE_URL` と `SUPABASE_ANON_KEY` を設定

### 2. RLSポリシー（インポート用）
スクリプトで挿入するには、conversations / conversation_utterances に INSERT を許可するポリシーが必要です。

**Supabase Dashboard → SQL Editor** で `database_conversation_import_policies.sql` を実行するか、以下をコピーして実行してください：

```sql
-- conversations: anon でも INSERT 可能
DROP POLICY IF EXISTS "Allow insert for import" ON conversations;
CREATE POLICY "Allow insert for import" ON conversations FOR INSERT WITH CHECK (true);

-- conversation_utterances: anon でも INSERT 可能
DROP POLICY IF EXISTS "Allow insert for import" ON conversation_utterances;
CREATE POLICY "Allow insert for import" ON conversation_utterances FOR INSERT WITH CHECK (true);
```

※ 本番では適切に制限してください。

### 3. スクリプト実行
```bash
# プロジェクトルートで（assets/csv 内の会話CSVを自動検出）
dart run scripts/import_conversations_from_csv.dart
```

**既存データを上書きする場合**（Supabase の会話を全削除してから再投入）：
```bash
dart run scripts/import_conversations_from_csv.dart --replace
```
- `SUPABASE_SERVICE_ROLE_KEY` を .env に設定すると、DELETE が確実に実行されます
- RLS で anon に DELETE が許可されていない場合は service_role キーが必要です

特定ファイルのみ指定する場合：
```bash
dart run scripts/import_conversations_from_csv.dart "assets/csv/Engrowthアプリ英単語データ - カフェ・レストラン編.csv"
```

### 4. アプリでの確認
学習画面のメニューから「会話トレーニング」→「30秒会話」または「3分英会話」を選択し、該当テーマの会話が表示されることを確認してください。

---

## Supabase ダッシュボードから手動で更新する場合

会話形式（conversations + conversation_utterances）は**親子関係**のため、テーブルエディタでCSVを直接アップロードするだけでは正しく反映できません。

### 手動手順
1. **インポートスクリプトを使用することを推奨**（上記「スクリプト実行」を参照）
2. スクリプトが使えない場合：
   - 既存データを削除: Table Editor → conversations / conversation_utterances → 手動で行を削除
   - 続けて `dart run scripts/import_conversations_from_csv.dart` を実行（削除後なら --replace なしで追加のみ）
