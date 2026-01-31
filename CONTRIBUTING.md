# コントリビューションガイドライン

## 開発フロー

### 1. Issueの作成
- 新機能やバグ修正は必ずIssueを作成してから開始
- Issueテンプレートを使用して、必要な情報を記載

### 2. ブランチの作成
```bash
# メインブランチから最新を取得
git checkout main
git pull origin main

# 新しいブランチを作成
git checkout -b feature/issue-番号-機能名
# 例: git checkout -b feature/issue-1-add-search-function
```

### 3. 開発
- 小さなコミットを心がける
- コミットメッセージは明確に
- 定期的にmainブランチから最新を取り込む

### 4. プッシュとPull Request
```bash
# ブランチをプッシュ
git push origin feature/issue-番号-機能名

# GitHubでPull Requestを作成
```

### 5. コードレビュー
- レビューを受けて、フィードバックに対応
- 承認後、mainブランチにマージ

## ブランチ命名規則

- `feature/issue-番号-機能名` - 新機能
- `fix/issue-番号-バグ名` - バグ修正
- `refactor/issue-番号-対象` - リファクタリング
- `docs/issue-番号-内容` - ドキュメント更新

## コミットメッセージ

```
[種類] 簡潔な説明

詳細な説明（必要に応じて）

Closes #Issue番号
```

種類:
- `feat`: 新機能
- `fix`: バグ修正
- `refactor`: リファクタリング
- `docs`: ドキュメント
- `style`: コードスタイル
- `test`: テスト
- `chore`: その他

## コーディング規約

- Dartの公式スタイルガイドに従う
- `flutter analyze`でエラーがないことを確認
- 可能な限り型安全なコードを書く

## Issue管理

- Issueは必ずラベルを付ける
- 進捗状況を定期的に更新
- 完了したIssueは適切にクローズ
