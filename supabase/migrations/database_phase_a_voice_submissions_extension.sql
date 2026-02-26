-- Phase A: voice_submissions 拡張（session_uuid, submission_context）
-- user_sessions と紐づけ、提出時スナップショット保存用
ALTER TABLE voice_submissions
  ADD COLUMN IF NOT EXISTS session_uuid UUID REFERENCES user_sessions(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS submission_context JSONB DEFAULT '{}'::jsonb;

CREATE INDEX IF NOT EXISTS idx_voice_submissions_session_uuid
  ON voice_submissions(session_uuid) WHERE session_uuid IS NOT NULL;
