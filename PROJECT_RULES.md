# プロジェクトルール

## 開発方針

### Issue駆動開発
- **すべての作業はIssueから始まる**
- 新機能、バグ修正、リファクタリングは必ずIssueを作成
- Issue番号をブランチ名に含める

### ブランチ戦略
- `main`: 本番環境用（常に安定版）
- `develop`: 開発用メインブランチ（オプション）
- `feature/*`: 新機能開発
- `fix/*`: バグ修正
- `refactor/*`: リファクタリング

### コミット規約
- コミットメッセージは明確に
- Issue番号を参照（`Closes #123`）
- 小さなコミットを心がける

## コード品質

### 必須チェック
- `flutter analyze` でエラーがないこと
- ビルドが成功すること
- 基本的な動作確認ができていること

### 推奨
- テストコードの追加（可能な範囲で）
- ドキュメントコメントの追加
- 型安全性の確保

## ファイル管理

### コミットしないファイル
- `.env`（環境変数）
- ビルド成果物（`build/`）
- 一時的なセットアップガイド（`*_SETUP.md`, `*_GUIDE.md`など）
- CSVデータファイル（機密情報を含む可能性）

### ドキュメント
- `README.md`: プロジェクト概要とセットアップ
- `CONTRIBUTING.md`: コントリビューションガイド
- `PROJECT_RULES.md`: このファイル

## Issue管理

### ラベル
- `enhancement`: 新機能
- `bug`: バグ
- `refactoring`: リファクタリング
- `documentation`: ドキュメント
- `frontend`: フロントエンド関連
- `backend`: バックエンド関連
- `database`: データベース関連
- `ui/ux`: UI/UX関連

### 優先度
- `priority: high`: 緊急
- `priority: medium`: 通常
- `priority: low`: 低優先度

## レビュープロセス

1. Pull Requestを作成
2. 自動チェック（CI/CD）が通ることを確認
3. コードレビューを依頼
4. フィードバックに対応
5. 承認後、マージ

## セキュリティ

- 認証情報は絶対にコミットしない
- `.env`ファイルは`.gitignore`に含まれていることを確認
- Supabaseのキーは環境変数で管理

## リリース

- タグを使用してバージョン管理
- リリースノートを作成
- 変更内容を明確に記載

## 3分英会話ストーリー生成（参照ルール）

3分英会話を生成する際は以下に従う。詳細は `docs/prompts/3min_story_generation_rules.md` を参照。

- **単語リスト**: `Engrowthアプリ英単語データ - 本番用 (1).csv` または `assets/csv/words_master_1000.csv`、`words_slot_*.csv`
- **仕様**: 1ストーリー＝約300〜450語、指定単語から10〜15語を自然に組み込む
- **出力**: story_sequences → conversations（story_sequence_id, story_order）→ conversation_utterances の INSERT SQL
- **スロット管理**: 50語単位で区切り、重複を抑制。`docs/slot_usage_template.csv` で使用済みを記録
