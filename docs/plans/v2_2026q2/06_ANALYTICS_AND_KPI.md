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
| resume_resolution | 再開先決定結果（resolution: resume / recommended_fallback / plain_fallback） |
| study_first_content_rendered | 学習初回コンテンツ表示（entry_source, tap_to_first_content_ms） |
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
| marquee_tap | Marquee タップ時（tap_id, target_route, source, label） |
| main_tile_tap | MainTilesGrid 各タイルタップ（tile_id, destination, auth_stage, rank） |
| learning_entry_started | 学習画面表示時（learning_mode, entry_source, tap_id）entry_source: marquee / resume_card / recommended_fallback / plain_fallback |
| study_first_content_rendered | 学習初回コンテンツ表示時（entry_source, tap_to_first_content_ms）B16 |
| home_primary_cta_impression | ホーム初回表示時（impression_at_ms） |
| home_primary_cta_recognized | 初回3秒以内の主要導線タップ（cta_source, elapsed_sec, under_3s） |

### 算出

- marquee_tap から learning_entry_started までの到達率（60秒ウィンドウ、tap_id で接続）
- resume_card_tap から learning_entry_started（entry_source=resume_card 系）までの到達率
- resume_card_tap から study_first_content_rendered までの tap_to_first_content_ms P95（B16 Zero-Latency 検証）
- 主要導線のタップ後離脱率

---

## 5. 担当コンサル連絡（B15）

| イベント | 発火タイミング |
|----------|----------------|
| consultant_contact_opened | 連絡画面を開いた時（has_consultant） |
| consultant_contact_channel_selected | チャネル選択時（channel: in_app / line / line_works） |
| consultant_contact_message_sent | アプリ内報告送信成功時（channel, report_type） |
| consultant_contact_message_failed | 送信失敗時（channel, reason） |

## 6. コンサルタント・課題発行（B10/B11）

| イベント | 発火タイミング | 備考 |
|----------|----------------|------|
| consultant_detail_opened | 詳細ログドロワーを開いた時 | submission_id, has_session_data |
| consultant_detail_closed | 詳細ログドロワーを閉じた時 | submission_id |
| consultant_detail_error | 詳細ログ取得不可・未連携時 | reason, submission_id |
| mission_issued | 課題発行成功時 | client_id, has_preset |
| mission_issue_failed | 課題発行失敗時 | reason |

### 算出

- consultant_detail_opened の has_session_data=true 率（session_uuid 連携率の目安）
- mission_issued の日次件数・担当別件数

---

## 7. イベント命名規約

- スネークケース: `screen_viewed`, `button_tapped`
- 動詞過去形 or 名詞: `tutorial_completed`, `session_start`
- パラメータ: snake_case（session_mode, source, tile_id）

---

## 8. 分析クエリ・判定基準

- 週次レビュー: 月曜朝に前週 KPI を確認。
- 離脱ポイント特定: 完了率低下時はイベント順序で停滞箇所を特定。
- A/B テスト: 大きな変更は段階ロールアウト。

### B15/B16 週次確認項目

- consultant_contact_opened の has_consultant=true 率
- consultant_contact_message_sent の日次件数
- resume_card_tap から study_first_content_rendered までの tap_to_first_content_ms P95
- resume_resolution の fallback 率（plain_fallback が高い場合は要改善）

### 参照

- docs/kpi_ux_plan.md
- docs/TUTORIAL_FUNNEL_QA.md
- docs/HOME_3SEC_RECOGNITION_QA.md（B09 3秒認識検証）
