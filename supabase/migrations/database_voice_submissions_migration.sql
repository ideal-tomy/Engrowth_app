-- 音声提出・コンサルタントレビュー機能用テーブル
-- Phase 1: 録音のクラウド保存とステータス管理
--
-- 事前に Supabase Dashboard > Storage でバケット作成が必要です:
-- バケット名: voice-recordings (Private)
-- ポリシー: 認証ユーザーが自分のフォルダにアップロード可能

-- 音声提出テーブル
CREATE TABLE IF NOT EXISTS voice_submissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  -- 会話学習の場合
  conversation_id UUID REFERENCES conversations(id) ON DELETE SET NULL,
  utterance_id UUID REFERENCES conversation_utterances(id) ON DELETE SET NULL,
  -- 例文学習の場合
  sentence_id UUID REFERENCES sentences(id) ON DELETE SET NULL,
  audio_url TEXT NOT NULL,
  session_id TEXT,
  submission_type TEXT DEFAULT 'practice' CHECK (submission_type IN ('practice', 'submitted')),
  review_status TEXT DEFAULT 'pending' CHECK (review_status IN ('pending', 'reviewed')),
  consultant_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- コンサルタントのフィードバックテーブル
CREATE TABLE IF NOT EXISTS voice_feedbacks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  voice_submission_id UUID REFERENCES voice_submissions(id) ON DELETE CASCADE NOT NULL,
  client_message TEXT NOT NULL,
  internal_note TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- インデックス
CREATE INDEX IF NOT EXISTS idx_voice_submissions_user_id ON voice_submissions(user_id);
CREATE INDEX IF NOT EXISTS idx_voice_submissions_submission_type ON voice_submissions(submission_type);
CREATE INDEX IF NOT EXISTS idx_voice_submissions_session_id ON voice_submissions(session_id);
CREATE INDEX IF NOT EXISTS idx_voice_submissions_created_at ON voice_submissions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_voice_feedbacks_submission_id ON voice_feedbacks(voice_submission_id);

-- RLS
ALTER TABLE voice_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE voice_feedbacks ENABLE ROW LEVEL SECURITY;

-- voice_submissions: ユーザーは自分の提出のみ閲覧・挿入・更新
CREATE POLICY "Users can view own voice submissions"
  ON voice_submissions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own voice submissions"
  ON voice_submissions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own voice submissions"
  ON voice_submissions FOR UPDATE
  USING (auth.uid() = user_id);

-- コンサルタント用: 全提出を閲覧・フィードバック用に更新可能（後でロール制限に変更可）
CREATE POLICY "Consultants can view all submissions"
  ON voice_submissions FOR SELECT
  USING (true);

CREATE POLICY "Consultants can update submissions for feedback"
  ON voice_submissions FOR UPDATE
  USING (true);

-- voice_feedbacks: フィードバックはコンサルタントが挿入、ユーザーは閲覧のみ
CREATE POLICY "Anyone can view feedbacks"
  ON voice_feedbacks FOR SELECT
  USING (true);

CREATE POLICY "Authenticated can insert feedbacks"
  ON voice_feedbacks FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');
