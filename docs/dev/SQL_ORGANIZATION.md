# SQLファイル整理方針

## 運用入口

| 場所 | 用途 | 実行方法 |
|------|------|----------|
| `supabase/migrations/` | マイグレーション・シード | `supabase db push` または Supabase Dashboard で適用 |
| `supabase_schema.sql` (ルート) | スキーマ参照用 | 初回セットアップ時に SQL Editor で実行 |
| `supabase_storage_setup.sql` (ルート) | Storage ポリシー設定 | 画像機能利用時に SQL Editor で手動実行 |

## アーカイブ

| 場所 | 内容 |
|------|------|
| `docs/archive/seed_stories/` | 実行済み・雛形の seed_story_*.sql（一部は migrations と重複） |

## 整理済み（Phase 3）

- ルートに散在していた `CHECK_*.sql`, `CREATE_*.sql` 等は CLEANUP により既に削除済み
- マイグレーションはすべて `supabase/migrations/` に集約済み
- `supabase_schema.sql` は README から参照されるためルートに保持
- `supabase_storage_setup.sql` は [docs/IMAGE_UPLOAD_GUIDE.md](../IMAGE_UPLOAD_GUIDE.md) から参照されるためルートに保持
