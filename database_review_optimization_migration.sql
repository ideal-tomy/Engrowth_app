-- user_progress テーブル拡張（復習最適化用）
-- Supabase DashboardのSQL Editorで実行してください

-- 復習用フィールドを追加
ALTER TABLE user_progress 
  ADD COLUMN IF NOT EXISTS last_review_at TIMESTAMP WITH TIME ZONE,
  ADD COLUMN IF NOT EXISTS next_review_at TIMESTAMP WITH TIME ZONE,
  ADD COLUMN IF NOT EXISTS stability DOUBLE PRECISION DEFAULT 1.0,  -- 記憶安定度
  ADD COLUMN IF NOT EXISTS difficulty DOUBLE PRECISION DEFAULT 0.3,  -- 難易度
  ADD COLUMN IF NOT EXISTS review_count INTEGER DEFAULT 0;  -- 復習回数

-- インデックスの追加（復習優先度計算用）
CREATE INDEX IF NOT EXISTS idx_user_progress_next_review_at 
  ON user_progress(user_id, next_review_at) 
  WHERE next_review_at IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_user_progress_review_priority 
  ON user_progress(user_id, next_review_at, hint_usage_count, used_hint_to_master);

-- 完了メッセージ
DO $$
BEGIN
  RAISE NOTICE 'user_progressテーブルの復習最適化拡張が完了しました！';
END $$;
