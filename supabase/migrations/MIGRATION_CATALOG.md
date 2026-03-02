# Migration Catalog

## 原則（重要）
- `supabase/migrations` はDB履歴の正本です。**実行済みでも移動しません**。
- 新旧の見分けは「移動」ではなく、本カタログと実行順序ドキュメントで管理します。

## Active Manual Run Order
実行順は以下を参照:
- `docs/SUPABASE_MIGRATION_ORDER.md`

## Category

### Foundation (schema / rls)
- `database_*.sql`

### Seed (content / tutorial)
- `seed_*.sql`

## Current Highlight
- `database_admin_access_audit_action.sql`: B14 監査ログ action_type
- `database_admin_consultant_assignments_policy.sql`: B13 管理者権限付与 RLS
- `database_client_reports.sql`: B15 クライアント→コンサルタント報告テーブル

## 運用ルール
- 新規SQL追加時は、`docs/SUPABASE_MIGRATION_ORDER.md` と本ファイルの両方を更新。
- 既存SQLはリネーム/移動しない（再現性・監査性保全）。
