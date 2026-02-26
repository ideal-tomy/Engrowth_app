# GitHubリポジトリセットアップ手順

## ステップ1: Gitリポジトリの初期化

```powershell
# Gitリポジトリを初期化
git init

# リモートリポジトリを追加
git remote add origin https://github.com/ideal-tomy/Engrowth_app.git
```

## ステップ2: 不要ファイルの削除（オプション）

クリーンアップを実行する場合：

```powershell
# セットアップガイドの削除
Remove-Item CHECK_*.md, CREATE_*.md, EASY_*.md, FLUTTER_*.md, SETUP_*.md, STEP_*.md, NEXT_*.md, QUICK_START.md, TABLE_*.md, FIX_*.md, IMPORT_*.md, MANUAL_*.md, DEVELOPMENT_PLAN.md -ErrorAction SilentlyContinue

# SQLファイルの削除（一時的なもの）
Remove-Item CHECK_*.sql, CREATE_*.sql, FIX_*.sql, UPDATE_*.sql -ErrorAction SilentlyContinue

# データファイルの削除
Remove-Item *.csv -ErrorAction SilentlyContinue

# インストーラーの削除
Remove-Item *.exe -ErrorAction SilentlyContinue

# PowerShellスクリプトの削除
Remove-Item install_*.ps1, set_*.ps1 -ErrorAction SilentlyContinue
```

**注意**: 削除前に、必要なファイルがないか確認してください。

## ステップ3: 初回コミット

```powershell
# すべてのファイルをステージング
git add .

# 初回コミット
git commit -m "feat: 初回コミット - Engrowthアプリの基本実装

- Flutter + Supabase構成
- 単語リスト機能
- 例文リスト機能
- 学習モード
- 進捗管理機能"
```

## ステップ4: メインブランチの設定とプッシュ

```powershell
# ブランチ名をmainに変更（GitHubのデフォルト）
git branch -M main

# リモートにプッシュ
git push -u origin main
```

## ステップ5: GitHubで確認

1. https://github.com/ideal-tomy/Engrowth_app にアクセス
2. ファイルが正しくアップロードされているか確認
3. Issueテンプレートが表示されているか確認

## 次のステップ

### Issueの作成

1. GitHubリポジトリの「Issues」タブを開く
2. 「New issue」をクリック
3. テンプレートを選択（機能追加 / バグ報告 / リファクタリング）
4. Issueを作成

### ブランチの作成

```powershell
# 例: Issue #1 の機能追加
git checkout -b feature/issue-1-add-search-function

# 開発後、コミット
git add .
git commit -m "feat: 検索機能を追加

Closes #1"

# プッシュ
git push origin feature/issue-1-add-search-function
```

### Pull Requestの作成

1. GitHubで「Pull requests」タブを開く
2. 「New pull request」をクリック
3. ブランチを選択
4. PRテンプレートに従って記入
5. レビューを依頼

## トラブルシューティング

### 認証エラーが発生する場合

```powershell
# GitHub CLIを使用する場合
gh auth login

# または、Personal Access Tokenを使用
git remote set-url origin https://YOUR_TOKEN@github.com/ideal-tomy/Engrowth_app.git
```

### 大きなファイルでエラーが出る場合

`.gitignore`に追加されていることを確認：
- `build/` ディレクトリ
- `.env` ファイル
- CSVファイル
- その他の一時ファイル
