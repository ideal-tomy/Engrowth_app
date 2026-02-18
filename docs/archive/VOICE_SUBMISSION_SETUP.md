# 音声提出機能（Phase 1）セットアップ

## 1. データベースマイグレーション

Supabase Dashboard > SQL Editor で以下を実行:

```
supabase/migrations/database_voice_submissions_migration.sql
```

## 2. ストレージバケット作成

Supabase Dashboard > Storage > New bucket

- **名前**: `voice-recordings`
- **Public bucket**: OFF（Private）
- **Create bucket** をクリック

### ストレージポリシー

バケット作成後、Policies で以下を追加:

**1. アップロード許可（認証ユーザーが自分のフォルダへ）**
- Policy name: `Users can upload own recordings`
- Allowed operation: INSERT
- Target roles: authenticated
- WITH CHECK expression: `bucket_id = 'voice-recordings' AND (storage.foldername(name))[1] = auth.uid()::text`

**2. 閲覧許可（認証ユーザー）**
- Policy name: `Authenticated can read recordings`
- Allowed operation: SELECT
- Target roles: authenticated
- Policy definition: `bucket_id = 'voice-recordings'`

## 3. コンサルタントダッシュボードへのアクセス

- Web: `https://your-app.web.app/consultant`
- ローカル: `http://localhost:xxxx/consultant`

## 4. 動作確認

1. アプリでログイン
2. 学習画面（例文学習）で録音 → 停止
3. 「聴き直す」で再生確認
4. 「先生に送る」で提出
5. `/consultant` で提出一覧を確認し、フィードバックを入力
