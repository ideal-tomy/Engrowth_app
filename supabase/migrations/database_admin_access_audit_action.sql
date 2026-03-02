-- B14: access_audit_logs に action_type を追加（フィルタ用）
-- 前提: database_phase_a_access_audit_logs.sql で access_audit_logs が作成済みであること
-- access_audit_logs が存在しない場合はスキップ（エラーにしない）

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'access_audit_logs') THEN
    ALTER TABLE access_audit_logs ADD COLUMN IF NOT EXISTS action_type TEXT;
    CREATE INDEX IF NOT EXISTS idx_access_audit_action_type ON access_audit_logs(action_type);
  END IF;
END $$;
