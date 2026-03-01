# Supabase マイグレーション実行順序ガイド

Supabase SQL Editor でマイグレーションを手動実行する場合の推奨順序と手順です。

## 1. エラーの原因：consultant_assignments が存在しない

**よくあるエラー1**: `database_rls_hardening_phase_c.sql` 実行時
```
ERROR: 42P01: relation "consultant_assignments" does not exist
```
→ Phase C の前に `database_consultant_assignments.sql` を先に実行してください。

**よくあるエラー2**: `database_consultant_assignments.sql` や `database_notifications.sql` を再実行したとき
```
ERROR: 42710: policy "..." for table "..." already exists
```
→ 各マイグレーションに `DROP POLICY IF EXISTS` を追加済みのため、再実行でエラーにならなくなりました。最新版の SQL を使っていれば再実行可能です。

**よくあるエラー3**: `database_rls_hardening_phase_c.sql` 実行時
```
ERROR: 42P01: relation "analytics_events" does not exist
```
→ Phase C は各テーブル（analytics_events, conversation_learning_events, voice_feedbacks）が**存在する場合のみ**ポリシーを適用するよう修正済みです。存在しないテーブルはスキップされるため、エラーになりません。最新版の SQL を再実行してください。

**解決策**: 以下の順序で実行してください。各スクリプトは冪等（再実行可）になっているので、既に実行済みでもエラーになりません。

---

## 2. 推奨実行順序

### ステップ1: consultant_assignments テーブルを作成
1. Supabase Dashboard → **SQL Editor** を開く
2. **New query** をクリック
3. `supabase/migrations/database_consultant_assignments.sql` の内容をコピー＆ペースト
4. **Run** (Ctrl+Enter) で実行
5. "Success. No rows returned" と表示されれば OK

### ステップ2: Phase C RLS を適用
1. 同じ SQL Editor で **New query**
2. `supabase/migrations/database_rls_hardening_phase_c.sql` の内容をコピー＆ペースト
3. **Run** で実行
4. エラーが出なければ完了

### ステップ3: 通知テーブルを作成（未作成の場合）
1. **New query**
2. `supabase/migrations/database_notifications.sql` の内容をコピー＆ペースト
3. **Run** で実行

---

## 3. 各マイグレーションの役割

| ファイル | 役割 |
|---------|------|
| `database_consultant_assignments.sql` | コンサルタントとクライアントの担当割当テーブル（Phase C の前提） |
| `database_rls_hardening_phase_c.sql` | analytics_events / conversation_learning_events / voice_feedbacks の RLS 厳格化 |
| `database_notifications.sql` | アプリ内通知テーブル（通知一覧ページ用） |
| `database_user_favorites.sql` | お気に入りテーブル（お気に入りページ用） |
| `database_user_favorites_add_pattern.sql` | お気に入りに `pattern` タイプ追加（パターンスプリント用） |
| `database_sentences_phrase_title_category.sql` | sentences に phrase_title / category_label_ja 追加（センテンス一覧用） |
| `database_sentences_backfill_phrase_category.sql` | 既存 sentences の phrase_title / category_label_ja を初期バックフィル（上記の直後に実行） |

---

## 4. notifications テーブル作成の詳細

`database_notifications.sql` を実行すると以下が作成されます：

- **notifications** テーブル
  - `id`, `user_id`, `type`, `title`, `message`, `related_id`, `read_at`, `created_at`
- RLS ポリシー
  - ユーザーは自分の通知のみ SELECT / UPDATE（既読マーク）可能

通知は Edge Function の `send-notifications` やアプリ内ロジックから挿入されます。ユーザーは `/notifications` ページで一覧を閲覧・既読操作ができます。
