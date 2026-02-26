# Supabase Phase A 適用手順（匿名ログイン検証用）

UIUX と機能の検証を行うため、匿名セッションでもテーブル参照が可能な暫定ポリシーを適用します。

## 前提

- 既存マイグレーション（voice_submissions, consultant_assignments 等）は適用済み
- Supabase プロジェクトが稼働中

## 適用順序

以下の SQL を **Supabase Dashboard > SQL Editor** で順番に実行するか、`supabase db push` で一括適用してください。

1. `database_phase_a_user_sessions.sql`
2. `database_phase_a_voice_submissions_extension.sql`
3. `database_phase_a_consultant_client_permissions.sql`
4. `database_phase_a_coach_threads_messages.sql`
5. `database_phase_a_app_feedback.sql`
6. `database_phase_a_daily_ai_insights.sql`
7. `database_phase_a_access_audit_logs.sql`

## ローカルでマイグレーション適用

```bash
cd /path/to/engrowth_app
supabase db reset   # 開発環境をリセットして全マイグレーション再適用
# または
supabase migration up   # 新規マイグレーションのみ適用
```

## 暫定ポリシーの要点

- `user_sessions`: 本人のみ SELECT/INSERT
- `consultant_client_permissions`: authenticated 全員が参照・挿入・更新
- `coach_threads` / `coach_messages`: スレッド参加者のみ参照
- `app_feedback`: authenticated 全員が挿入・参照
- `daily_ai_insights`: authenticated 全員が参照・管理
- `access_audit_logs`: authenticated 全員が挿入・参照

## 検証項目（Phase A 適用後）

1. 匿名ログインでアプリ起動
2. ハンバーガーメニューで「開発: ログイン済み画面」を ON
3. 録音履歴・講師用ダッシュボード・管理者ダッシュボードへの導線を確認
4. 提出前確認モーダル → 提出 → 録音履歴（提出済みタブ）の遷移を確認
5. コンサル画面の KPI・詳細ドロワー（現状はプレースホルダー）を確認

## 注意

Phase A のポリシーは **本番環境では使わない** でください。UI/機能検証完了後に Phase B（RLS 厳格化）を適用してください。
