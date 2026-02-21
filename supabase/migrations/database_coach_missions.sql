-- コンサルタントが配信する「今日のミッション」
CREATE TABLE IF NOT EXISTS coach_missions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  consultant_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  mission_text TEXT NOT NULL,
  action_route TEXT,
  mission_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_id, mission_date)
);

CREATE INDEX IF NOT EXISTS idx_coach_missions_client ON coach_missions(client_id);
CREATE INDEX IF NOT EXISTS idx_coach_missions_date ON coach_missions(mission_date);

ALTER TABLE coach_missions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Clients can view own missions"
  ON coach_missions FOR SELECT
  USING (auth.uid() = client_id);

CREATE POLICY "Consultants can manage missions for assigned clients"
  ON coach_missions FOR ALL
  USING (
    consultant_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM consultant_assignments ca
      WHERE ca.client_id = coach_missions.client_id
      AND ca.consultant_id = auth.uid()
      AND ca.status = 'active'
    )
  );
