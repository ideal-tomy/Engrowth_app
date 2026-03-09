# バックエンド資産棚卸し・廃止順序

起動遅延リファクタに伴うバックエンド側の不要/旧方式資産の分類と廃止順を定義する。  
現行方針: TTS は **CDN + JSON インデックス**（`MASTER_PLAN.md`・`docs/TTS_CDN_R2_ARCHITECTURE.md`）。DB 参照（`tts_assets` / prefill）は廃止済み。

---

## 1. 即削除（低リスク）

| 対象 | 根拠 | 実施 |
|------|------|------|
| `scripts/check_tts_url.dart` | 単発デバッグ用。Supabase public URL 固定で旧方式寄り。運用導線に未掲載。 | **削除済み** |
| `docs/ACTIVE_DOCS_INDEX.md` の存在しない TTS ドキュメント参照 | `TTS_音声DB確認手順_やさしい版.md` 等、実ファイル不在。誤誘導の原因。 | Index から該当行を削除し、現行 doc に集約 |

---

## 2. 段階的廃止（中リスク）

| 対象 | 根拠 | 置換先・手順 |
|------|------|----------------|
| `supabase/functions/tts_synthesize/index.ts` | アプリ本体の `functions.invoke` は `conversation_reply` / `stt_transcribe` のみ。`tts_synthesize` は prefill 等スクリプトからのみ使用。 | 新規運用停止 → 一定期間観測 → 廃止。音声は CDN + `audio_index.json`（`lib/services/openai_tts_service.dart`）が標準。 |
| `scripts/prefill_tts_assets.dart` | `tts_assets` / `tts_synthesize` 前提。現行方針（DB 参照廃止）と不整合。 | `build_audio_index.dart` + R2 運用ドキュメント群。active 運用手順から外し、必要なら archive へ。 |
| `scripts/check_tts_prefill_status.dart` | 同上。`tts_assets` 照合用。 | 同上。 |
| `scripts/verify_tts_cache_hash.dart` | 同上。`tts_synthesize` invoke あり。 | 同上。 |
| `docs/TTS_CACHE_FULL_RUNBOOK.md` | direct_db / prefill / `tts_assets` を主軸。現行方式と逆。 | `TTS_FLOW.md`・`TTS_CDN_R2_SETUP.md`・`TTS_CDN_R2_ARCHITECTURE.md` に集約。まず ARCHIVED 明示し、Index から除外。 |

**廃止順**: 1) ドキュメントの ARCHIVED 化と Index 整理 → 2) 旧 prefill/verify スクリプトの運用停止と archive 退避 → 3) `tts_synthesize` の新規呼び出し停止確認後、Function 廃止検討。

---

## 3. 保留（削除前に確認必須）

| 対象 | 理由 | 確認すること |
|------|------|----------------|
| `supabase/functions/send-notifications/index.ts` | リポジトリ内からの参照なし。外部ジョブ・手動運用・将来 LINE 連携の可能性。 | 外部トリガー・cron・管理画面からの呼び出し有無を確認。廃止時は代替（DB トリガー or 明示 insert）を用意。 |
| `supabase/functions/detect-dropouts/index.ts` | アプリ内参照なし。`database_cron_detect_dropouts.sql` に cron 実行例あり。 | 本番で cron 等から既に実行されているか確認。廃止時は SQL ジョブ/管理画面集計へ統合を検討。 |
| `supabase/migrations/*`（tts_assets 等） | 履歴保全のため **移動・削除しない**（`docs-and-migrations-hygiene` ルール）。 | 運用は `MIGRATION_CATALOG.md` で管理。新規参照は追加しない。 |

---

## 参照

- `MASTER_PLAN.md`（TTS 配信原則・ADR）
- `docs/TTS_FLOW.md`・`docs/TTS_CDN_R2_ARCHITECTURE.md`
- `supabase/migrations/MIGRATION_CATALOG.md`
