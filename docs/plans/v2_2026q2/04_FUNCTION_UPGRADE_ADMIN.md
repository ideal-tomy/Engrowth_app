# 管理者機能（権限・監査・運用）の改善計画

## Goal

- 権限・監査の要件を満たす運用基盤を整備する。
- 4タブ（権限付与/監査/運用/AI承認）を実データ連携まで完成させる。

## Non-Goal

- 本計画範囲外の新規監査要件追加。既存タブ構造を前提に実装を進める。

## Exit Criteria

- 権限付与・監査・運用・AI承認の 4 タブが実データと連携する。
- 運用監視で未対応提出件数が取得でき、管理者が参照可能。
- 本番環境で JWT app_role=admin による判定が動作する。

---

## 1. 現状

### 1.1 判定

- 本番: 未実装（TODO: auth.jwt()->>'app_role' = 'admin'）
- 開発: devViewAsAdminProvider

### 1.2 実装済み

- 4タブ UI（権限付与/監査/運用/AI承認）
- 運用タブで未対応件数表示（実データ）
- isAdminProvider の JWT app_role 判定（user_metadata / app_metadata）
- 権限付与ロジック（consultant_assignments の CRUD、監査ログ記録）
- 監査ログの実データ表示・フィルタ（access_audit_logs）
- 配信デモ（LINE / LINE WORKS 連携イメージ、運用タブ内）

### 1.3 TODO

- AI承認フローの詳細設計・実装

---

## 2. 改善方針

### 2.1 権限制御

- role_provider の admin 判定を JWT claim に移行。
- RLS と連携し、app_role=admin で全件閲覧可能であることを検証。

### 2.2 監査

- 監査ログの取得・表示 UI を実データと連携。
- 検索・フィルタの範囲を計画内で定義。

### 2.3 運用

- 未対応提出件数のリアルタイム（または準リアルタイム）表示。
- 必要に応じて Supabase のリアルタイム購読を利用。

---

## 3. 導線

- メニュー「管理者ダッシュボード」→ AdminDashboardScreen。
- 未ログイン時は /home へリダイレクト。
