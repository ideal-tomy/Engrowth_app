-- Phase A: user_sessions テーブル（UI検証用）
-- 学習セッション単位の記録。提出と紐づけ可能にする
CREATE TABLE IF NOT EXISTS user_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  track TEXT CHECK (track IN ('scenario', 'story', 'sentence', 'conversation')),
  content_id UUID,
  session_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  ended_at TIMESTAMPTZ,
  duration_sec INT DEFAULT 0,
  attempt_count INT DEFAULT 0,
  retry_count INT DEFAULT 0,
  device_os TEXT,
  device_model TEXT,
  device_type TEXT CHECK (device_type IN ('smartphone', 'tablet', 'pc', 'other')),
  app_version TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_timestamp ON user_sessions(session_timestamp DESC);

-- Phase A: 暫定ポリシー（匿名含む authenticated で本人のみ参照）
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own sessions"
  ON user_sessions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sessions"
  ON user_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);
