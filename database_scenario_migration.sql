-- シナリオ連鎖学習用テーブル作成
-- Supabase DashboardのSQL Editorで実行してください

-- シナリオテーブル
CREATE TABLE IF NOT EXISTS scenarios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  thumbnail_url TEXT,
  difficulty TEXT DEFAULT 'medium',  -- 'easy', 'medium', 'hard'
  estimated_minutes INTEGER DEFAULT 10,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- シナリオステップテーブル
CREATE TABLE IF NOT EXISTS scenario_steps (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  scenario_id UUID REFERENCES scenarios(id) ON DELETE CASCADE,
  sentence_id UUID REFERENCES sentences(id) ON DELETE CASCADE,
  order_index INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(scenario_id, order_index)
);

-- ユーザーシナリオ進捗テーブル
CREATE TABLE IF NOT EXISTS user_scenario_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  scenario_id UUID REFERENCES scenarios(id) ON DELETE CASCADE,
  last_step_index INTEGER DEFAULT 0,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, scenario_id)
);

-- インデックスの作成
CREATE INDEX IF NOT EXISTS idx_scenario_steps_scenario_id ON scenario_steps(scenario_id);
CREATE INDEX IF NOT EXISTS idx_scenario_steps_order_index ON scenario_steps(scenario_id, order_index);
CREATE INDEX IF NOT EXISTS idx_user_scenario_progress_user_id ON user_scenario_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_scenario_progress_scenario_id ON user_scenario_progress(scenario_id);

-- RLSポリシーの設定
ALTER TABLE scenarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE scenario_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_scenario_progress ENABLE ROW LEVEL SECURITY;

-- scenarios: 全ユーザーが閲覧可能
DROP POLICY IF EXISTS "Scenarios are viewable by everyone" ON scenarios;
CREATE POLICY "Scenarios are viewable by everyone" 
  ON scenarios FOR SELECT 
  USING (true);

-- scenario_steps: 全ユーザーが閲覧可能
DROP POLICY IF EXISTS "Scenario steps are viewable by everyone" ON scenario_steps;
CREATE POLICY "Scenario steps are viewable by everyone" 
  ON scenario_steps FOR SELECT 
  USING (true);

-- user_scenario_progress: ユーザーは自分の進捗のみ閲覧・更新可能
DROP POLICY IF EXISTS "Users can view own scenario progress" ON user_scenario_progress;
CREATE POLICY "Users can view own scenario progress" 
  ON user_scenario_progress FOR SELECT 
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own scenario progress" ON user_scenario_progress;
CREATE POLICY "Users can update own scenario progress" 
  ON user_scenario_progress FOR UPDATE 
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own scenario progress" ON user_scenario_progress;
CREATE POLICY "Users can insert own scenario progress" 
  ON user_scenario_progress FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- updated_atを自動更新するトリガー
CREATE OR REPLACE FUNCTION update_scenarios_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_scenarios_updated_at ON scenarios;
CREATE TRIGGER trigger_update_scenarios_updated_at
  BEFORE UPDATE ON scenarios
  FOR EACH ROW
  EXECUTE FUNCTION update_scenarios_updated_at();

DROP TRIGGER IF EXISTS trigger_update_user_scenario_progress_updated_at ON user_scenario_progress;
CREATE TRIGGER trigger_update_user_scenario_progress_updated_at
  BEFORE UPDATE ON user_scenario_progress
  FOR EACH ROW
  EXECUTE FUNCTION update_scenarios_updated_at();

-- 完了メッセージ
DO $$
BEGIN
  RAISE NOTICE 'シナリオ関連テーブルの作成が完了しました！';
END $$;
