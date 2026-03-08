# Active Docs Index

このファイルは、現時点で参照すべき一次ドキュメントを示します。

## Product Master
- `MASTER_PLAN.md`

## Plans (v2 2026 Q2)
- `docs/plans/v2_2026q2/README.md`
- `docs/plans/SPEAK_LIKE_GUIDED_FLOW_PLAN.md`（30秒/3分/パターンスプリント Speak風順序立てガイドフロー）
- `docs/plans/v2_2026q2/phaseA.md`
- `docs/plans/v2_2026q2/phaseB.md`
- `docs/plans/v2_2026q2/phaseC.md`
- `docs/plans/v2_2026q2/phaseB_impl.md`（Phase B 実装記録）
- `docs/plans/v2_2026q2/phaseC_impl.md`（Phase C 迷いナッジ 実装PLAN）

## Tutorial / Onboarding
- `docs/plans/TUTORIAL_INTRO_POPUP_PLAN.md`

## Consultant / Mission
- `docs/MISSION_DELIVERY_CHANNEL_DESIGN.md`（課題配信チャネル設計・LINE連携準備）

## UI/UX・Onboarding
- `docs/DAILY_VOICE_ONBOARDING_QA.md`
- `docs/MARQUEE_QA_CHECKLIST.md`
- `docs/TUTORIAL_SCHEMA_DESIGN.md`
- `docs/TUTORIAL_FUNNEL_QA.md`
- `docs/HOME_3SEC_RECOGNITION_QA.md`

## DB / Supabase
- `docs/SUPABASE_MIGRATION_ORDER.md`
- `supabase/migrations/MIGRATION_CATALOG.md`

## Motion Sync（遷移・体感遅延・CTA計測）
- `docs/MOTION_SYNC_ANALYTICS_QUERIES.md`（transition_complete_ms / tap_to_first_content_ms / cta_tap_rate の before/after 比較クエリ）

## TTS（音声再生・キャッシュ）
- `docs/TTS_FLOW.md`（全体フロー・10秒タイムアウトの意味・prefill 照合手順）
- `docs/TTS_音声DB確認手順_やさしい版.md`（キャッシュキーを合わせて「DBに保存されている音声が再生できるか」確認する手順・やさしい版）
- `docs/TTS_キャッシュを合わせる方法_やさしい版.md`（キャッシュを合わせる意味と、モデル・声・正規化をそろえる手順・やさしい版）
- `docs/TTS_最初の1件だけ再生される現象_調査.md`（99% YES なのに2本目以降が流れない原因と対処：Web オートプレイ・再生速度）
- `docs/TTS_tts-1で音声を用意し直す手順.md`（tts-1 で音声を一から揃える手順・やることだけ）
- `docs/TTS_DEBUG_CHECKLIST.md`（5秒壁・direct_db 低下時の診断、デプロイ前後チェック）
- `docs/TTS_CACHE_FULL_RUNBOOK.md`（prefill 手順）

## Archive Rules
- 旧計画・完了済み検討メモは `docs/archive/` に集約する。
- ルート `docs/` に残す文書は「現在進行の一次資料」のみ。
- 新規に一次資料を追加したら、このIndexを同時更新する。
- **打ち切り・結論レポート**: `docs/TTS_Supabase_DB再生_作業履歴と結論レポート.md`（Supabase DB 由来 TTS 再生の試行・ハッシュ一致施策・エラー対応・未達成の理由の総括。archive は .cursorignore のため docs 直下に配置）
