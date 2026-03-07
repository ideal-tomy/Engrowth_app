# TTS Edge Function デバッグチェックリスト

## キャッシュ契約の固定（PR1 完了判定）

speed=1.0、voice=alloy で統一。UI速度は再生側で playbackRate 適用。

```sql
-- PR1 完了判定: voice が alloy のみ、speed が 1.0 のみ
SELECT voice, COUNT(*) FROM tts_assets GROUP BY voice;
SELECT speed, COUNT(*) FROM tts_assets GROUP BY speed ORDER BY speed;
```

## PR2 完了判定（prefill 対象拡張後）

```sql
-- 直近24hの投入量
SELECT DATE_TRUNC('hour', created_at) AS h, COUNT(*)
FROM tts_assets
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY 1
ORDER BY 1 DESC;

-- 言語カバレッジ
SELECT language, COUNT(*) FROM tts_assets GROUP BY language ORDER BY language;
```

## PR3 完了判定（原因切り分け）

**cache問題** vs **再生問題** の分岐:

| 症状 | 切り分け | 確認SQL |
|------|----------|---------|
| 音が鳴らない | Edge Logs で `cache_hit=true` か | 下記 SQL で direct_db 比率確認 |
| cache_hit=true なのに無音 | **再生問題**（Web autoplay / network） | `tts_web_play_error` の error_type |
| TimeoutException 10秒 | **URL 読み込み失敗**（onCanPlay が発火しない） | DevTools Network で URL の 403/404 確認 |
| cache_hit=false ばかり | **cache問題**（prefill 不足 / キー不一致） | `verify_tts_cache_hash.dart --samples 10` |

```sql
-- direct_db 比率（直近24h）
SELECT
  ROUND(100.0 * COUNT(*) FILTER (WHERE event_properties->>'path_taken' = 'direct_db')
    / NULLIF(COUNT(*), 0), 1) AS direct_db_rate_pct,
  COUNT(*) AS total
FROM analytics_events
WHERE event_type = 'tts_request'
  AND created_at > NOW() - INTERVAL '24 hours';

-- Web再生失敗の内訳（autoplay 切り分け）
SELECT event_properties->>'error_type' AS error_type, COUNT(*)
FROM analytics_events
WHERE event_type = 'tts_web_play_error'
  AND created_at > NOW() - INTERVAL '24 hours'
GROUP BY 1
ORDER BY 2 DESC;
```

## 原因カテゴリの切り分け（30分以内）

| カテゴリ | 症状 | 確認方法 |
|----------|------|----------|
| **DB** | direct_db 比率が低い、db_result=timeout/error が多い | analytics_events の `tts_request` で `tts_source`, `db_result`, `db_elapsed_ms` を確認 |
| **Edge** | 5秒超の遅延、edge 経路が多い | Supabase Invocations の実行時間、Edge Logs の `db_query_ms`, `openai_ms`, `cache_hit` |
| **WebPolicy** | シークレットで無音、not_allowed | `tts_web_play_error` の `error_type=not_allowed` |
| **競合** | flutter_tts と重なる、二重再生 | `tts_fallback` の `path_taken`, `tts_playback_session` の `flutter_fallback_count` |

## 10秒タイムアウト（TimeoutException）の切り分け

`TimeoutException after 0:00:10.000000` は、`openai_tts_playback_web.dart` の `onCanPlay` が 10 秒以内に発火しなかったことを意味する。＝**音声 URL の読み込みが完了していない**。

### 確認手順

1. **DevTools を開いた状態で再生を実行**（Network タブで `tts` や `storage` でフィルタ）
2. 再生ボタンをタップしてリクエストを発生させる
3. Network タブで `tts-audio` や `object/public` を含むリクエストを確認
4. そのリクエストの **Status** を確認:
   - **200** → 読み込み成功しているはず。オート再生制限の可能性
   - **403** → `tts-audio` バケットが Private のまま。`UPDATE storage.buckets SET public = true WHERE id = 'tts-audio';` を実行
   - **404** → `storage_path` と Storage の実ファイルが食い違っている。prefill 再実行を検討

### 参考

- 詳細フロー: `docs/TTS_FLOW.md`

## analytics_events について（テーブルがない場合）

**1995件のキャッシュ** は `tts_assets` テーブルと Storage の `tts-audio` バケット（音声メタ＋MP3）です。prefill で投入済みなら存在します。

**analytics_events** は別テーブルで、`tts_request` や `tts_web_play_error` などの観測イベントを保存します。TTS_DEBUG_CHECKLIST の SQL はこれを参照します。

- **`relation "analytics_events" does not exist` が出る場合**  
  → `supabase/migrations/database_analytics_events.sql` を Supabase SQL Editor で実行してテーブルを作成してください。
- **analytics_events をまだ作っていない場合**  
  → 下記 SQL の代わりに、**Edge Functions → tts_synthesize → Logs / Invocations** で直接確認してください（`db_query_ms`, `openai_ms`, `cache_hit` など）。

## 「5秒の壁」判定クエリ

```sql
-- 直近7日: tts_source 別の平均遅延・件数
SELECT
  event_properties->>'tts_source' AS tts_source,
  COUNT(*) AS cnt,
  ROUND(AVG((event_properties->>'latency_ms')::int)) AS avg_latency_ms
FROM analytics_events
WHERE event_type = 'tts_request'
  AND created_at > NOW() - INTERVAL '7 days'
GROUP BY event_properties->>'tts_source';

-- direct_db 比率（低下時は DB timeout / キー不一致を疑う）
SELECT
  ROUND(100.0 * COUNT(*) FILTER (WHERE event_properties->>'tts_source' = 'direct_db')
    / NULLIF(COUNT(*), 0), 1) AS direct_db_rate_pct
FROM analytics_events
WHERE event_type = 'tts_request'
  AND created_at > NOW() - INTERVAL '7 days';
```

## ログの確認方法

Supabase CLI には `logs` コマンドがないため、**Dashboard** でログを確認します。

1. [Supabase Dashboard](https://supabase.com/dashboard) → プロジェクトを選択
2. **Edge Functions** → `tts_synthesize` をクリック
3. **Logs** タブ: 例外・`console.error` 等の詳細ログ（`db_query_ms`, `openai_ms`, `tts_session_id` でクライアントと相関可能）
4. **Invocations** タブ: リクエスト/レスポンス・ステータスコード・実行時間

## 500 / 502 エラー時の確認事項

| 確認項目 | 方法 |
|----------|------|
| `OPENAI_API_KEY` | Dashboard → Project Settings → Edge Functions → Secrets |
| `SUPABASE_URL` / `SUPABASE_SERVICE_ROLE_KEY` | デプロイ済み Functions には自動付与 |
| マイグレーション | `tts_assets` テーブル・`tts-audio` バケットが存在するか |
| Storage ポリシー | `tts-audio` に読み取りポリシーがあるか |

## prefill 実行のコツ

- 初回は `--limit 10` で少数テスト: `dart run scripts/prefill_tts_assets.dart --limit 10`
- エラーが出たら Dashboard の Logs で原因を確認

## prefill 同時実行ポリシー

- **同時実行**: 可能だが推奨しない（体感遅延・502 率上昇の恐れ）
- **ルール**:
  - 本番利用時間帯は `prefill --limit` で小分け実行
  - 大量 prefill はオフピークで実行
  - 連続 502 が増える場合は間隔を空ける（再試行バックオフ）
- **監視**: Edge Functions の Invocations/Logs で 5xx 率を確認。しきい値超過時は prefill を一時停止

## 1回目から爆速にする（ハッシュ一致・Public URL）

「2回目は早いが1回目が遅い」＝サーバー側キャッシュがヒットしていない可能性が高い。

### あきらめる前に：原因の切り分け

prefill を何度回してもキャッシュヒットが増えない場合、**診断スクリプト**で原因を特定する:

```bash
dart run scripts/verify_tts_cache_hash.dart
dart run scripts/verify_tts_cache_hash.dart --samples 10
# Edge ログの cache_key_preview のテキスト部分を指定して検証
dart run scripts/verify_tts_cache_hash.dart --text "hello. i would like a coffee, please."
```

- **「DB にこの cache_key が存在します」かつ「Edge 呼び出し結果: cache_hit = false」**  
  → **本番の Edge が古い**。`supabase functions deploy tts_synthesize` を実行して最新の index.ts をデプロイする。
- **「DB にこの cache_key がありません」**  
  → キー計算のずれか、その発話が prefill 対象外。Edge の Logs で `cache_key_hash` / `cache_key_preview` を確認し、DB の `tts_assets.cache_key` と比較する。

### 30秒会話・3分英会話・パターンスプリントで cache_hit=false になる場合

1. **Edge Logs** で cache_hit=false のログを1件選び、`cache_key_preview` のテキスト部分（最初の `|` より前）をコピー
2. **診断実行**:
   ```bash
   dart run scripts/verify_tts_cache_hash.dart --text "ここにコピーしたテキスト"
   ```
3. **結果の解釈**:
   - `DB=あり Edge_cache_hit=true` → そのテキストは正常。別のテキストでミスしている
   - `DB=なし Edge_cache_hit=false` → prefill 対象外 or キー不一致。conversation_utterances にそのテキストが存在するか SQL で確認
   - `DB=あり Edge_cache_hit=false` → Edge のデプロイが古い。`npx supabase functions deploy tts_synthesize --no-verify-jwt` を実行

### 実施手順

1. **マイグレーション実行**: `database_tts_audio_public_bucket.sql` で tts-audio を Public に変更
2. **Edge Function 再デプロイ**: `supabase functions deploy tts_synthesize`（**必須**。未デプロイだとずっとキャッシュミス）
3. **prefill 再実行**: テキスト正規化を Edge と一致させたため、全件再投入を推奨
   ```bash
   dart run scripts/prefill_tts_assets.dart
   ```
4. **ログ確認**: Edge の Logs で `cache_hit: true` が増えているか確認。`cache_hit: false` 時に `cache_key_hash`, `cache_key_preview` で DB 値と突き合わせ可能

## デプロイ前後チェック

| チェック | 方法 |
|----------|------|
| env | `.env` の `SUPABASE_URL`, `SUPABASE_ANON_KEY` がビルドに渡っているか（`build_for_deploy.ps1` 使用） |
| migration | `database_tts_assets_migration.sql`, `database_tts_audio_public_bucket.sql` が本番で適用済みか |
| プロジェクト一致 | prefill・verify・アプリが同じ Supabase プロジェクトを参照しているか。下記「接続先の確認」参照 |
| function version | `supabase functions deploy tts_synthesize` 直後に Invocations で `cache_hit` が期待どおりか |
| hash 一致 | `dart run scripts/verify_tts_cache_hash.dart` で DB と Edge のキー一致を確認 |

### 接続先の確認（prefill・アプリが同じ Supabase か）

1. **スクリプトで確認**:
   ```powershell
   .\scripts\verify_supabase_env.ps1
   ```
   → `.env` の `SUPABASE_URL` が表示される。`https://munemrzmgaitfeejrtns.supabase.co` なら OK。

2. **デプロイ時の確認**: `.\scripts\build_for_deploy.ps1` または `.\scripts\deploy_firebase.ps1` を実行すると、ビルド開始時に「Supabase URL: https://...」が表示される。上記と同じなら一致。

3. **ローカル実行**: `flutter run -d chrome` は `.env` を読むので、1 と同じプロジェクトになる。

## 再現テスト手順（Web シークレット）

1. スマホ Chrome シークレットモードでアプリを開く
2. 画面を一度もタップせずに再生ボタンを表示
3. 再生タップ → 無音になる想定
4. SnackBar「再生を開始するにはタップしてください」の [再生] をタップ → 再生成功を確認
