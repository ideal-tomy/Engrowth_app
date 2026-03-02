# KPI・イベント設計・計測

## Goal

- MASTER_PLAN の成功指標を具体的なイベント・算出方法・判定基準に落とし込む。
- イベント命名規約を固定し、分析クエリ・判定基準を計画化する。

## Non-Goal

- 計測基盤の新規構築。既存 analytics_provider を前提に拡張する。

## Exit Criteria

- KPI とイベントが文書化され、週次レビューで参照可能。
- イベント命名規約が固定され、新規イベント追加時に従う。

---

## 1. North Star（MASTER_PLAN 準拠）

| 指標 | 算出方法 | 目標 |
|------|----------|------|
| D7 Retention | 初回アクセス7日後の再訪問率 | 週次改善 |
| 日課提出率 | daily_report_submitted / active_users | 週次改善 |

---

## 2. オンボーディング・チュートリアル

| イベント | 発火タイミング | 備考 |
|----------|----------------|------|
| onboarding_started | オンボーディング開始 | step, variant |
| onboarding_entry_tapped | 初回体験バナー/導線タップ | variant |
| onboarding_completed | オンボーディング完了 | variant, next_recommended_action |
| onboarding_skipped | スキップ | at_step, variant |
| onboarding_home_handoff_shown | 完了後ホーム誘導表示 | - |
| onboarding_home_handoff_tapped | 誘導先タップ（resume_card 等） | target |
| tutorial_started | チュートリアル開始 | entry_source: onboarding / direct |
| tutorial_completed | チュートリアル完了 | - |
| tutorial_skipped | スキップ（閉じる/スキップ） | at_step_id |
| tutorial_load_failed | チュートリアル読み込み失敗 | reason |
| tutorial_fallback_used | フォールバック利用 | step_id, stt_text（離脱要因分析） |

### 算出

- tutorial_started → tutorial_completed 完了率
- onboarding_started → onboarding_completed 完了率

---

## 3. 学習・UX（kpi_ux_plan.md 継承）

| イベント | 発火タイミング |
|----------|----------------|
| session_start | Quick30/Focus3 開始（session_mode 付与） |
| quick30_complete | Quick30 セッション完了 |
| focus3_complete | Focus3 セッション完了 |
| voice_attempt | 録音開始時 |
| resume_card_tap | 再開カード（source: resume / recommended） |
| next_task_accepted | セッション完了後「もう1セット続ける」 |

### 算出

- session_start_rate: session_start / ホーム表示回数
- quick30_completion_rate: quick30_complete / session_start(mode=quick30)
- focus3_completion_rate: focus3_complete / session_start(mode=focus3)
- voice_attempt_rate: voice_attempt / 表示された問題数

---

## 4. 導線

| イベント | 発火タイミング |
|----------|----------------|
| marquee_tap | Marquee タップ時 |
| main_tile_tap | MainTilesGrid 各タイルタップ（tile_id 付与） |

### 算出

- marquee_tap から学習開始までの到達率
- 主要導線のタップ後離脱率

---

## 5. イベント命名規約

- スネークケース: `screen_viewed`, `button_tapped`
- 動詞過去形 or 名詞: `tutorial_completed`, `session_start`
- パラメータ: snake_case（session_mode, source, tile_id）

---

## 6. 分析クエリ・判定基準

- 週次レビュー: 月曜朝に前週 KPI を確認。
- 離脱ポイント特定: 完了率低下時はイベント順序で停滞箇所を特定。
- A/B テスト: 大きな変更は段階ロールアウト。

### 参照

- docs/kpi_ux_plan.md
- docs/TUTORIAL_FUNNEL_QA.md
