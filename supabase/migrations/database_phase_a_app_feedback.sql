-- Phase A: app_feedback
-- ユーザー要望/レビュー（AI要約の入力）
CREATE TABLE IF NOT EXISTS app_feedback (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  author_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  author_role TEXT CHECK (author_role IN ('client', 'consultant')),
  category TEXT CHECK (category IN ('bug', 'ux', 'feature', 'other')),
  content TEXT NOT NULL,
  status TEXT DEFAULT 'new' CHECK (status IN ('new', 'triaged', 'planned', 'done')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_app_feedback_status ON app_feedback(status);
CREATE INDEX IF NOT EXISTS idx_app_feedback_created ON app_feedback(created_at DESC);

ALTER TABLE app_feedback ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated can insert app_feedback"
  ON app_feedback FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- 閲覧は管理者向け（暫定で authenticated 全員）
CREATE POLICY "Authenticated can view app_feedback"
  ON app_feedback FOR SELECT
  USING (auth.role() = 'authenticated');
