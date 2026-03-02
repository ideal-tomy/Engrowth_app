# Engrowth 3ヶ月バージョンアップ計画：全体概要

## Goal

- `MASTER_PLAN.md` を唯一基準として、場当たり実装から「設計先行・一貫実装」へ移行する。
- デザイン面と機能面（ユーザー/コンサル/管理者）を同じ枠組みで計画し、導線まで含めて実装可能な粒度に分解する。
- 1ファイル過積載を避け、AI/人間の双方が迷わないドキュメント構成を作る。

## Non-Goal

- 本計画の策定・整備を超える実装作業は、別バックログとして扱う。
- 既存のMASTER_PLAN.md、ACTIVE_DOCS_INDEX.md の構成を変更しない。

## Exit Criteria

- 分割型計画ファイル群が揃い、各ファイルに Goal/Non-goal/Exit Criteria がある。
- 3ロール（ユーザー/コンサル/管理者）の導線が同じ粒度で記述される。
- 実装バックログが「1PR=1目的」で実行可能な粒度に分解される。
- KPIと受け入れ基準が各フェーズに紐づく。

---

## 範囲

- **基準**: MASTER_PLAN.md（哲学・Phase・ガードレール）
- **現状入力**: `00_CURRENT_STATE.md`（ルート・画面・ロール・現行ドキュメント）
- **計画成果物**: 本ディレクトリ内の全分割ドキュメント

---

## 3ヶ月マイルストーン

| 月 | フェーズ | 主な成果 |
|----|----------|----------|
| Month 1 | 設計固定 | 画面一覧・導線マップ確定、デザイン原則・UIトークン・遷移ポリシー定義、KPI・イベント命名規約固定 |
| Month 2 | 実装準備 | バックログを機能単位に分割（1PR=1目的）、DB変更抽出・実行順記載、高優先機能（チュートリアル離脱改善、ロール導線）仕様確定 |
| Month 3 | 実装運用 | バックログ順に着手、Exit Criteria 検証、KPIレビューで導線文言/順序を反復改善、次四半期繰越項目の明確化 |

---

## ドキュメント構成

| ファイル | 役割 |
|----------|------|
| [README.md](README.md) | 読み順・更新ルール |
| [00_CURRENT_STATE.md](00_CURRENT_STATE.md) | 現状棚卸し（計画入力） |
| [00_OVERVIEW.md](00_OVERVIEW.md) | 本ファイル（全体目的・範囲・マイルストーン） |
| [01_DESIGN_UPGRADE_APP_WIDE.md](01_DESIGN_UPGRADE_APP_WIDE.md) | 全画面デザイン原則・コンポーネント統一・演出基準 |
| [02_FUNCTION_UPGRADE_USER.md](02_FUNCTION_UPGRADE_USER.md) | 学習者体験の機能改善 |
| [03_FUNCTION_UPGRADE_CONSULTANT.md](03_FUNCTION_UPGRADE_CONSULTANT.md) | コンサル導線・評価体験 |
| [04_FUNCTION_UPGRADE_ADMIN.md](04_FUNCTION_UPGRADE_ADMIN.md) | 権限・監査・運用 |
| [05_IA_AND_JOURNEYS.md](05_IA_AND_JOURNEYS.md) | トップ→各ページ導線・ページ遷移仕様 |
| [06_ANALYTICS_AND_KPI.md](06_ANALYTICS_AND_KPI.md) | KPI定義・イベント設計・計測SQL |
| [07_BACKLOG_EXECUTION_PLAN.md](07_BACKLOG_EXECUTION_PLAN.md) | 1PR粒度の実装バックログ |
| [08_ACCEPTANCE_AND_QA.md](08_ACCEPTANCE_AND_QA.md) | ロール別受け入れ基準・E2E |

---

## アーキテクチャ視点

```
MASTER_PLAN → plans_v2_docs → DesignUpgrade
                           → RoleFunctionPlans (User/Consultant/Admin)
                           → IAAndJourneys
                           → AnalyticsAndKPI
RoleFunctionPlans + IAAndJourneys → BacklogExecution → ImplementationPRs
AnalyticsAndKPI → AcceptanceAndQA
ImplementationPRs → KPIReviewLoop
```
