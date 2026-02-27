# Supabase 会話データ更新 Runbook

修正後英会話CSVを Supabase に安全に反映させるための手順です。
ステージング確認→本番の2段階で運用することを推奨します。

---

## 1. 前提条件

- Supabase プロジェクトが稼働中
- `.env` に `SUPABASE_URL` と `SUPABASE_ANON_KEY` を設定
- `conversations` / `conversation_utterances` テーブルが存在
- 必要に応じて `database_conversation_import_policies.sql` で INSERT ポリシーを設定済み（[CSV_IMPORT_GUIDE](CSV_IMPORT_GUIDE.md) 参照）

---

## 2. Step 1: 修正後CSVを正規フォーマットへ統一

### 必須カラム

| カラム | 説明 | 例 |
|--------|------|-----|
| Scenario_ID | シナリオ識別子（同一会話内で同じ値） | CAFE_01, HOTEL_02 |
| Order | 発話順（1から連番） | 1, 2, 3... |
| Role | 話者 | A または B |
| Text_EN | 英語テキスト | "Hello. I would like a coffee." |
| Text_JP | 日本語テキスト | こんにちは。コーヒーをください。 |

### 正規化ルール

- Scenario_ID: 英数字とアンダースコアのみ。重複は同一会話を示す
- Order: 整数。欠番なく1から連番
- Role: A または B（大文字推奨）
- Text_EN: 空でないこと。引用符・改行は適切にエスケープ
- Text_JP: 空でも可

### theme / situation_type の正規化

ファイル名または別カラムで指定する場合、[conversation_scene_coverage_matrix.md](conversation_scene_coverage_matrix.md) の正規化辞書に従う。

---

## 3. Step 2: 事前検証

### 3.1 品質検証（不自然発話の検出）

```bash
dart run scripts/validate_conversation_utterances.dart path/to/conversation_utterances_rows.csv
```

- 出力: `audit_report.csv`
- 要修正・全面改稿が含まれる場合は、先に [conversation_rewrite_workflow.md](conversation_rewrite_workflow.md) に従って書換を完了する

### 3.2 CSVフォーマット検証（インポート前チェック）

```bash
dart run scripts/validate_csv_before_import.dart path/to/your_conversations.csv
```

- 重複 Scenario_ID 内の Order 欠番、空発話、禁則文字をチェック
- 問題があればエラーを出力し、インポートを中止

### 3.3 手動チェック項目

- [ ] 全発話が `conversation_quality_rubric.md` を満たしているか
- [ ] 同一 Scenario_ID 内で Order が 1 から連番か
- [ ] Role が A/B のみか
- [ ] Text_EN に不適切な文字（制御文字、過度な特殊文字）がないか

---

## 4. Step 3: ステージング Supabase へ投入

### 4.1 ステージング環境の用意

- 本番と別の Supabase プロジェクトを用意するか、本番の別スキーマで検証可能な場合はそれを使用
- ステージング用 `.env.staging` を用意し、`SUPABASE_URL` / `SUPABASE_ANON_KEY` をステージング用に設定

### 4.2 ドライラン（任意）

- `scripts/import_conversations_from_csv.dart` に `--dry-run` オプションがある場合、実行して挿入せずパース結果のみ確認
- 現行スクリプトには未実装のため、小規模CSV（1シナリオのみ）でテスト投入を推奨

### 4.3 インポート実行

```bash
# プロジェクトルートで（上書きインポート: 既存会話を全削除してから投入）
dart run scripts/import_conversations_from_csv.dart --replace
```

または追加のみ（重複に注意）:
```bash
dart run scripts/import_conversations_from_csv.dart "path/to/your_conversations.csv"
```

- 複数ファイル: `assets/csv` に会話CSVを配置し、引数なしで実行すると自動検出して全CSVを処理
- `--replace` 時は `.env` に `SUPABASE_SERVICE_ROLE_KEY` を設定することを推奨（DELETE 権限）

### 4.4 インポートログの保存

- 実行時の標準出力を `import_log_YYYYMMDD_HHmm.txt` として保存
- 失敗した Scenario_ID があれば、ログを確認してCSVを修正後、再実行

---

## 5. Step 4: アプリ画面で回帰確認

### 確認項目

1. **会話一覧**: 該当 theme / situation_type で会話が表示されるか
2. **会話学習**: 発話が正しい順序で表示され、TTS再生が動作するか
3. **音声再生**: 各発話の英語・日本語再生が問題ないか
4. **進捗イベント**: 学習完了・録音提出等のイベントが記録されるか

### テスト手順

1. アプリを起動し、会話トレーニング → 30秒会話 または 3分英会話 を選択
2. 該当シーン（例: カフェ・レストラン）を選択
3. 新規投入した会話を1本選び、聞く→役モードで録音まで実行
4. 発話が途切れないか、不自然な表示がないか確認

---

## 6. Step 5: 本番投入とロールバック

### 6.1 本番投入

- ステージングで問題がないことを確認後、本番 Supabase の .env を使用して同様にインポート実行
- 既存会話を**更新**する場合は、先に該当 `conversation_id` の `conversation_utterances` を削除してから、新規発話を投入する必要あり
- 新規会話の追加のみの場合は、既存スクリプトでそのまま追加

### 6.2 ロールバック用スナップショット

- 投入前に、該当 theme の既存 `conversations` / `conversation_utterances` をエクスポートし、`backup_conversations_YYYYMMDD.csv` として保存
- Supabase Dashboard > 該当テーブル > Export to CSV を利用

### 6.3 ロールバック手順

- バックアップCSVから該当会話を再投入するか、Dashboard から手動で削除・復元
- 発話のみ差し替える場合: 該当 `conversation_id` の utterance を DELETE 後、正しいCSVで再インポート

---

## 7. 運用強化（実装済み・予定）

| 項目 | 状況 | 備考 |
|------|------|------|
| 品質検証スクリプト | 済 | `validate_conversation_utterances.dart` |
| CSVフォーマット検証 | 予定 | `validate_csv_before_import.dart` |
| インポートログ | 手動 | 標準出力をファイルにリダイレクト |
| theme/situation_type 辞書 | 済 | `conversation_scene_coverage_matrix.md` |

---

## 8. トラブルシューティング

### インポート時にエラー

- `SUPABASE_URL` / `SUPABASE_ANON_KEY` を確認
- RLS ポリシーで INSERT が許可されているか確認
- カラム名が Scenario_ID, Order, Role, Text_EN, Text_JP であるか確認（大文字小文字はスクリプト次第）

### 会話が表示されない

- `theme` がアプリの `kScenarioCategories` 等でマッチしているか確認
- `situation_type` が daily / travel / business / student / common のいずれかか確認

### 発話順が乱れる

- Order が整数として正しくソートされているか確認
- 同じ Order が重複していないか確認
