# Firebase Hosting デプロイ手順

## 前提条件
- Flutter がインストール済み
- Firebase CLI がインストール済み (`npm install -g firebase-tools`)
- .env に SUPABASE_URL, SUPABASE_ANON_KEY が設定済み

---

## ステップ 1: Firebase CLI にログイン

ブラウザで Firebase Console にログインしているだけでは不十分です。**ターミナルから Firebase CLI 用にログイン**する必要があります。

```powershell
firebase login
```

ブラウザが開くので、Google アカウントでログインしてください。

---

## ステップ 2: Firebase プロジェクトの作成（未作成の場合）

### 方法A: Firebase Console で作成（おすすめ）
1. https://console.firebase.google.com/ を開く
2. 「プロジェクトを追加」→ プロジェクト名を入力（例: `engrowth-app`）
3. Google Analytics はオプション（スキップ可）
4. 作成完了後、**プロジェクト ID** を控える（例: `engrowth-app-12345`）

### 方法B: 既存プロジェクトがある場合
すでに Firebase プロジェクトがある場合はそのプロジェクト ID を使用できます。

---

## ステップ 3: プロジェクトをリンク

プロジェクトルートで実行：

```powershell
firebase use --add
```

- 表示された一覧からプロジェクトを選択（矢印キー + Enter）
- エイリアス名を聞かれたら `default` のまま Enter

これで `.firebaserc` が作成されます。

---

## ステップ 4: デプロイ実行

```powershell
.\scripts\deploy_firebase.ps1
```

これで `flutter build web` → `firebase deploy --only hosting` が自動で実行されます。

---

## トラブルシューティング

### 「Failed to list Firebase projects」「401 Unauthenticated」
→ ステップ 1 の `firebase login` を再度実行してください。

### 「.firebaserc がない」「Which project do you want to use?」
→ ステップ 3 の `firebase use --add` を実行してください。

### 「No project active」
→ `firebase use プロジェクトID` でプロジェクトを指定してください。
