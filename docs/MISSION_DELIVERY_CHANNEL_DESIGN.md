# 課題配信チャネル設計（LINE/LINE WORKS 連携準備）

## Goal

- 課題発行時の出力をチャネル非依存イベントとして整理する。
- 将来の LINE / LINE WORKS 連携時に、UI 変更を最小化できるメタ設計を明記する。

## Non-Goal

- LINE / LINE WORKS への実送信実装（今回は設計のみ）。

---

## 1. 現行チャネル

| チャネル ID | 説明 | 実装 |
|-------------|------|------|
| `in_app` | アプリ内 TodaysMissionCard | coach_missions → todaysCoachMissionProvider |

課題発行は `ConsultantService.createMission()` で `coach_missions` に upsert される。クライアントは `TodaysMissionCard` 経由で表示を取得する。

---

## 2. 将来拡張（予定）

| チャネル ID | 説明 | 前提 |
|-------------|------|------|
| `line` | LINE 個人向け | LINE Login / Messaging API |
| `line_works` | LINE WORKS（法人向け） | LINE WORKS 連携 |

---

## 3. メタ設計（拡張ポイント）

### 3.1 データ構造案

課題発行をチャネル非依存にするため、以下を将来テーブル拡張候補とする。

| カラム案 | 型 | 説明 |
|----------|------|------|
| `delivery_channel` | TEXT | 現行: 常に `in_app`。将来: `line`, `line_works` 等 |
| `delivery_state` | TEXT | `pending` / `sent` / `failed` / `skipped` |
| `delivery_metadata` | JSONB | 送信先ID・外部メッセージID等 |

**現状**: `coach_missions` に上記カラムは未追加。Phase では `createMission()` の戻りを in-app のみとし、UI は変更しない。

### 3.2 サービス層の分離方針

```
ConsultantService.createMission()
  → coach_missions へ upsert（現行）
  → 将来: MissionDeliveryOrchestrator.emit(mission, channels: ['in_app', 'line'])
```

- **現行**: `createMission()` が直接 `coach_missions` に書き込む。
- **将来**: 同一メソッド内で、追加チャネルへの送信を呼び出すだけにする。UI（ConsultantDashboardScreen）側は変更不要にする。

### 3.3 イベント設計

| イベント | 発火タイミング | 将来拡張 |
|---------|----------------|----------|
| `mission_issued` | 課題発行成功時 | `delivery_channel` を properties に追加可能 |
| `mission_issue_failed` | 発行失敗時 | 同様 |
| `mission_delivery_sent` | 各チャネル送信完了時（将来） | - |

---

## 4. 管理者画面でのデモ

- 運用タブ内に「課題配信デモ（LINE / LINE WORKS）」カードを追加。
- 直近の coach_missions を取得し、チャネル別（in_app/LINE/LINE WORKS）の擬似状態を表示。
- 実API接続は行わず、連携時の動きをイメージできる。

## 5. 参照

- [03_FUNCTION_UPGRADE_CONSULTANT.md](plans/v2_2026q2/03_FUNCTION_UPGRADE_CONSULTANT.md)
- [07_BACKLOG_EXECUTION_PLAN.md](plans/v2_2026q2/07_BACKLOG_EXECUTION_PLAN.md) B10, B11
