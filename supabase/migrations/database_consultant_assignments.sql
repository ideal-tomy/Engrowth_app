-- コンサルタントとクライアントの担当割当
CREATE TABLE IF NOT EXISTS consultant_assignments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  consultant_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  client_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'paused')),
  notes TEXT,
  UNIQUE(consultant_id, client_id)
);

CREATE INDEX IF NOT EXISTS idx_consultant_assignments_consultant ON consultant_assignments(consultant_id);
CREATE INDEX IF NOT EXISTS idx_consultant_assignments_client ON consultant_assignments(client_id);

ALTER TABLE consultant_assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Consultants can manage own assignments"
  ON consultant_assignments FOR ALL
  USING (auth.uid() = consultant_id);

CREATE POLICY "Clients can view own assignments"
  ON consultant_assignments FOR SELECT
  USING (auth.uid() = client_id);
