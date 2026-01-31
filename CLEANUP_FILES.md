# クリーンアップ対象ファイル

以下のファイルは開発中の一時的なガイドやセットアップ用ファイルです。
GitHubにpushする前に削除または整理することを推奨します。

## 削除推奨ファイル

### セットアップガイド（一時的なもの）
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

### SQLファイル（一時的なもの）
- `CHECK_EXISTING_TABLES.sql`
- `CHECK_SENTENCES_COLUMNS.sql`
- `CHECK_TABLE_STATUS.sql`
- `CREATE_WORDS_TABLE.sql`
- `CREATE_WORDS_TABLE_FIXED.sql`
- `FIX_SENTENCES_TABLE.sql`
- `FIX_TABLE_NAMES.sql`
- `UPDATE_SENTENCES_TABLE.sql`

### データファイル
- `Engrowthアプリ英単語データ - 4語制限.csv`
- `Engrowthアプリ英単語データ のコピー - 例文リスト02.csv`
- `words_import.csv`

### インストーラー
- `Git-2.52.0-64-bit.exe`

### PowerShellスクリプト（一時的なもの）
- `install_flutter.ps1`
- `set_user_path.ps1`

## 保持するファイル

### ドキュメント
- `README.md` - プロジェクト概要
- `CONTRIBUTING.md` - コントリビューションガイド
- `PROJECT_RULES.md` - プロジェクトルール
- `supabase_schema.sql` - データベーススキーマ（参考用）

### スクリプト
- `scripts/import_words.dart` - 単語インポートスクリプト
- `scripts/import_sentences.dart` - 例文インポートスクリプト

## クリーンアップ手順

```powershell
# セットアップガイドの削除
Remove-Item CHECK_*.md, CREATE_*.md, EASY_*.md, FLUTTER_*.md, SETUP_*.md, STEP_*.md, NEXT_*.md, QUICK_START.md, TABLE_*.md, FIX_*.md, IMPORT_*.md, MANUAL_*.md, DEVELOPMENT_PLAN.md

# SQLファイルの削除（一時的なもの）
Remove-Item CHECK_*.sql, CREATE_*.sql, FIX_*.sql, UPDATE_*.sql

# データファイルの削除
Remove-Item *.csv

# インストーラーの削除
Remove-Item *.exe

# PowerShellスクリプトの削除
Remove-Item install_*.ps1, set_*.ps1
```
