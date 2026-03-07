# TTS キャッシュ「最初から全部」手順書

**この順番を1つずつ実行する。飛ばさない。**

---

## 初心者向け: 各章の確認ポイント

| 章 | 何を確認するか | 成功条件 | 失敗時次アクション |
|----|----------------|----------|-------------------|
| 前提 | プロジェクトルート・.env・Supabase ログイン | ターミナル実行・Dashboard 閲覧が可能 | 権限不足時は Owner に招待依頼、CLI 未準備時は Node/NPM セットアップ |
| Step 2 | tts_assets テーブル・tts-audio バケット(public) | SQL で true / public=true | migration 実行、`UPDATE storage.buckets` |
| Step 3 | Edge Secrets に OPENAI_API_KEY | Dashboard で確認可能 | Secrets に追加 |
| Step 4 | tts_synthesize デプロイ | Deployed successfully | Project not linked なら `supabase link` |
| Step 5 | DB と Edge の cache_key 一致 | verify で cache_hit=true または DB=なし | Edge 再デプロイ、接続先 URL 確認 |
| Step 6-7 | prefill 実行・2回目ヒット | 2回目でキャッシュヒット増加 | `--limit` で分割、verify でキー不一致確認 |
| Step 8 | アプリで再生 | 1回目から遅延なく再生 | Edge Logs で cache_hit 確認、TTS_DEBUG_CHECKLIST 参照 |

**障害切り分け**は `docs/TTS_DEBUG_CHECKLIST.md` を参照。

---

## 完了判定SQL（毎回同じ手順で合否を出す）

本番切替後、Supabase SQL Editor で次を実行し、期待と一致するか確認する。

```sql
-- 1) 直近24hのキャッシュ利用状況
SELECT
  event_properties->>'tts_source' AS tts_source,
  COUNT(*) AS cnt,
  ROUND(AVG((event_properties->>'latency_ms')::int)) AS avg_latency_ms
FROM analytics_events
WHERE event_type = 'tts_request'
  AND created_at > NOW() - INTERVAL '24 hours'
GROUP BY 1
ORDER BY cnt DESC;

-- 2) direct_db vs edge の内訳（edge 偏重でないか）
SELECT
  COUNT(*) FILTER (WHERE event_properties->>'path_taken' = 'edge') AS edge_count,
  COUNT(*) FILTER (WHERE event_properties->>'path_taken' = 'direct_db') AS direct_db_count
FROM analytics_events
WHERE event_type = 'tts_request'
  AND created_at > NOW() - INTERVAL '24 hours';
```

期待: `direct_db_count` が主、`edge_count` は未prefill文や動的文に限定。analytics_events が無い場合は Edge Logs で `cache_hit` を確認。

---

## 本番切替手順（固定・再実行ループを止める）

**毎回同じ順で実行する。1回の切替で完了可否を判定する。**

1. **Edge deploy** → `npx supabase functions deploy tts_synthesize --no-verify-jwt`
2. **prefill（小さく試す）** → `dart run scripts/prefill_tts_assets.dart --limit 10`（初回は必ず小規模で確認）
3. **prefill（全量）** → `dart run scripts/prefill_tts_assets.dart`
4. **2回目 prefill（ヒット確認）** → `dart run scripts/prefill_tts_assets.dart`（キャッシュヒット数が増えていること）
5. **app 確認** → 会話学習で「会話を聴く」を再生
6. **完了判定** → 上記 SQL を実行し、期待と一致するか確認

※ Step 2〜3（tts_assets / バケット）が未整備の場合は先に実施。詳細は下記 Step 参照。

### キャッシュ整合確認フロー（再現性固定）

| 手順 | コマンド | 成功条件 |
|------|----------|----------|
| 1. ハッシュ突合 | `dart run scripts/verify_tts_cache_hash.dart` | DB と Edge の cache_key が一致 |
| 2. 特定テキスト検証 | `dart run scripts/verify_tts_cache_hash.dart --text "Edgeログのテキスト"` | DB=あり かつ Edge_cache_hit=true |
| 3. 複数サンプル | `dart run scripts/verify_tts_cache_hash.dart --samples 10` | 全件 DB=あり Edge_cache_hit=true |

Edge ログで `cache_hit=false` のログを1件選び、`cache_key_preview` のテキスト部分（最初の `|` より前）をコピーして `--text` に指定すると、その発話だけを検証できる。

---

## コマンドだけ並べた一覧（詳細は下の Step 参照）

**ローカル Docker は不要。** `supabase status` は使わず、いきなりデプロイからでよい。

```powershell
cd c:\Users\ryoji\demo\engrowth_app
npx supabase functions deploy tts_synthesize --no-verify-jwt
dart pub get
dart run scripts/verify_tts_cache_hash.dart
dart run scripts/prefill_tts_assets.dart --limit 10
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

**接続先確認**: `.\scripts\verify_supabase_env.ps1` で prefill・アプリ・デプロイ先が同じ Supabase プロジェクトか確認できる。

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

## Step 6: prefill を実行（小さく試す→全量）

**初回は必ず小規模で確認する。**

```powershell
dart run scripts/prefill_tts_assets.dart --limit 10
```

- エラーなく完了すれば、全量を実行:

```powershell
dart run scripts/prefill_tts_assets.dart
```

- 最初の1件で `1件目: cache_hit=true` なら、すでにキーが揃っている。
- `1件目: cache_hit=false` なら、この実行で約 1995 件が「今の Edge のルール」で DB に投入される。完了まで待つ（数十分かかることがある）。

エラーが多発する場合は `--limit 100` で段階的に試す。

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
| 6 | `dart run scripts/prefill_tts_assets.dart --limit 10` で小規模確認後、全量実行 | □ |
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

## 原因切り分け: cache問題 vs 再生問題

| 症状 | 切り分け | 確認・対策 |
|------|----------|------------|
| 音が鳴らない | Edge Logs で `cache_hit` を確認 | `cache_hit=true` → 再生問題（Web autoplay / network）。`tts_web_play_error` の error_type を確認 |
| 音が鳴らない | 同上 | `cache_hit=false` → cache問題。prefill 再実行、`verify_tts_cache_hash.dart --samples 10` で検証 |
| 毎回遅い | direct_db 比率が低い | analytics_events で `path_taken='direct_db'` の割合を確認。低ければ prefill 不足 or キー不一致 |

複数サンプル検証: `dart run scripts/verify_tts_cache_hash.dart --samples 10`

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
