-- コンサルタント用クイック返信テンプレート
CREATE TABLE IF NOT EXISTS feedback_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  consultant_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT,
  usage_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_feedback_templates_consultant ON feedback_templates(consultant_id);

ALTER TABLE feedback_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Consultants can manage own templates"
  ON feedback_templates FOR ALL
  USING (auth.uid() = consultant_id OR consultant_id IS NULL);
