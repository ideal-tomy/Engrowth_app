# Supabase Phase B 適用手順（RLS 厳格化）

UI/機能検証が完了したら、本番稼働前に Phase B を適用して RLS を厳格化します。

## 前提

- Phase A のマイグレーションが適用済み
- UI/機能の検証が完了している
- 管理者用の JWT claim 設定が完了している

## JWT claim の設定（管理者判定用）

Supabase Dashboard で `app_role=admin` を JWT に含めるには、以下のいずれかが必要です。

### 方法 1: Custom Claims（推奨）

1. Supabase Dashboard > Authentication > Users
2. 管理者ユーザーを選択
3. User Metadata に `{"app_role": "admin"}` を追加
4. または、Database Function で `auth.jwt()` の custom claims を設定

### 方法 2: 専用ロールテーブル

`user_roles` テーブルを作成し、RLS ポリシーで `EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')` を参照する方法もあります。

本マイグレーションでは `auth.jwt()->>'app_role' = 'admin'` を想定しています。環境に合わせてポリシーを調整してください。

## 適用順序

1. バックアップを取得（schema + 必要に応じて data）
2. `database_phase_b_rls_hardening.sql` を実行

```bash
# ローカル
supabase db push

# または Supabase Dashboard > SQL Editor でファイル内容を貼り付けて実行
```

## 検証項目（Phase B 適用後）

1. **クライアント**: 自分の voice_submissions / voice_feedbacks のみ参照できること
2. **コンサルタント**: 担当クライアント（consultant_assignments に登録）の提出のみ参照できること
3. **管理者**: 全テーブルを参照・更新できること（app_role=admin の JWT）
4. **越権**: クライアントが他人の提出を読めないこと、コンサルが未担当クライアントを読めないことを確認

## Storage ポリシー

`voice-recordings` バケットのポリシーも同様に厳格化してください。

- クライアント: 自分のフォルダ（`{user_id}/*`）のみアップロード・参照
- コンサル: 担当クライアントのフォルダのみ参照
- 管理者: 全フォルダ参照

## トラブルシューティング

- ポリシー適用後、アプリで「権限がありません」が出る場合:
  - 該当テーブルのポリシー一覧を確認
  - `auth.uid()` が期待どおりか確認（ログイン状態）
  - consultant_assignments に正しく割当が入っているか確認
