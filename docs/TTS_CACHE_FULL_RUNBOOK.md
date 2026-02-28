# TTS キャッシュ「最初から全部」手順書

**この順番を1つずつ実行する。飛ばさない。**

---

## コマンドだけ並べた一覧（詳細は下の Step 参照）

**ローカル Docker は不要。** `supabase status` は使わず、いきなりデプロイからでよい。

```powershell
cd c:\Users\ryoji\demo\engrowth_app
npx supabase functions deploy tts_synthesize --no-verify-jwt
dart pub get
dart run scripts/verify_tts_cache_hash.dart
dart run scripts/prefill_tts_assets.dart
dart run scripts/prefill_tts_assets.dart
```

※ 初回だけ「Project not linked」と出たら `npx supabase link --project-ref あなたのプロジェクトREF` を実行してから再度 deploy。  
※ Step 2 の SQL（tts_assets とバケットの確認・Public 化）は **Supabase Dashboard → SQL Editor** で手動実行。

---

## 前提

- プロジェクトルートが `engrowth_app` であること
- `.env` に `SUPABASE_URL` と `SUPABASE_SERVICE_ROLE_KEY`（または `SUPABASE_ANON_KEY`）が入っていること
- Supabase プロジェクトにログイン済み（`supabase login` 済み or リンク済み）

---

## Step 1: プロジェクトのリンク（未リンクならだけ）

**`supabase status` は使わない。** あれはローカル Docker 用で、リモートに Edge をデプロイするだけなら不要です（Docker がなくても deploy できます）。

いきなり **Step 4 の deploy** を実行してよい。そのとき:

- **「Project not linked」** と出たら、以下を実行してからもう一度 deploy:
  ```powershell
  npx supabase link --project-ref あなたのプロジェクトREF
  ```
  （プロジェクトREF = Supabase Dashboard → Project Settings → General の **Reference ID**。例: `munemrzmgaitfeejrtns`）
- すでにリンク済みなら deploy がそのまま進む。

---

## Step 2: tts_assets テーブルと tts-audio バケットがあるか確認

**Supabase Dashboard** → **SQL Editor** で次を実行:

```sql
SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'tts_assets');
SELECT id, name, public FROM storage.buckets WHERE id = 'tts-audio';
```

- 1行目が `true`、2行目に `tts-audio` の行が出ていれば OK。
- どちらか無い場合は、**SQL Editor** で以下を**この順で**実行する。

**2a. テーブル・バケット作成（未作成の場合のみ）**

`supabase/migrations/database_tts_assets_migration.sql` の内容をそのまま SQL Editor に貼り付けて実行。

**2b. バケットを Public にする**

SQL Editor で次を実行（結果は「1 row affected」などで、表は出ない）:

```sql
UPDATE storage.buckets SET public = true WHERE id = 'tts-audio';
```

**確認:** 同じ Editor で次を実行し、表の `public` 列が `true` なら OK:

```sql
SELECT id, name, public FROM storage.buckets WHERE id = 'tts-audio';
```

---

## Step 3: Edge Function のシークレット確認

**Supabase Dashboard** → **Project Settings** → **Edge Functions** → **Secrets**

- `OPENAI_API_KEY` が設定されていること。

無ければ追加して保存。

---

## Step 4: Edge Function をデプロイ

ターミナルで（プロジェクトルートで）:

```powershell
cd c:\Users\ryoji\demo\engrowth_app
npx supabase functions deploy tts_synthesize --no-verify-jwt
```

（`supabase` がそのまま使える環境なら `supabase functions deploy ...` でよい）

「Deployed successfully」系の表示になるまで待つ。失敗したらエラー内容を確認する。

---

## Step 5: 診断スクリプトで「DB と Edge の一致」を確認

```powershell
dart pub get
dart run scripts/verify_tts_cache_hash.dart
```

- **「DB にこの cache_key がありません」** → Step 6 の prefill で投入するのでこのままでよい。
- **「DB にこの cache_key が存在します」かつ「cache_hit = false」** → 本番 Edge がまだ古い。Step 4 をやり直し、デプロイが本当に成功しているか・別プロジェクトにデプロイしていないか確認する。
- **「cache_hit = true」** → すでにキャッシュが効いている。Step 6 は任意。Step 7 でアプリ確認へ。

---

## Step 6: prefill を1回だけ実行

```powershell
dart run scripts/prefill_tts_assets.dart
```

- 最初の1件で `1件目: cache_hit=true` なら、すでにキーが揃っている。
- `1件目: cache_hit=false` なら、この実行で約 1995 件が「今の Edge のルール」で DB に投入される。完了まで待つ（数十分かかることがある）。

エラーが多発する場合は `--limit 100` を付けて試す:

```powershell
dart run scripts/prefill_tts_assets.dart --limit 100
```

---

## Step 7: prefill をあと1回実行（ヒット確認）

```powershell
dart run scripts/prefill_tts_assets.dart
```

- **「キャッシュヒット 1995」に近い数字**になっていれば、キャッシュは有効。
- ヒットがほとんど増えない場合は、Step 5 の診断を再度実行し、  
  「DB にこの cache_key が存在します」なのに「cache_hit = false」かどうかで、**デプロイ先・Edge のバージョン**を再確認する。

---

## Step 8: アプリで再生して確認

1. アプリを起動（実機 or シミュレータ）
2. 会話学習で「会話を聴く」をタップ
3. **1回目から**遅延なく再生が始まれば成功

まだ遅い場合:

- **Supabase Dashboard** → **Edge Functions** → **tts_synthesize** → **Logs** で、直近のリクエストに `cache_hit: true` が出ているか確認する。
- すべて `cache_hit: false` なら、アプリから呼ばれている Edge が別プロジェクトのものか、まだ古いバージョンのままになっていないか確認する。

---

## チェックリスト（実行時につける）

| # | やること | 済 |
|---|----------|----|
| 1 | （スキップ可）未リンクなら deploy 時に link | □ |
| 2 | SQL で tts_assets と tts-audio 存在確認。なければ migration 実行 & `UPDATE storage.buckets` で public=true | □ |
| 3 | Dashboard で OPENAI_API_KEY 設定確認 | □ |
| 4 | `npx supabase functions deploy tts_synthesize --no-verify-jwt` を実行 | □ |
| 5 | `dart run scripts/verify_tts_cache_hash.dart` で結果確認 | □ |
| 6 | `dart run scripts/prefill_tts_assets.dart` を1回実行 | □ |
| 7 | prefill をあと1回実行し、ヒット数確認 | □ |
| 8 | アプリで「会話を聴く」を再生して体感確認 | □ |

---

## Step 9: 先読み・重複音声の確認（任意）

**先読みが効いているか**
- シナリオ学習 or 会話一覧を開く → 数秒待ってからカードをタップ → 会話画面で再生
- 1回目から即再生されれば先読みが効いている（DB 直参照または一覧ウォームアップが働いている）

**重複音声が出ないか**
- 会話全体を聴く再生中、OpenAI と flutter_tts が同時に流れないこと。重なったらフォールバック経路の不具合の可能性。

**KPI 確認（analytics_events に記録されている場合）**

```sql
SELECT event_type, event_properties
FROM analytics_events
WHERE event_type IN ('tts_request', 'tts_playback_session')
ORDER BY created_at DESC
LIMIT 20;
```

- `tts_request`: `tts_source` が `direct_db` なら DB 直参照ヒット、`edge` なら Edge 経由
- `tts_playback_session`: `first_utterance_prefetched`, `first_5_prefetch_hit_count`, `flutter_fallback_count` で初回・先頭5件のヒット率・フォールバック回数を確認

---

## それでもダメなとき（切り分けフロー）

| 症状 | 想定原因 | 確認・対策 |
|------|----------|------------|
| 1回目が遅い、2回目は速い | 先読み未実行 or DB未ヒット | 一覧を開いてからカードをタップしているか。Step 5 で cache_key が DB に存在するか確認 |
| 毎回遅い | DB未命中・Edge Cold Start | Step 5 の診断、prefill 再実行。Edge Logs で `cache_hit` を確認 |
| 音声が二重に流れる | flutter_tts フォールバック重複 | アプリを最新に更新。ログで `tts_fallback` が多発していないか確認 |
| Edge に `cache_hit: false` ばかり | ハッシュ不一致 or prefill 未実施 | Step 5 の `verify_tts_cache_hash.dart` を再実行。prefill を再実施 |

**控えるべき情報**
- Step 5 の出力（「DB にこの cache_key が存在します」かどうか、`cache_hit = true/false`）
- Dashboard → Edge Functions → tts_synthesize → Logs の直近ログ
- `analytics_events` の `tts_request` / `tts_playback_session` の直近数件
