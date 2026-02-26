-- Phase A: daily_ai_insights
-- AI日次要約の承認フロー用
CREATE TABLE IF NOT EXISTS daily_ai_insights (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  summary_date DATE NOT NULL,
  highlights JSONB,
  risks JSONB,
  top_requests JSONB,
  proposed_actions JSONB,
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'approved', 'rejected')),
  rejection_reason TEXT,
  generated_by_model TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_ai_insights_date ON daily_ai_insights(summary_date);
CREATE INDEX IF NOT EXISTS idx_daily_ai_insights_status ON daily_ai_insights(status);

ALTER TABLE daily_ai_insights ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated can view daily_ai_insights"
  ON daily_ai_insights FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated can manage daily_ai_insights"
  ON daily_ai_insights FOR ALL
  USING (auth.role() = 'authenticated');
