# TTS 音声が鳴るか かんたん確認手順

**「実行したはずなのにダメ」のとき、どこが違うか1つずつ確認するための手順です。**

---

## この手順でわかること

- データベースに音声の「一覧表」があるか
- 音声ファイルの「保管庫」が正しく設定されているか
- 音声を作るための「秘密の鍵」が入っているか
- アプリが音声を正しく取りに行っているか

**1つでも欠けていると、音が鳴りません。**

---

## 確認の流れ（全体）

```
確認1: Supabase のウェブサイトを開く
  ↓
確認2: データベースに「音声一覧表」があるか
  ↓
確認3: 音声の「保管庫」が Public か
  ↓
確認4: 秘密の鍵（OPENAI_API_KEY）が入っているか
  ↓
確認5: ターミナルで「診断」を実行
  ↓
確認6: アプリで実際に再生してみる
  ↓
確認7: ログで「何が起きたか」を見る
```

---

## 確認1: Supabase のウェブサイトを開く

### やること

1. ブラウザで **https://supabase.com/dashboard** を開く
2. ログインする（まだならアカウント作成）
3. 左側の一覧から **自分のプロジェクト** をクリック

### プロジェクトがどれかわからないとき

- プロジェクト名は `engrowth` など、自分でつけた名前
- URL に `munemrzmgaitfeejrtns` のような英数字が入っていれば、それがプロジェクトの ID

### OK の目安

- プロジェクトの画面が開いて、左にメニュー（Table Editor, SQL Editor, Storage など）が並んでいる

---

## 確認2: データベースに「音声一覧表」があるか

### やること

1. 左のメニューで **「SQL Editor」** をクリック
2. 真ん中の白い（または黒い）入力欄に、下の文を**そのままコピーして貼り付け**
3. 右上の **「Run」** ボタン（または Ctrl+Enter）を押す

```sql
SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'tts_assets');
```

### 結果の見方

| 表示 | 意味 |
|------|------|
| **true** と出る | OK。音声の一覧表がある |
| **false** と出る | NG。一覧表がない。下の「NG のとき」を実行 |

### NG のとき

1. SQL Editor で **New query** をクリック
2. プロジェクト内の `supabase/migrations/database_tts_assets_migration.sql` を開く
3. その中身を**全部コピー**して、SQL Editor に貼り付け
4. **Run** を押す
5. エラーが出なければ、もう一度「確認2」の SQL を実行して `true` になるか確認

---

## 確認3: 音声の「保管庫」が Public か

### やること

1. 左のメニューで **「Storage」** をクリック
2. 一覧に **「tts-audio」** という名前のバケット（保管庫）があるか確認

### 結果の見方

| 表示 | 意味 |
|------|------|
| **tts-audio がある** | 次の「Public か」を確認 |
| **tts-audio がない** | NG。確認2の `database_tts_assets_migration.sql` を実行していれば作られる。もう一度確認2を実行 |

### Public かどうか

1. **tts-audio** の行をクリック
2. 右側または上に **「Public」** と書いてあれば OK
3. **「Private」** のときは、SQL Editor で次を実行:

```sql
UPDATE storage.buckets SET public = true WHERE id = 'tts-audio';
```

4. もう一度 Storage を開いて、**Public** になっているか確認

---

## 確認4: 秘密の鍵（OPENAI_API_KEY）が入っているか

音声を作るために、OpenAI というサービスを使います。そのためには「秘密の鍵」が必要です。

### やること

1. 左のメニュー下の方の **「Project Settings」**（歯車マーク）をクリック
2. 左のサブメニューで **「Edge Functions」** をクリック
3. **「Secrets」** というタブをクリック
4. 一覧に **「OPENAI_API_KEY」** があるか確認

### 結果の見方

| 表示 | 意味 |
|------|------|
| **OPENAI_API_KEY がある** | OK |
| **OPENAI_API_KEY がない** | NG。**「Add new secret」** をクリックし、名前を `OPENAI_API_KEY`、値に OpenAI の API キーを入れて保存 |

### API キーの取り方

- https://platform.openai.com/api-keys で OpenAI にログインして作成

---

## 確認5: ターミナルで「診断」を実行

パソコンの「黒い画面」（ターミナル）で、データベースとアプリの設定が合っているか確認します。

### やること

1. **Cursor** や **VS Code** でプロジェクトを開いた状態で、**ターミナル**を開く（下のパネル）
2. 次のコマンドを**1行ずつ**入力して Enter:

```powershell
cd c:\Users\ryoji\demo\engrowth_app
dart run scripts/diagnose_schema_gap.dart
```

### 結果の見方

| 表示 | 意味 |
|------|------|
| **OK tts_assets**、**OK user_stats**、**OK user_progress** と出る | OK。データベースの形は問題なし |
| **NG** と出る | その行に書いてある「→」の後のファイルを実行する（多くは `fix_schema_gap_user_stats_progress.sql`） |

### NG のとき

1. SQL Editor を開く
2. `supabase/migrations/fix_schema_gap_user_stats_progress.sql` を開いて中身をコピー
3. SQL Editor に貼り付けて **Run**
4. もう一度 `dart run scripts/diagnose_schema_gap.dart` を実行

---

## 確認6: アプリで実際に再生してみる

### やること

1. ターミナルで:

```powershell
cd c:\Users\ryoji\demo\engrowth_app
flutter run -d chrome
```

2. ブラウザでアプリが開いたら、**会話学習** を開く
3. **「会話を聴く」** のようなボタンをタップ
4. 音が鳴るか確認

### 結果の見方

| 結果 | 意味 |
|------|------|
| **音が鳴る** | OK。ここまでで十分 |
| **音が鳴らない** | 確認7へ。ログを見て原因を探す |
| **プログレスバーだけ進んで終わる** | 音声は届いているが再生できていない可能性。確認7へ |

---

## 確認7: ログで「何が起きたか」を見る

音が鳴らないとき、Supabase のログで「アプリが何を要求して、何が返ってきたか」を確認します。

### やること

1. Supabase の画面で、左のメニューから **「Edge Functions」** をクリック
2. **「tts_synthesize」** をクリック
3. **「Logs」** タブをクリック
4. 直近のログを上から見る

### 見るポイント

| ログに書いてあること | 意味 |
|----------------------|------|
| **cache_hit: true** | データベースから音声を取れた。再生まわりを疑う |
| **cache_hit: false** | データベースにヒットしなかった。prefill を実行する必要あり |
| **error** や **500** | 何かが失敗している。エラー内容を読む |

### cache_hit: false ばかりのとき

ターミナルで次を実行して、音声データをデータベースに投入する:

```powershell
cd c:\Users\ryoji\demo\engrowth_app
dart run scripts/prefill_tts_assets.dart --limit 10
```

エラーが出なければ:

```powershell
dart run scripts/prefill_tts_assets.dart
```

終わったら、もう一度アプリで再生を試す。

### 一括 prefill で課金するのに音声が残らないとき

**ストーリー単位の prefill** を使う（課金抑制・検証付き）:

```powershell
# 1ストーリーだけ（約40件）
dart run scripts/prefill_story_tts.dart "服飾店での試着と購入"

# 全ストーリー一括（1回の実行で全部）
dart run scripts/prefill_story_tts.dart --all
```

- 各件の前に DB を直接確認し、既にあれば Edge を呼ばない（課金ゼロ）
- Edge 呼び出し後、DB に書き込まれたか検証
- `--all` で全ストーリーを1回の実行で処理できる

1件だけ投入する場合:

```powershell
dart run scripts/prefill_single_text.dart "再生したいテキストをそのまま貼る"
```

---

## チェックリスト（実行したら✓をつける）

| # | 確認内容 | 結果 |
|---|----------|------|
| 1 | Supabase のダッシュボードを開けた | □ |
| 2 | tts_assets テーブルがある（SQL で true） | □ |
| 3 | Storage に tts-audio があり、Public | □ |
| 4 | Edge Functions の Secrets に OPENAI_API_KEY | □ |
| 5 | diagnose_schema_gap が全部 OK | □ |
| 6 | アプリで再生した | □ |
| 7 | ログで cache_hit を確認した | □ |

---

## どこで止まっているか

| 止まった場所 | 次にやること |
|--------------|--------------|
| 確認2で false | `database_tts_assets_migration.sql` を実行 |
| 確認3で tts-audio がない | 確認2の SQL を先に実行 |
| 確認3で Private のまま | `UPDATE storage.buckets...` を実行 |
| 確認4で OPENAI_API_KEY がない | Secrets に追加 |
| 確認5で NG が出る | `fix_schema_gap_user_stats_progress.sql` を実行 |
| 確認6で音が鳴らない | 確認7でログを確認。cache_hit=false なら prefill を実行 |
| 確認7で cache_hit=false ばかり | `dart run scripts/prefill_tts_assets.dart` を実行 |
| 確認7で cache_hit=true なのに無音 | ブラウザのオート再生制限の可能性。画面をタップしてから再生を試す |

---

## prefill 完了後の残作業（音声再生のため）

prefill が終わったあと、アプリで音声を再生するために確認すること:

| # | 確認内容 | やり方 |
|---|----------|--------|
| 1 | **tts-audio バケットが Public** | Supabase → Storage → tts-audio → Public か確認。Private なら `UPDATE storage.buckets SET public = true WHERE id = 'tts-audio';` を実行 |
| 2 | **アプリを再読み込み** | ブラウザで F5 または `flutter run -d chrome` を再実行 |
| 3 | **再生を試す** | 「3分一気に聴く」でストーリーを再生。画面をタップしてから再生（オート再生制限のため） |

**アプリ側の追加設定は不要**。prefill で tts_assets と Storage に保存済みなら、そのまま再生できる。

---

## AI に直接確認してもらう方法

### 方法A: URL のアクセス可否（設定画面に行かなくてよい）

1. ターミナルで実行:
   ```powershell
   dart run scripts/check_tts_url.dart
   ```
2. DevTools の Network タブで失敗した URL があれば、その URL を引数で渡す:
   ```powershell
   dart run scripts/check_tts_url.dart "https://...supabase.co/storage/v1/object/public/tts-audio/xxxx.mp3"
   ```
3. **`check_tts_result.txt`** ができる
4. AI に **「@check_tts_result.txt を確認して」** と依頼

→ AI が Status 200/403/404 を直接確認できます。設定画面への遷移は不要です。

### 方法B: TTS デバッグ出力（cache miss の詳細・犯人特定用）

1. アプリで「3分一気に聴く」を試す（cache miss が出る）
2. 設定（≡）→ **「TTS デバッグ出力」** をタップ
3. **「コピー」** をタップ
4. プロジェクトルートに **`debug_tts_output.txt`** として貼り付けて保存
5. AI に **「@debug_tts_output.txt を確認して原因を特定して」** と依頼

→ **recipe_raw**（ハッシュ化する前のレシピ生文字列）が含まれます。Supabase DB の値と目視比較して、小数点・空白・voice のズレを特定できます。コンソールにも `🚨 【犯人特定用】アプリ側のレシピ生文字列` が出力されます。

---

## それでもダメなとき

- **TTS_CACHE_FULL_RUNBOOK.md** の手順を最初から順番に実行する
- **TTS_DEBUG_CHECKLIST.md** の「原因切り分け」の表を見る
- Edge Functions の **「Invocations」** タブで、リクエストが成功（200）か失敗（500）かを確認する
