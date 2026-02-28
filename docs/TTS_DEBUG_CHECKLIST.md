# TTS Edge Function デバッグチェックリスト

## ログの確認方法

Supabase CLI には `logs` コマンドがないため、**Dashboard** でログを確認します。

1. [Supabase Dashboard](https://supabase.com/dashboard) → プロジェクトを選択
2. **Edge Functions** → `tts_synthesize` をクリック
3. **Logs** タブ: 例外・`console.error` 等の詳細ログ
4. **Invocations** タブ: リクエスト/レスポンス・ステータスコード

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
