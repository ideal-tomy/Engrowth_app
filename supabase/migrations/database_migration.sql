-- データベーススキーマ拡張
-- Supabase Dashboard → SQL Editor で実行してください

-- uuid-ossp拡張機能を有効化（既に有効な場合はスキップ）
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. learning_logs テーブルの作成
-- ============================================
CREATE TABLE IF NOT EXISTS learning_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  sentence_id UUID REFERENCES sentences(id) ON DELETE CASCADE,
  
  -- 学習セッション情報
  session_id UUID,
  session_start_time TIMESTAMP WITH TIME ZONE,
  
  -- ヒント使用情報
  hint_phase TEXT,  -- 'none', 'initial', 'extended', 'keywords'
  thinking_time_seconds INTEGER,
  used_hint BOOLEAN DEFAULT FALSE,
  
  -- 学習結果
  mastered BOOLEAN DEFAULT FALSE,
  answer_shown BOOLEAN DEFAULT FALSE,
  
  -- メタデータ
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- インデックスの作成
CREATE INDEX IF NOT EXISTS idx_learning_logs_user_id ON learning_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_learning_logs_sentence_id ON learning_logs(sentence_id);
CREATE INDEX IF NOT EXISTS idx_learning_logs_session_id ON learning_logs(session_id);
CREATE INDEX IF NOT EXISTS idx_learning_logs_created_at ON learning_logs(created_at);

-- ============================================
-- 2. hint_settings テーブルの作成
-- ============================================
CREATE TABLE IF NOT EXISTS hint_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  
  -- ヒントタイミング設定
  initial_hint_delay_seconds INTEGER DEFAULT 2,
  extended_hint_delay_seconds INTEGER DEFAULT 6,
  keywords_hint_delay_seconds INTEGER DEFAULT 10,
  
  -- ヒント表示設定
  hint_opacity DOUBLE PRECISION DEFAULT 0.6,
  hint_phases_enabled TEXT[] DEFAULT ARRAY['initial', 'extended', 'keywords'],
  
  -- フィードバック設定
  haptic_feedback_enabled BOOLEAN DEFAULT TRUE,
  visual_feedback_enabled BOOLEAN DEFAULT TRUE,
  
  -- メタデータ
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 3. user_progress テーブルの拡張
-- ============================================
ALTER TABLE user_progress 
  ADD COLUMN IF NOT EXISTS hint_usage_count INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS used_hint_to_master BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS average_thinking_time_seconds INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS last_hint_phase TEXT;

-- インデックスの追加
CREATE INDEX IF NOT EXISTS idx_user_progress_hint_usage 
  ON user_progress(user_id, hint_usage_count);

-- 既存データのデフォルト値設定
UPDATE user_progress 
SET 
  hint_usage_count = COALESCE(hint_usage_count, 0),
  used_hint_to_master = COALESCE(used_hint_to_master, FALSE),
  average_thinking_time_seconds = COALESCE(average_thinking_time_seconds, 0)
WHERE hint_usage_count IS NULL 
   OR used_hint_to_master IS NULL 
   OR average_thinking_time_seconds IS NULL;

-- ============================================
-- 4. RLSポリシーの設定
-- ============================================

-- learning_logs テーブル
ALTER TABLE learning_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own learning logs" ON learning_logs;
CREATE POLICY "Users can view own learning logs" 
  ON learning_logs FOR SELECT 
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own learning logs" ON learning_logs;
CREATE POLICY "Users can insert own learning logs" 
  ON learning_logs FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own learning logs" ON learning_logs;
CREATE POLICY "Users can update own learning logs" 
  ON learning_logs FOR UPDATE 
  USING (auth.uid() = user_id);

-- hint_settings テーブル
ALTER TABLE hint_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own hint settings" ON hint_settings;
CREATE POLICY "Users can view own hint settings" 
  ON hint_settings FOR SELECT 
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own hint settings" ON hint_settings;
CREATE POLICY "Users can insert own hint settings" 
  ON hint_settings FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own hint settings" ON hint_settings;
CREATE POLICY "Users can update own hint settings" 
  ON hint_settings FOR UPDATE 
  USING (auth.uid() = user_id);

-- ============================================
-- 5. ビュー（統計用）
-- ============================================
CREATE OR REPLACE VIEW hint_usage_stats AS
SELECT 
  user_id,
  sentence_id,
  COUNT(*) as total_attempts,
  COUNT(*) FILTER (WHERE used_hint = TRUE) as hint_used_count,
  COUNT(*) FILTER (WHERE hint_phase = 'initial') as initial_hint_count,
  COUNT(*) FILTER (WHERE hint_phase = 'extended') as extended_hint_count,
  COUNT(*) FILTER (WHERE hint_phase = 'keywords') as keywords_hint_count,
  AVG(thinking_time_seconds) as avg_thinking_time,
  MAX(created_at) as last_studied_at
FROM learning_logs
GROUP BY user_id, sentence_id;

-- ============================================
-- 6. 関数（統計計算用）
-- ============================================
CREATE OR REPLACE FUNCTION get_user_hint_statistics(p_user_id UUID)
RETURNS TABLE (
  total_sentences BIGINT,
  sentences_with_hints BIGINT,
  hint_usage_rate DOUBLE PRECISION,
  avg_thinking_time DOUBLE PRECISION,
  most_used_hint_phase TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(DISTINCT sentence_id) as total_sentences,
    COUNT(DISTINCT sentence_id) FILTER (WHERE used_hint = TRUE) as sentences_with_hints,
    CASE 
      WHEN COUNT(*) > 0 THEN 
        (COUNT(*) FILTER (WHERE used_hint = TRUE)::DOUBLE PRECISION / COUNT(*)::DOUBLE PRECISION) * 100
      ELSE 0
    END as hint_usage_rate,
    AVG(thinking_time_seconds)::DOUBLE PRECISION as avg_thinking_time,
    MODE() WITHIN GROUP (ORDER BY hint_phase) as most_used_hint_phase
  FROM learning_logs
  WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 7. トリガー関数
-- ============================================

-- updated_at自動更新
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_hint_settings_updated_at ON hint_settings;
CREATE TRIGGER update_hint_settings_updated_at
  BEFORE UPDATE ON hint_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- user_progress自動更新
CREATE OR REPLACE FUNCTION update_user_progress_from_log()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_progress (
    user_id,
    sentence_id,
    hint_usage_count,
    used_hint_to_master,
    average_thinking_time_seconds,
    last_hint_phase,
    last_studied_at,
    is_mastered
  )
  VALUES (
    NEW.user_id,
    NEW.sentence_id,
    1,
    NEW.used_hint AND NEW.mastered,
    NEW.thinking_time_seconds,
    NEW.hint_phase,
    NEW.created_at,
    NEW.mastered
  )
  ON CONFLICT (user_id, sentence_id)
  DO UPDATE SET
    hint_usage_count = user_progress.hint_usage_count + 1,
    used_hint_to_master = CASE 
      WHEN NEW.used_hint AND NEW.mastered THEN TRUE 
      ELSE user_progress.used_hint_to_master 
    END,
    average_thinking_time_seconds = (
      (user_progress.average_thinking_time_seconds * (user_progress.hint_usage_count - 1) + NEW.thinking_time_seconds) 
      / (user_progress.hint_usage_count + 1)
    ),
    last_hint_phase = NEW.hint_phase,
    last_studied_at = NEW.created_at,
    is_mastered = NEW.mastered OR user_progress.is_mastered;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_progress_on_learning_log ON learning_logs;
CREATE TRIGGER update_progress_on_learning_log
  AFTER INSERT ON learning_logs
  FOR EACH ROW
  EXECUTE FUNCTION update_user_progress_from_log();

-- ============================================
-- 完了メッセージ
-- ============================================
DO $$
BEGIN
  RAISE NOTICE 'データベーススキーマ拡張が完了しました！';
END $$;
