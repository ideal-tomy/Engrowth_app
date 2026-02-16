-- 会話学習イベントテーブル（管理者向け分析用）
-- listenCompleted, roleStarted, roleCompleted, autoAdvanceUsed, manualNextUsed

CREATE TABLE IF NOT EXISTS conversation_learning_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE NOT NULL,
  session_id TEXT,
  event_type TEXT NOT NULL CHECK (event_type IN (
    'listen_completed', 'role_started', 'role_completed',
    'auto_advance_used', 'manual_next_used'
  )),
  role TEXT,  -- 'A' or 'B' for role_started/role_completed
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_conversation_learning_events_user_id
  ON conversation_learning_events(user_id);
CREATE INDEX IF NOT EXISTS idx_conversation_learning_events_conversation_id
  ON conversation_learning_events(conversation_id);
CREATE INDEX IF NOT EXISTS idx_conversation_learning_events_created_at
  ON conversation_learning_events(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_conversation_learning_events_event_type
  ON conversation_learning_events(event_type);

ALTER TABLE conversation_learning_events ENABLE ROW LEVEL SECURITY;

-- ユーザーは自分のイベントのみ挿入
DROP POLICY IF EXISTS "Users can insert own learning events" ON conversation_learning_events;
CREATE POLICY "Users can insert own learning events"
  ON conversation_learning_events FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- コンサルタント・管理者が全ユーザーのイベントを閲覧可能（提出一覧と同様）
DROP POLICY IF EXISTS "Consultants can view all learning events" ON conversation_learning_events;
CREATE POLICY "Consultants can view all learning events"
  ON conversation_learning_events FOR SELECT
  USING (true);
