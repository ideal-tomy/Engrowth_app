# 認証・セッション分離 QA 検証手順

## 目的

デプロイ URL 共有時に他者のログイン状態が伝播しないこと、およびユーザーごとにデータが正しく分離されることを検証する。

## 事前確認（Supabase Dashboard）

1. **Authentication → Providers**
   - Anonymous Sign-ins: 有効
   - Google: 有効、Client ID/Secret 設定済み
   - Manual Linking: 有効（匿名→永続リンク用）

2. **Authentication → URL Configuration**
   - Site URL: `https://engrowth-app.web.app`（本番）
   - Redirect URLs: 本番オリジン・localhost が登録済み

## 検証ケース 1: URL 共有時のセッション漏洩防止

### 手順

1. ブラウザ A で本番 URL にアクセス
2. ログイン（Google または メール/パスワード）
3. ログイン完了直後のアドレスバー URL を確認
   - **期待**: `https://engrowth-app.web.app/` など、`#access_token` / `#refresh_token` / `?code=` を含まない
4. その URL をコピーし、ブラウザ B（別ブラウザまたはシークレットモード）で開く
5. ブラウザ B の状態を確認

### 期待結果

- ブラウザ B ではログインされていない（匿名または未ログイン）
- ブラウザ B で表示されるデータは、ブラウザ A のユーザーと共有されない

## 検証ケース 2: 別端末・別ブラウザでのユーザー分離

### 手順

1. 端末 A でユーザー X としてログインし、学習進捗・録音履歴などを操作
2. 端末 B（別 PC / スマホ / シークレットウィンドウ）でユーザー Y としてログイン
3. 両端末で以下を確認:
   - 進捗（覚えた例文数など）
   - 録音履歴
   - お気に入り
   - 通知

### 期待結果

- 端末 A と端末 B で表示されるデータが一致しない（ユーザー X ≠ ユーザー Y）
- 共有されているデータが一切ない

## 検証ケース 3: 本番ビルドの必須条件

### 手順

1. `cd engrowth_app` でプロジェクトルートへ移動
2. `.env` に `SUPABASE_URL` と `SUPABASE_ANON_KEY` が設定されていることを確認
3. `.\scripts\build_for_deploy.ps1`（Windows）または `./scripts/build_for_deploy.sh`（Mac/Linux）でビルド
4. ビルドが成功し、`build/web` が生成されることを確認

### 期待結果

- `--release` と `--dart-define` で Supabase 接続情報が埋め込まれた状態でビルドされる
- デプロイ後、認証・データ取得が正常に動作する

## 関連ファイル

- `lib/utils/auth_url_cleanup.dart` - OAuth 後 URL クリーンアップ
- `lib/main.dart` - 起動時のクリーンアップ呼び出し
- `docs/ANONYMOUS_AUTH_SETUP.md` - 認証セットアップ詳細
