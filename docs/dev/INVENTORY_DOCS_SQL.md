# ドキュメント・SQL 棚卸し台帳

リファクタリング Phase 1 の成果物。即対応 / 要確認 / 保留 に分類済み。実施時はこの台帳に従い、削除せず archive 移動を優先する。

---

## 1. MDファイル一覧

### 即対応（削除または統合）

| パス | アクション | 理由 |
|------|------------|------|
| `IMPLEMENTATION_ROADMAP.md` (ルート) | 削除 | REFACTORING_PLAN 明記。docs/archive/past_plans/ に同内容あり |
| `CLEANUP_FILES.md` (ルート) | 削除 | リファクタリング完了後、役目終了 |
| `docs/TEMP_BACKGROUND_SETUP.md` | archive へ移動 | ファイル名に TEMP、仮設定用。本番実装済みなら参照用に archive |

### 要確認（内容比較が必要）

| パス | アクション候補 | 理由 |
|------|----------------|------|
| `Googletss切り替え手順.md` (ルート) | 統合 or archive | docs/GOOGLE_TTS_SETUP.md と重複の可能性。ルート版は Firebase Functions 経由の詳細手順。統合先を明確化 |
| `docs/archive/completed/IMAGE_UPLOAD_QUICK_START.md` | 保持 or 統合 | docs/IMAGE_UPLOAD_GUIDE.md に包含されているか確認 |
| `docs/3MIN_STORY_GENERATION_GUIDE.md` | 役割明確化 | docs/3分ストーリー作成内容まとめ.md、docs/3MIN_STORY_TASK_CHECKLIST.md と重複・役割分担を整理 |
| `docs/CONTRADICTIONS_REPORT.md` | 確認後 archive | 矛盾点が解消済みか確認。解消済みなら archive |
| `docs/update.md` | リネーム & archive | 内容は音声ファースト設計書。ファイル名と不一致。`VOICE_FIRST_DESIGN_ARCHIVED.md` 等へ |

### 保留（実装/参照確認が必要）

| パス | 備考 |
|------|------|
| `docs/archive/VOICE_SUBMISSION_SETUP.md` | 実装完了済みか確認 |
| `docs/archive/completed/LEARNING_MODE_QUICK_START.md` | 現在の実装と照合 |
| `docs/archive/completed/IMAGE_DISPLAY_TEST.md` | 現在のテスト手順と照合 |
| `docs/archive/seed_stories/` 配下 | 実行済みSQLの雛形として保持を推奨 |

### 保持（正本・参照用）

| パス | 役割 |
|------|------|
| `README.md` | プロジェクト概要・セットアップ |
| `CONTRIBUTING.md` | コントリビューションガイド |
| `PROJECT_RULES.md` | プロジェクトルール |
| `docs/ANONYMOUS_AUTH_SETUP.md` | 匿名認証セットアップ |
| `docs/GOOGLE_TTS_SETUP.md` | Google TTS 簡易セットアップ |
| `docs/IMAGE_UPLOAD_GUIDE.md` | 画像アップロードガイド |
| `docs/DEPLOY_ENV_SETUP.md` | デプロイ・環境変数 |
| `docs/3MIN_STORY_GENERATION_GUIDE.md` | 3分ストーリー生成（要役割整理） |
| `docs/dev/REGRESSION_BASELINE.md` | 回帰確認基準 |
| `docs/dev/REFACTORING_PLAN.md` | リファクタリング計画 |
| `docs/dev/INVENTORY_DOCS_SQL.md` | 本台帳 |
| `.github/` 配下の md | テンプレート・ワークフロー用 |

### アーカイブ済み（移動不要）

| パス | 備考 |
|------|------|
| `docs/archive/past_plans/*` | 過去計画 |
| `docs/archive/completed/*` | 完了済み実装メモ |
| `docs/archive/VOICE_*` | 音声関連設計 |

---

## 2. SQLファイル一覧

### 運用入口（supabase/migrations）

| 種別 | 例 | 備考 |
|------|-----|------|
| スキーマ/マイグレーション | `database_*.sql` | テーブル・RLS・関数等 |
| シード | `seed_story_*.sql` | 3分ストーリー用データ |

### アーカイブ（docs/archive/seed_stories）

| ファイル例 | アクション | 理由 |
|------------|------------|------|
| `seed_story_*.sql` 一式 | 保持 | 実行済み・雛形として参照。3MIN_STORY_GENERATION_GUIDE で言及 |
| `seed_story_coffee_shop.sql` | 保持 | 雛形として使用中 |

### ルート/その他

| パス | アクション | 理由 |
|------|------------|------|
| `supabase_schema.sql` | 保持 | スキーマ参照用 |
| `supabase_storage_setup.sql` | 要確認 | 実装参照の有無を確認後、migrations へ集約 or archive |

### 即対応対象（CLEANUP_FILES.md 記載・存在する場合のみ）

以下はルートに存在する場合のみ削除。存在しなければ対象外。

- `CHECK_EXISTING_TABLES.sql`
- `CHECK_SENTENCES_COLUMNS.sql`
- `CHECK_TABLE_STATUS.sql`
- `CREATE_WORDS_TABLE.sql`
- `CREATE_WORDS_TABLE_FIXED.sql`
- `FIX_SENTENCES_TABLE.sql`
- `FIX_TABLE_NAMES.sql`
- `UPDATE_SENTENCES_TABLE.sql`

---

## 3. 実施時の注意

1. **削除は慎重に**: まず archive へ移動し、1サイクル運用後に削除検討。
2. **README リンク**: 移動・削除時に `README.md` のリンクを更新する。
3. **PROJECT_RULES**: `PROJECT_RULES.md` の参照パスを整合させる。
4. **SQL**: `supabase/migrations` 以外の実行済みSQLは即削除せず、`docs/archive/sql_legacy` へ退避。

---

## 4. Phase 2 実施記録

### 実施済み（2025-02-26）
- `IMPLEMENTATION_ROADMAP.md` (ルート): 削除
- `CLEANUP_FILES.md` (ルート): 削除
- `docs/TEMP_BACKGROUND_SETUP.md`: 削除（アーカイブ版を `docs/archive/TEMP_BACKGROUND_SETUP.md` に作成）
- `docs/update.md`: 削除（アーカイブ版を `docs/archive/VOICE_FIRST_DESIGN_ARCHIVED.md` に作成）
- `Googletss切り替え手順.md`: 削除（アーカイブ版を `docs/archive/GOOGLE_TTS_SWITCH_GUIDE.md` に作成）
- `GITHUB_SETUP.md` (ルート): 削除 → `docs/dev/GITHUB_SETUP.md` に移動
- `INITIAL_ISSUES.md` (ルート): 削除 → `docs/archive/INITIAL_ISSUES.md` に移動

### README リンク
- `README.md` は `CONTRIBUTING.md`, `PROJECT_RULES.md` を参照（ルートに保持のため変更なし）
- `docs/3MIN_STORY_GENERATION_GUIDE.md` は `PROJECT_RULES.md` を参照（ルートのため `../PROJECT_RULES.md` で可）

---

## 5. Phase 3 実施記録（SQL）

### 実施済み（2025-02-26）
- `supabase/migrations/` を唯一の運用入口として明文化
- `docs/dev/SQL_ORGANIZATION.md` を作成し、整理方針を文書化
- ルートの `CHECK_*.sql`, `CREATE_*.sql` 等は存在せず（CLEANUP 済み）
- `supabase_schema.sql`, `supabase_storage_setup.sql` はドキュメントから参照のためルートに保持

---

*Phase 1 完了時点: 2025-02-26*
*Phase 2 実施記録追加: 2025-02-26*
*Phase 3 実施記録追加: 2025-02-26*

## 6. Phase 4 実施記録（コード）

### 実施済み（2025-02-26）
- **終了確認ダイアログ共通化**: `lib/widgets/exit_confirmation_dialog.dart` を新規作成し、`StudyScreen` / `ScenarioStudyScreen` で利用
- **学習ログ共通化**: `LearningService.logLearningEnsuringSession` を追加し、両画面の `_logLearning` を置き換え

### 今後のタスク（別PR推奨）
- `conversation_study_screen.dart` の分割（1,754行）
- `scenario_progress_board_screen.dart` の分割（514行）
