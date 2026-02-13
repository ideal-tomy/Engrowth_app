-- 音声メイン会話習得機能用テーブル作成
-- Supabase DashboardのSQL Editorで実行してください

-- 会話テーブル
CREATE TABLE IF NOT EXISTS conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  scenario_id UUID REFERENCES scenarios(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  situation_type TEXT,  -- 'student', 'business'
  week_range TEXT,  -- '1-2', '3-4', etc.
  theme TEXT,  -- '挨拶', '自己紹介', etc.
  thumbnail_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 会話発話テーブル
CREATE TABLE IF NOT EXISTS conversation_utterances (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  speaker_role TEXT NOT NULL,  -- 'A', 'B', 'C', 'system'
  utterance_order INTEGER NOT NULL,
  english_text TEXT NOT NULL,
  japanese_text TEXT NOT NULL,
  audio_url TEXT,  -- 音声ファイルURL（オプション）
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(conversation_id, utterance_order)
);

-- 音声再生履歴テーブル
CREATE TABLE IF NOT EXISTS voice_playback_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  utterance_id UUID REFERENCES conversation_utterances(id) ON DELETE CASCADE,
  played_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  playback_type TEXT DEFAULT 'tts',  -- 'tts', 'user_recording', 'system_audio'
  session_id TEXT,  -- 学習セッションID
  UNIQUE(user_id, conversation_id, utterance_id, session_id)
);

-- 既存テーブルの拡張
-- sentencesテーブルに会話対応フィールドを追加（後方互換性のためオプショナル）
ALTER TABLE sentences 
  ADD COLUMN IF NOT EXISTS conversation_id UUID REFERENCES conversations(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS utterance_order INTEGER;

-- scenariosテーブルに会話モードフィールドを追加
ALTER TABLE scenarios
  ADD COLUMN IF NOT EXISTS conversation_mode TEXT DEFAULT 'sentence';  -- 'sentence' or 'conversation'

-- インデックスの作成
CREATE INDEX IF NOT EXISTS idx_conversations_scenario_id ON conversations(scenario_id);
CREATE INDEX IF NOT EXISTS idx_conversations_situation_type ON conversations(situation_type);
CREATE INDEX IF NOT EXISTS idx_conversation_utterances_conversation_id ON conversation_utterances(conversation_id);
CREATE INDEX IF NOT EXISTS idx_conversation_utterances_order ON conversation_utterances(conversation_id, utterance_order);
CREATE INDEX IF NOT EXISTS idx_voice_playback_history_user_id ON voice_playback_history(user_id);
CREATE INDEX IF NOT EXISTS idx_voice_playback_history_conversation_id ON voice_playback_history(conversation_id);
CREATE INDEX IF NOT EXISTS idx_voice_playback_history_session_id ON voice_playback_history(session_id);

-- RLSポリシーの設定
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_utterances ENABLE ROW LEVEL SECURITY;
ALTER TABLE voice_playback_history ENABLE ROW LEVEL SECURITY;

-- conversations: 全ユーザーが閲覧可能
DROP POLICY IF EXISTS "Conversations are viewable by everyone" ON conversations;
CREATE POLICY "Conversations are viewable by everyone" 
  ON conversations FOR SELECT 
  USING (true);

-- conversation_utterances: 全ユーザーが閲覧可能
DROP POLICY IF EXISTS "Conversation utterances are viewable by everyone" ON conversation_utterances;
CREATE POLICY "Conversation utterances are viewable by everyone" 
  ON conversation_utterances FOR SELECT 
  USING (true);

-- voice_playback_history: ユーザーは自分の履歴のみ閲覧・挿入可能
DROP POLICY IF EXISTS "Users can view own playback history" ON voice_playback_history;
CREATE POLICY "Users can view own playback history" 
  ON voice_playback_history FOR SELECT 
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own playback history" ON voice_playback_history;
CREATE POLICY "Users can insert own playback history" 
  ON voice_playback_history FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- updated_atを自動更新するトリガー
CREATE OR REPLACE FUNCTION update_conversations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_conversations_updated_at ON conversations;
CREATE TRIGGER trigger_update_conversations_updated_at
  BEFORE UPDATE ON conversations
  FOR EACH ROW
  EXECUTE FUNCTION update_conversations_updated_at();

-- 完了メッセージ
DO $$
BEGIN
  RAISE NOTICE '会話機能用テーブルの作成が完了しました！';
END $$;
