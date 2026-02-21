-- コンサルタントの日次総評
CREATE TABLE IF NOT EXISTS daily_summaries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  consultant_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  summary_date DATE NOT NULL,
  content TEXT NOT NULL,
  stats JSONB,
  posted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_id, summary_date)
);

CREATE INDEX IF NOT EXISTS idx_daily_summaries_client ON daily_summaries(client_id);
CREATE INDEX IF NOT EXISTS idx_daily_summaries_date ON daily_summaries(summary_date);

ALTER TABLE daily_summaries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Clients can view own summaries"
  ON daily_summaries FOR SELECT
  USING (auth.uid() = client_id);

CREATE POLICY "Consultants can manage summaries for assigned clients"
  ON daily_summaries FOR ALL
  USING (
    consultant_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM consultant_assignments ca
      WHERE ca.client_id = daily_summaries.client_id
      AND ca.consultant_id = auth.uid()
      AND ca.status = 'active'
    )
  );
