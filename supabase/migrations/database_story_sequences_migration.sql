-- 3分ストーリー機能用テーブル
-- 1ストーリー = 3〜5チャンク（会話）、各チャンク30〜45秒

-- ストーリーシーケンス（3分ストーリーのメタデータ）
CREATE TABLE IF NOT EXISTS story_sequences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  total_duration_minutes INTEGER DEFAULT 3,
  thumbnail_url TEXT,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 会話をストーリーに紐づけ
ALTER TABLE conversations
  ADD COLUMN IF NOT EXISTS story_sequence_id UUID REFERENCES story_sequences(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS story_order INTEGER;

-- ユーザーのストーリー進捗（再開用）
CREATE TABLE IF NOT EXISTS story_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  story_sequence_id UUID REFERENCES story_sequences(id) ON DELETE CASCADE,
  last_conversation_id UUID REFERENCES conversations(id) ON DELETE SET NULL,
  last_utterance_index INTEGER DEFAULT 0,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, story_sequence_id)
);

-- 会話の中断位置（ストーリー外も含む再開用）
CREATE TABLE IF NOT EXISTS conversation_resume (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  utterance_index INTEGER DEFAULT 0,
  last_resume_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, conversation_id)
);

CREATE INDEX IF NOT EXISTS idx_conversations_story_sequence ON conversations(story_sequence_id);
CREATE INDEX IF NOT EXISTS idx_story_progress_user ON story_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_conversation_resume_user ON conversation_resume(user_id);

ALTER TABLE story_sequences ENABLE ROW LEVEL SECURITY;
ALTER TABLE story_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_resume ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Story sequences viewable by everyone" ON story_sequences;
CREATE POLICY "Story sequences viewable by everyone" ON story_sequences FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can view own story progress" ON story_progress;
CREATE POLICY "Users can view own story progress" ON story_progress FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can insert own story progress" ON story_progress;
CREATE POLICY "Users can insert own story progress" ON story_progress FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can update own story progress" ON story_progress;
CREATE POLICY "Users can update own story progress" ON story_progress FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can view own conversation resume" ON conversation_resume;
CREATE POLICY "Users can view own conversation resume" ON conversation_resume FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can insert own conversation resume" ON conversation_resume;
CREATE POLICY "Users can insert own conversation resume" ON conversation_resume FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can update own conversation resume" ON conversation_resume;
CREATE POLICY "Users can update own conversation resume" ON conversation_resume FOR UPDATE USING (auth.uid() = user_id);
