# TTS Edge Function デバッグチェックリスト

## 原因カテゴリの切り分け（30分以内）

| カテゴリ | 症状 | 確認方法 |
|----------|------|----------|
| **DB** | direct_db 比率が低い、db_result=timeout/error が多い | analytics_events の `tts_request` で `tts_source`, `db_result`, `db_elapsed_ms` を確認 |
| **Edge** | 5秒超の遅延、edge 経路が多い | Supabase Invocations の実行時間、Edge Logs の `db_query_ms`, `openai_ms`, `cache_hit` |
| **WebPolicy** | シークレットで無音、not_allowed | `tts_web_play_error` の `error_type=not_allowed` |
| **競合** | flutter_tts と重なる、二重再生 | `tts_fallback` の `path_taken`, `tts_playback_session` の `flutter_fallback_count` |

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
```

- **「DB にこの cache_key が存在します」かつ「Edge 呼び出し結果: cache_hit = false」**  
  → **本番の Edge が古い**。`supabase functions deploy tts_synthesize` を実行して最新の index.ts をデプロイする。
- **「DB にこの cache_key がありません」**  
  → キー計算のずれか、その発話が prefill 対象外。Edge の Logs で `cache_key_hash` / `cache_key_preview` を確認し、DB の `tts_assets.cache_key` と比較する。

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
| function version | `supabase functions deploy tts_synthesize` 直後に Invocations で `cache_hit` が期待どおりか |
| hash 一致 | `dart run scripts/verify_tts_cache_hash.dart` で DB と Edge のキー一致を確認 |

## 再現テスト手順（Web シークレット）

1. スマホ Chrome シークレットモードでアプリを開く
2. 画面を一度もタップせずに再生ボタンを表示
3. 再生タップ → 無音になる想定
4. SnackBar「再生を開始するにはタップしてください」の [再生] をタップ → 再生成功を確認
