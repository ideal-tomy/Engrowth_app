# v2_2026q2 計画ドキュメント

Engrowth 3ヶ月バージョンアップ計画の分割型ドキュメント群です。

## 読み順

1. **00_OVERVIEW.md** — 全体目的・範囲・3ヶ月マイルストーン
2. **00_CURRENT_STATE.md** — 現状棚卸し（計画の入力情報）
3. **01_DESIGN_UPGRADE_APP_WIDE.md** — デザイン原則
4. **02_FUNCTION_UPGRADE_USER.md** — 学習者機能
5. **03_FUNCTION_UPGRADE_CONSULTANT.md** — コンサル機能
6. **04_FUNCTION_UPGRADE_ADMIN.md** — 管理者機能
7. **05_IA_AND_JOURNEYS.md** — 導線・遷移
8. **06_ANALYTICS_AND_KPI.md** — KPI・イベント
9. **07_BACKLOG_EXECUTION_PLAN.md** — 実装バックログ
10. **08_ACCEPTANCE_AND_QA.md** — 受け入れ基準・E2E
11. **phaseA.md** — PLANモード用プロンプト（触覚統一）
12. **phaseB.md** — PLANモード用プロンプト（ふわっと表示統一）
13. **phaseC.md** — PLANモード用プロンプト（迷いナッジ）
14. **phaseC_impl.md** — Phase C 迷いナッジ 実装PLAN

## 運用ルール

- **基準文書**: 計画判断は `MASTER_PLAN.md` を唯一の基準とする。
- **更新タイミング**: 各分割ファイルは「計画確定時」「実装着手時」に更新する。完了したら Exit Criteria を確認。
- **旧化の扱い**: 旧計画は `ARCHIVED` を先頭に明示するか、`docs/archive/` へ移動する。
- **SQL**: マイグレーション SQL は `supabase/migrations` から移動しない。新旧は `MIGRATION_CATALOG.md` で管理。
