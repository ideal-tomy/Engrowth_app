# デプロイ環境での Supabase 接続について

## クイックチェック（デプロイ後データが出ない場合）

| 確認項目 | ローカル | デプロイ |
|----------|----------|----------|
| 単語・センテンス・会話データが表示される | ✓ | ✗ |
| 3分ストーリーが表示される | ✓ | ✗ |
| シナリオ学習で「Null check」エラー | - | ✓ |

**→ ほぼ確実に「ビルド時に Supabase の URL/キーが埋め込まれていない」ことが原因です。**

---

## 現象

- **ローカル** (`flutter run`): データが表示される（.env を読むため）
- **デプロイ後** (Firebase Hosting など): 「単語が見つかりません」「センテンスがありません」「3分英会話は準備中です」「Null check operator used on a null value」など

## 原因

Flutter Web では、Supabase の接続情報（URL・APIキー）を**ビルド時**にコードに埋め込む必要があります。

- `.env` は**ローカル専用**。デプロイ後の Web アプリでは `.env` は読み込まれません。
- `flutter build web` を単体で実行すると:

- `--dart-define` で渡していない場合、`String.fromEnvironment` は空文字のまま
- `.env` はアセットとしてビルドに含まれるが、**デプロイ環境では読み込まれない**ことが多い
- その結果、Supabase の URL/キーが空になり、接続に失敗する

## 対処方法

### 方法1: デプロイ用ビルドスクリプトを使用（推奨）

**重要**: 必ず `engrowth_app` フォルダ（プロジェクトルート）で実行してください。

**Windows (PowerShell):**
```powershell
cd engrowth_app
.\scripts\build_for_deploy.ps1
firebase deploy
```

**Mac / Linux:**
```bash
cd engrowth_app
chmod +x scripts/build_for_deploy.sh
./scripts/build_for_deploy.sh
firebase deploy
```

このスクリプトはプロジェクトルートの `.env` を読み込み、`--dart-define` で Supabase の値を受け渡してビルドします。親フォルダ（demo など）から実行すると `.env` が見つかりません。

### 方法2: 手動で dart-define を指定してビルド

`.env` の値を直接指定する場合:

```powershell
flutter build web --release `
  --dart-define=SUPABASE_URL=https://munemrzmgaitfeejrtns.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=あなたのanon_key `
  --dart-define=ENABLE_GROUP_IMAGE_URLS=false
```

※ API キーは Git にコミットしないでください。スクリプト利用時は `.env`（`.gitignore` 対象）で管理します。

### 方法3: 環境変数から読み込んでビルド

```powershell
# PowerShell で環境変数を設定してから
$env:SUPABASE_URL = "https://xxx.supabase.co"
$env:SUPABASE_ANON_KEY = "your_key"
flutter build web --release --dart-define=SUPABASE_URL=$env:SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$env:SUPABASE_ANON_KEY
```

## デプロイ手順（Firebase Hosting）

1. 上記のいずれかの方法でビルド
2. 生成された `build/web` をデプロイ
   ```bash
   firebase deploy
   ```

## Supabase 側の設定確認

1. **Authentication → URL Configuration**
   - Site URL に `https://engrowth-app.web.app` を追加
   - Redirect URLs にも同様に追加

2. **RLS（Row Level Security）**
   - 未ログインでも参照可能なテーブルは、そのポリシーが正しく設定されているか確認
   - 認証必須のテーブルは、ログインしていないと空の結果になる

## トラブルシューティング

### 「.env が見つかりません」と表示される

- **原因**: 親フォルダ（例: `demo`）からスクリプトを実行している
- **対処**: `cd engrowth_app` でプロジェクトルートに移動してから実行
- **確認**: スクリプト実行時に "Project root:" と ".env path:" が表示されます。`.env` がそのパスに存在するか確認してください

### 「The term '.\scripts\build_for_deploy.ps1' is not recognized」

- **原因**: プロジェクトルート以外のフォルダで実行している（`engrowth_app` 内に `scripts` フォルダがある）
- **対処**: `cd engrowth_app` でプロジェクトフォルダに移動してから実行

### ビルド後の確認

ビルド後に `build/web/main.dart.js` を開き、Supabase の URL が含まれているか確認できます（機密情報を含むため、本番では慎重に扱ってください）。

### Null check エラー

「Null check operator used on a null value」は、Supabase の接続失敗時や、取得データが null の場合に発生することがあります。コード側で null を前提としたフォールバック処理を追加済みです。根本解決は、**正しいビルドスクリプトで Supabase の URL/キーを埋め込むこと**です。

### 次回デプロイから起動時にエラー表示

`main.dart` にチェックを追加済みです。Supabase の URL/キーが空のままビルドした場合、アプリ起動時に「Supabase の接続情報が設定されていません」というメッセージを表示します。
