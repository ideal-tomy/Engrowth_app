-- user_stats テーブル作成（習慣化UX用）
-- Supabase DashboardのSQL Editorで実行してください

-- 既存テーブルに不足カラムがあれば追加（部分適用からの復旧用）
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_stats') THEN
    ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS last_study_date DATE;
    ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS daily_done_count INTEGER DEFAULT 0;
    ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS daily_goal_count INTEGER DEFAULT 3;
    ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS daily_reset_date DATE;
    ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS streak_count INTEGER DEFAULT 0;
    ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS timezone TEXT DEFAULT 'Asia/Tokyo';
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS user_stats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  
  -- ストリーク関連
  streak_count INTEGER DEFAULT 0,  -- 連続学習日数
  last_study_date DATE,  -- 最後に学習した日（ユーザーのローカル日付）
  
  -- 日次ミッション関連
  daily_goal_count INTEGER DEFAULT 3,  -- 1日の目標例文数
  daily_done_count INTEGER DEFAULT 0,  -- 今日完了した例文数
  daily_reset_date DATE,  -- 日次リセット日（ミッションリセット用）
  
  -- タイムゾーン
  timezone TEXT DEFAULT 'Asia/Tokyo',
  
  -- メタデータ
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- インデックスの作成
CREATE INDEX IF NOT EXISTS idx_user_stats_user_id ON user_stats(user_id);
CREATE INDEX IF NOT EXISTS idx_user_stats_last_study_date ON user_stats(last_study_date);

-- RLSポリシーの設定
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;

-- ユーザーは自分の統計のみ閲覧可能
DROP POLICY IF EXISTS "Users can view own stats" ON user_stats;
CREATE POLICY "Users can view own stats" 
  ON user_stats FOR SELECT 
  USING (auth.uid() = user_id);

-- ユーザーは自分の統計のみ更新可能
DROP POLICY IF EXISTS "Users can update own stats" ON user_stats;
CREATE POLICY "Users can update own stats" 
  ON user_stats FOR UPDATE 
  USING (auth.uid() = user_id);

-- ユーザーは自分の統計のみ挿入可能
DROP POLICY IF EXISTS "Users can insert own stats" ON user_stats;
CREATE POLICY "Users can insert own stats" 
  ON user_stats FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- updated_atを自動更新するトリガー
CREATE OR REPLACE FUNCTION update_user_stats_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_user_stats_updated_at ON user_stats;
CREATE TRIGGER trigger_update_user_stats_updated_at
  BEFORE UPDATE ON user_stats
  FOR EACH ROW
  EXECUTE FUNCTION update_user_stats_updated_at();

-- 完了メッセージ
DO $$
BEGIN
  RAISE NOTICE 'user_statsテーブルの作成が完了しました！';
END $$;
