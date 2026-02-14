# Engrowth - 英会話学習アプリ

画像と例文を組み合わせた英会話学習アプリです。Duo 3.0を意識したデザインで、効率的な英会話学習をサポートします。

## 🚀 機能

- **単語リスト**: 1000単語の一覧表示、検索、グループ別フィルタ
- **例文リスト**: 画像付き例文の一覧表示
- **学習モード**: 画像と例文を組み合わせた暗記学習、進捗管理
- **進捗管理**: 学習済み/未学習の管理、進捗率表示

## 📋 要件

- Flutter 3.0以上
- Dart 3.0以上
- Supabaseアカウント

## 🛠️ セットアップ

### 1. リポジトリのクローン

```bash
git clone https://github.com/ideal-tomy/Engrowth_app.git
cd Engrowth_app
```

### 2. 依存パッケージのインストール

```bash
flutter pub get
```

### 3. Supabaseプロジェクトの作成

1. [Supabase](https://supabase.com)でアカウントを作成
2. 新しいプロジェクトを作成
3. プロジェクトのURLとanon keyを取得

### 4. データベーススキーマの作成

Supabase DashboardのSQL Editorで `supabase_schema.sql` を実行してください。

### 5. 環境変数の設定

`.env`ファイルを作成し、Supabaseの認証情報を設定：

```env
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

### 6. データのインポート

```bash
# 単語データのインポート
dart run scripts/import_words.dart

# 例文データのインポート
dart run scripts/import_sentences.dart
```

## 🏃 実行

### 開発環境で実行

```bash
# Web
flutter run -d chrome

# Android
flutter run

# iOS
flutter run
```

### ビルド

```bash
# Android APK
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

## 📁 プロジェクト構造

```
lib/
├── models/          # データモデル
├── services/        # SupabaseサービスとCSVインポート
├── providers/       # Riverpodプロバイダー
├── screens/         # 画面
├── widgets/         # 再利用可能なウィジェット
└── utils/           # ユーティリティ

scripts/             # データインポートスクリプト
```

## 🌐 Firebase Hosting デプロイ（推奨）

Flutter Web を Firebase Hosting にデプロイする方法です。**ローカルでビルド**するため、サーバーに Flutter を入れる必要がなく、確実にデプロイできます。

### 初回セットアップ

1. **Firebase CLI のインストール**
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

2. **Firebase プロジェクトの紐付け**（初回のみ）
   ```bash
   firebase init hosting
   ```
   - 既存の Firebase プロジェクトを選択するか新規作成
   - 「What do you want to use as your public directory?」→ `build/web`
   - 既存の `firebase.json` がある場合、上書きせず **No** を選ぶ

### デプロイ手順

1. **環境変数の準備**  
   `.env` に `SUPABASE_URL` と `SUPABASE_ANON_KEY` を設定済みであること。

2. **デプロイ実行**
   ```bash
   # macOS / Linux
   ./scripts/deploy_firebase.sh

   # Windows (PowerShell)
   .\scripts\deploy_firebase.ps1
   ```

   または手動で：
   ```bash
   flutter build web --release \
     --dart-define=SUPABASE_URL=あなたのURL \
     --dart-define=SUPABASE_ANON_KEY=あなたのキー
   firebase deploy --only hosting
   ```

3. デプロイ後、`https://プロジェクトID.web.app` で公開されます。

## 🤝 コントリビューション

コントリビューションを歓迎します！詳細は [CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。

### 開発フロー

1. Issueを作成
2. ブランチを作成（`feature/issue-番号-機能名`）
3. 開発・コミット
4. Pull Requestを作成
5. コードレビュー
6. マージ

詳細は [PROJECT_RULES.md](PROJECT_RULES.md) を参照してください。

## 📝 ライセンス

このプロジェクトのライセンス情報は後日追加予定です。

## 🔗 リンク

- [Supabase](https://supabase.com)
- [Flutter](https://flutter.dev)
