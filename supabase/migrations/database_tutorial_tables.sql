-- チュートリアル専用テーブル（事前生成音声で低遅延体験）
-- 初回体験の「聞く→話す→返答」を意図バケットで制御

-- チュートリアル定義
CREATE TABLE IF NOT EXISTS tutorials (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description_ja TEXT,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ステップ定義（1ステップ = システム発話 → ユーザー発話 → 意図別返答）
CREATE TABLE IF NOT EXISTS tutorial_steps (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tutorial_id UUID NOT NULL REFERENCES tutorials(id) ON DELETE CASCADE,
  step_order INTEGER NOT NULL,
  prompt_text_en TEXT NOT NULL,
  prompt_text_ja TEXT,
  prompt_audio_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(tutorial_id, step_order)
);

-- 意図別返答（greeting / self_intro / unknown 等）
CREATE TABLE IF NOT EXISTS tutorial_step_responses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tutorial_step_id UUID NOT NULL REFERENCES tutorial_steps(id) ON DELETE CASCADE,
  intent_bucket TEXT NOT NULL,
  response_text_en TEXT NOT NULL,
  response_text_ja TEXT,
  response_audio_url TEXT,
  next_step_id UUID REFERENCES tutorial_steps(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(tutorial_step_id, intent_bucket)
);

CREATE INDEX IF NOT EXISTS idx_tutorial_steps_tutorial ON tutorial_steps(tutorial_id);
CREATE INDEX IF NOT EXISTS idx_tutorial_step_responses_step ON tutorial_step_responses(tutorial_step_id);

ALTER TABLE tutorials ENABLE ROW LEVEL SECURITY;
ALTER TABLE tutorial_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE tutorial_step_responses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Tutorials readable by everyone" ON tutorials;
CREATE POLICY "Tutorials readable by everyone" ON tutorials FOR SELECT USING (true);

DROP POLICY IF EXISTS "Tutorial steps readable by everyone" ON tutorial_steps;
CREATE POLICY "Tutorial steps readable by everyone" ON tutorial_steps FOR SELECT USING (true);

DROP POLICY IF EXISTS "Tutorial step responses readable by everyone" ON tutorial_step_responses;
CREATE POLICY "Tutorial step responses readable by everyone" ON tutorial_step_responses FOR SELECT USING (true);

-- updated_at 自動更新
CREATE OR REPLACE FUNCTION update_tutorials_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_tutorials_updated_at ON tutorials;
CREATE TRIGGER trigger_update_tutorials_updated_at
  BEFORE UPDATE ON tutorials
  FOR EACH ROW
  EXECUTE FUNCTION update_tutorials_updated_at();
