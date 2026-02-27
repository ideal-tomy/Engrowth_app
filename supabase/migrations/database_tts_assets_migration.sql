-- TTS 音声アセットのキャッシュ管理用テーブル・Storage バケット
-- tts_synthesize Edge Function が OpenAI 合成結果を Storage に保存し、メタをここに記録
-- キャッシュキー hash(text+language+voice+speed+model) で lookup

-- tts_assets メタテーブル
CREATE TABLE IF NOT EXISTS tts_assets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  cache_key TEXT NOT NULL UNIQUE,
  storage_path TEXT NOT NULL,
  model TEXT NOT NULL DEFAULT 'tts-1-hd',
  voice TEXT NOT NULL,
  language TEXT NOT NULL,
  speed DOUBLE PRECISION NOT NULL,
  duration_ms INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_used_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tts_assets_cache_key ON tts_assets(cache_key);
CREATE INDEX IF NOT EXISTS idx_tts_assets_last_used_at ON tts_assets(last_used_at DESC);

-- RLS: 読み取りは anon/authenticated、挿入・更新は service role のみ（Edge Function 経由で RLS 回避）
ALTER TABLE tts_assets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read tts_assets"
  ON tts_assets FOR SELECT
  USING (true);

-- Storage バケット tts-audio（Private）
INSERT INTO storage.buckets (id, name, public)
VALUES ('tts-audio', 'tts-audio', false)
ON CONFLICT (id) DO NOTHING;

-- tts-audio バケット: 署名付き URL で読み取り可能（path は hash で推測困難）
CREATE POLICY "Allow read tts-audio"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'tts-audio');
