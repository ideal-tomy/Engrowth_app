# 匿名認証のセットアップ

## 概要

アプリは起動時に自動的に**匿名ログイン**を行い、ユーザー ID を発行します。これにより：

- 学習進捗を Supabase に保存できる
- 後から「アカウント作成」で永続アカウントに昇格し、データを保持できる

## Supabase 側の設定

1. **Supabase Dashboard** → **Authentication** → **Providers**
2. **Anonymous Sign-ins** を有効化（Enable をオン）
3. 保存

## フロー

| 状態 | 説明 |
|------|------|
| 起動時 | セッションなし → `signInAnonymously()` で匿名ユーザー作成 |
| 匿名中 | ダッシュボードに「ログインで記録を保存」バナー表示 |
| アカウント作成 | `linkAnonymousToPermanent()` でメール・パスワードを設定し、同じ user_id のまま永続化 |
| ログイン | 既存アカウントで `signIn()` → 新しいセッション（匿名データは引き継がれない） |
| ログアウト | `signOut()` 後、自動で再度匿名サインイン |

## 開発用：ログイン済み画面の確認

開発時に「ログイン後の画面」を確認するには：

1. 設定メニュー（ハンバーガー）を開く
2. **「開発: ログイン済み画面」** スイッチをオン
3. 匿名のまま、ログイン済みとして表示される（CoachBanner、統計など）

※ `kDebugMode` のときのみ表示されます。本番ビルドでは表示されません。

## 関連ファイル

- `lib/services/auth_service.dart` - 認証サービス
- `lib/providers/auth_provider.dart` - 認証状態プロバイダ（devViewAsSignedIn 含む）
- `lib/screens/account_screen.dart` - アカウント画面
- `lib/widgets/dashboard_sections/anonymous_data_save_banner.dart` - 匿名ユーザー向けバナー
