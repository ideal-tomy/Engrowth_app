# 実装PLAN 差分・改善点

本文書は、既存実装と [`実装PLAN.md`](実装PLAN.md) の差分を埋めるための改善点を整理したものです。

## 1. 現状 vs 計画の差分一覧

| 項目 | 現状 | 計画 | 改善アクション |
|------|------|------|----------------|
| 認証状態UI | `AuthStage` あり、`devViewAsSignedIn` で開発検証可能 | 匿名ログインでUIUX確認 | 既存を維持、メニュー分離を追加 |
| ハンバーガーメニュー | 共通表示（アカウント、設定、講師用、ログアウト） | 匿名/ログイン/ロール別IA | `_SettingsDrawer` をAuthStage/ロールで出し分け |
| 録音履歴画面 | 未実装 | 練習/提出済みタブ、共有境界の明示 | 新規 `recording_history_screen.dart` |
| 提出前確認モーダル | 未実装 | 共有相手・取り消し方針の明示 | 既存提出導線にモーダル追加 |
| 共有境界の常時表示 | 未実装 | 「提出済みのみコンサルに共有」を固定表示 | `share_boundary_notice` ウィジェット |
| コンサルダッシュボード | 提出一覧・再生・フィードバックあり | KPI・詳細ドロワー・課題発行 | 2層構造へ拡張 |
| 管理者ダッシュボード | 未実装 | 権限付与・監査・運用・AI承認 | 新規構築 |
| `user_sessions` | 未実装 | 学習セッション単位の記録 | Phase A マイグレーション |
| `consultant_client_permissions` | 未実装 | 期間外閲覧制御 | Phase A マイグレーション |
| RLS | 緩い（`USING (true)` あり） | consultant_assignments 参照で厳格化 | Phase B 適用 |

## 2. 実装に影響する既存コード

- **認証**: [`lib/providers/auth_provider.dart`](lib/providers/auth_provider.dart)  
  - `authStageProvider`, `devViewAsSignedInProvider` を活用
- **ドロワー**: [`lib/screens/dashboard_screen.dart`](lib/screens/dashboard_screen.dart)  
  - `_SettingsDrawer` を `AuthStage` に応じて項目を出し分け対象
- **音声提出**: [`lib/services/voice_submission_service.dart`](lib/services/voice_submission_service.dart)  
  - `markAsSubmitted` の前に確認モーダルを挿入
- **コンサル画面**: [`lib/screens/consultant_dashboard_screen.dart`](lib/screens/consultant_dashboard_screen.dart)  
  - 既存カードを維持しつつKPI・詳細ドロワーを追加
- **ルーティング**: [`lib/utils/router.dart`](lib/utils/router.dart)  
  - `/recordings`, `/consultant`, `/admin` 等の追加

## 3. UI統一ルール（実装時ガイド）

実装PLAN 10. に従う:

- 色は `Theme.of(context).colorScheme` のみ使用
- ダークモードでは影を減らし、境界線（outlineVariant）を活用
- 主要カード半径・余白: 角丸24/12系
- 一次操作は右下 or カード下部の同位置に固定
- 心理負荷を上げる文言は避ける

## 4. 開発時の匿名ログイン前提

- アプリ起動時は `ensureSignedIn()` で匿名サインイン
- ハンバーガーメニューの「開発: ログイン済み画面」で `devViewAsSignedIn` を ON にしてログイン後UIを確認
- Supabase Phase A では `auth.role() = 'authenticated'` を含む暫定ポリシーで匿名からもテーブル参照可能
- Phase B 適用前に上記で全導線のUI/機能確認を行う
