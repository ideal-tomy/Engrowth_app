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

**よくあるエラー4**: `relation "access_audit_logs" does not exist` または `relation "coach_missions" does not exist`
→ 管理者用マイグレーション（database_admin_*）は、該当テーブルが存在しない場合はスキップするよう修正済みです。フル機能を使うには、先に以下を実行してください:
- `database_phase_a_access_audit_logs.sql`（access_audit_logs 作成）
- `database_coach_missions.sql`（coach_missions 作成）

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

### ステップ4: チュートリアルテーブルを作成（未作成の場合）
1. **New query**
2. `supabase/migrations/database_tutorial_tables.sql` の内容をコピー＆ペースト
3. **Run** で実行
4. 続けて `supabase/migrations/seed_tutorial_greeting.sql` を実行してシード投入

### ステップ5: analytics_events（TTS 観測・KPI 用、任意）

TTS_DEBUG_CHECKLIST の SQL や KPI 計測を使う場合のみ:

1. **New query**
2. `supabase/migrations/database_analytics_events.sql` の内容をコピー＆ペースト
3. **Run** で実行

### ステップ6: 管理者機能（B12-B14）

**前提テーブル**（未作成の場合は先に実行）:
- `access_audit_logs`: `database_phase_a_access_audit_logs.sql`
- `consultant_assignments`: `database_consultant_assignments.sql`
- `coach_missions`: `database_coach_missions.sql`

上記が存在しない場合、管理者用マイグレーションは該当部分をスキップします（エラーになりません）。

1. `supabase/migrations/database_admin_access_audit_action.sql` を実行（action_type カラム追加）
2. `supabase/migrations/database_admin_consultant_assignments_policy.sql` を実行（管理者用 RLS ポリシー）

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
| `database_tutorial_tables.sql` | チュートリアル専用テーブル（tutorials, tutorial_steps, tutorial_step_responses） |
| `seed_tutorial_greeting.sql` | 初回挨拶チュートリアルのシード（上記の直後に実行） |
| `database_admin_access_audit_action.sql` | access_audit_logs に action_type 追加（B14 監査タブ） |
| `database_admin_consultant_assignments_policy.sql` | 管理者が consultant_assignments / coach_missions を操作できる RLS（B13, 配信デモ） |
| `database_client_reports.sql` | B15 クライアント→コンサルタントのアプリ内クイック報告テーブル |
| `database_analytics_events.sql` | KPI計測用イベントテーブル（TTS 観測・D1/D7継続率等。TTS_DEBUG_CHECKLIST の SQL に必要） |

---

## 4. notifications テーブル作成の詳細

`database_notifications.sql` を実行すると以下が作成されます：

- **notifications** テーブル
  - `id`, `user_id`, `type`, `title`, `message`, `related_id`, `read_at`, `created_at`
- RLS ポリシー
  - ユーザーは自分の通知のみ SELECT / UPDATE（既読マーク）可能

通知は Edge Function の `send-notifications` やアプリ内ロジックから挿入されます。ユーザーは `/notifications` ページで一覧を閲覧・既読操作ができます。
