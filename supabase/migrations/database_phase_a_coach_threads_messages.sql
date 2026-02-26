-- Phase A: coach_threads / coach_messages
-- クライアント-コンサルタント間の簡易コミュニケーション
CREATE TABLE IF NOT EXISTS coach_threads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  consultant_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_id, consultant_id)
);

CREATE TABLE IF NOT EXISTS coach_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  thread_id UUID REFERENCES coach_threads(id) ON DELETE CASCADE NOT NULL,
  sender_role TEXT NOT NULL CHECK (sender_role IN ('client', 'consultant')),
  content TEXT NOT NULL,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_coach_threads_client ON coach_threads(client_id);
CREATE INDEX IF NOT EXISTS idx_coach_threads_consultant ON coach_threads(consultant_id);
CREATE INDEX IF NOT EXISTS idx_coach_messages_thread ON coach_messages(thread_id);

ALTER TABLE coach_threads ENABLE ROW LEVEL SECURITY;
ALTER TABLE coach_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own threads"
  ON coach_threads FOR SELECT
  USING (auth.uid() = client_id OR auth.uid() = consultant_id);

CREATE POLICY "Authenticated can insert threads"
  ON coach_threads FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can view messages in own threads"
  ON coach_messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM coach_threads ct
      WHERE ct.id = thread_id
      AND (ct.client_id = auth.uid() OR ct.consultant_id = auth.uid())
    )
  );

CREATE POLICY "Authenticated can insert messages"
  ON coach_messages FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');
