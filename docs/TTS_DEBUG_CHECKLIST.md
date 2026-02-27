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
