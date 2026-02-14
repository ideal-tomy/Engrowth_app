# プロジェクトリファクタリング計画

## 1. 目的

本計画は、`engrowth_app` プロジェクトのファイル構造を整理し、保守性と開発効率を向上させることを目的とします。開発初期段階で作成された一時ファイルや重複したドキュメントを整理し、クリーンな状態を目指します。

## 2. リファクタリング対象と方針

### 2.1. ドキュメントの整理 (`.md` ファイル)

- **方針**: ルートディレクトリにあるドキュメントを `docs` ディレクトリに集約し、情報の重複を解消します。完了済みのドキュメントはアーカイブします。
- **対象ファイルとアクション**:
    - **移動**:
        - `CONTRIBUTING.md` → `docs/CONTRIBUTING.md`
        - `GITHUB_SETUP.md` → `docs/dev/GITHUB_SETUP.md`
        - `PROJECT_RULES.md` → `docs/PROJECT_RULES.md`
        - `INITIAL_ISSUES.md` → `docs/archive/INITIAL_ISSUES.md` (内容は `docs/ALL_ISSUES_LIST.md` に統合されていると想定)
    - **削除**:
        - `IMPLEMENTATION_ROADMAP.md` (ルート): `docs/IMPLEMENTATION_ROADMAP.md` に内容が包含・更新されているため削除。
        - `CLEANUP_FILES.md`: このリファクタリング計画で役目を終えるため削除。
    - **アーカイブ**:
        - `docs/completed` ディレクトリ → `docs/archive/completed` に移動。

### 2.2. データベース関連ファイルの整理 (`.sql` ファイル)

- **方針**: ルートディレクトリに散在するマイグレーション用SQLファイルを `supabase/migrations` ディレクトリに集約します。これにより、Supabase CLIによるマイグレーション管理が容易になります。
- **対象ファイルとアクション**:
    - **移動**:
        - `database_achievement_migration.sql`
        - `database_conversation_import_policies.sql`
        - `database_conversation_migration.sql`
        - `database_migration.sql`
        - `database_review_optimization_migration.sql`
        - `database_scenario_migration.sql`
        - `database_user_stats_migration.sql`
        
        上記すべてを `supabase/migrations/` ディレクトリに移動します。

### 2.3. 不要な一時ファイルの削除

- **方針**: `CLEANUP_FILES.md` のリストに基づき、現在は不要となった開発初期のセットアップガイドや一時データを削除します。
- **対象ファイル**:
    - `CHECK_STATUS.md`
    - `CREATE_ENV.md`
    - `EASY_INSTALL.md`
    - `FLUTTER_INSTALL.md`
    - `SETUP_GUIDE.md`
    - `STEP_BY_STEP.md`
    - `NEXT_STEPS.md`
    - `QUICK_START.md`
    - `TABLE_SETUP_GUIDE.md`
    - `FIX_INDEX_ERROR.md`
    - `IMPORT_CSV_GUIDE.md`
    - `MANUAL_SETUP_GUIDE.md`
    - `DEVELOPMENT_PLAN.md`
    - `CHECK_EXISTING_TABLES.sql`
    - `CHECK_SENTENCES_COLUMNS.sql`
    - `CHECK_TABLE_STATUS.sql`
    - `CREATE_WORDS_TABLE.sql`
    - `CREATE_WORDS_TABLE_FIXED.sql`
    - `FIX_SENTENCES_TABLE.sql`
    - `FIX_TABLE_NAMES.sql`
    - `UPDATE_SENTENCES_TABLE.sql`
    - `Engrowthアプリ英単語データ - 4語制限.csv`
    - `Engrowthアプリ英単語データ のコピー - 例文リスト02.csv`
    - `words_import.csv`
    - `Git-2.52.0-64-bit.exe`
    - `install_flutter.ps1`
    - `set_user_path.ps1`
    
    *(注: これらのファイルは現在のディレクトリに存在しない可能性があります。存在するもののみを削除対象とします。)*

## 3. 実行手順

1.  **`supabase/migrations` ディレクトリの作成**: データベースマイグレーションファイルを格納するためのディレクトリを作成します。
2.  **SQLファイルの移動**: 上記「2.2」に従い、`.sql` ファイルを `supabase/migrations` に移動します。
3.  **ドキュメントの移動と整理**: 上記「2.1」に従い、`.md` ファイルの移動、削除、アーカイブを実行します。
4.  **一時ファイルの削除**: 上記「2.3」のリストにあるファイルが存在する場合、それらを削除します。
5.  **`REFACTORING_PLAN.md` の更新**: 全ての操作が完了したら、このファイルを `docs/dev/REFACTORING_PLAN.md` に移動し、完了した旨を記録します。

---
**承認後、上記の手順を順次実行します。**
