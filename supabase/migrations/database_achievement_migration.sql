-- ゲーミフィケーション用テーブル作成
-- Supabase DashboardのSQL Editorで実行してください

-- バッジ/称号テーブル
CREATE TABLE IF NOT EXISTS achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  icon TEXT DEFAULT 'star',  -- アイコン名（Material Icons）
  condition_type TEXT NOT NULL,  -- 'streak', 'sentence_count', 'scenario_count', 'hint_free_count'
  condition_value INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ユーザー達成テーブル
CREATE TABLE IF NOT EXISTS user_achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  achievement_id UUID REFERENCES achievements(id) ON DELETE CASCADE,
  unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, achievement_id)
);

-- インデックスの作成
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_achievement_id ON user_achievements(achievement_id);

-- RLSポリシーの設定
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;

-- achievements: 全ユーザーが閲覧可能
DROP POLICY IF EXISTS "Achievements are viewable by everyone" ON achievements;
CREATE POLICY "Achievements are viewable by everyone" 
  ON achievements FOR SELECT 
  USING (true);

-- user_achievements: ユーザーは自分の達成のみ閲覧可能
DROP POLICY IF EXISTS "Users can view own achievements" ON user_achievements;
CREATE POLICY "Users can view own achievements" 
  ON user_achievements FOR SELECT 
  USING (auth.uid() = user_id);

-- user_achievements: ユーザーは自分の達成のみ挿入可能
DROP POLICY IF EXISTS "Users can insert own achievements" ON user_achievements;
CREATE POLICY "Users can insert own achievements" 
  ON user_achievements FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- 初期バッジデータの挿入
INSERT INTO achievements (title, description, icon, condition_type, condition_value) VALUES
  ('初めての学習', '最初の例文を学習しました', 'star', 'sentence_count', 1),
  ('継続の力', '7日連続で学習しました', 'local_fire_department', 'streak', 7),
  ('学習者', '10個の例文を学習しました', 'school', 'sentence_count', 10),
  ('上級者', '50個の例文を学習しました', 'emoji_events', 'sentence_count', 50),
  ('マスター', '100個の例文を学習しました', 'workspace_premium', 'sentence_count', 100),
  ('ストーリーテラー', '3つのシナリオを完了しました', 'auto_stories', 'scenario_count', 3),
  ('完璧主義者', 'ヒントなしで10回正解しました', 'verified', 'hint_free_count', 10)
ON CONFLICT DO NOTHING;

-- 完了メッセージ
DO $$
BEGIN
  RAISE NOTICE 'ゲーミフィケーション関連テーブルの作成が完了しました！';
END $$;
