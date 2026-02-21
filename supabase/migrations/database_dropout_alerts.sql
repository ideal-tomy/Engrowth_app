-- 離脱予兆アラート（講師向け）
CREATE TABLE IF NOT EXISTS dropout_alerts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  consultant_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  alert_type TEXT CHECK (alert_type IN ('no_study', 'no_submission', 'streak_broken')),
  days_inactive INTEGER,
  last_activity_date DATE,
  acknowledged_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_dropout_alerts_consultant ON dropout_alerts(consultant_id);
CREATE INDEX IF NOT EXISTS idx_dropout_alerts_created ON dropout_alerts(created_at DESC);

ALTER TABLE dropout_alerts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Consultants can view and manage own alerts"
  ON dropout_alerts FOR ALL
  USING (auth.uid() = consultant_id);
