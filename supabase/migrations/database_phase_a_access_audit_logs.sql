-- Phase A: access_audit_logs
-- 誰が・いつ・誰のデータを見たか（期間外閲覧時など）
CREATE TABLE IF NOT EXISTS access_audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  viewer_id UUID REFERENCES auth.users(id) ON DELETE SET NULL NOT NULL,
  target_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL NOT NULL,
  resource_type TEXT,
  resource_id UUID,
  accessed_at TIMESTAMPTZ DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_access_audit_viewer ON access_audit_logs(viewer_id);
CREATE INDEX IF NOT EXISTS idx_access_audit_target ON access_audit_logs(target_user_id);
CREATE INDEX IF NOT EXISTS idx_access_audit_accessed ON access_audit_logs(accessed_at DESC);

ALTER TABLE access_audit_logs ENABLE ROW LEVEL SECURITY;

-- 挿入は全員可（クライアントからもログ記録）、閲覧は管理者向け（暫定で authenticated）
CREATE POLICY "Authenticated can insert access_audit_logs"
  ON access_audit_logs FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated can view access_audit_logs"
  ON access_audit_logs FOR SELECT
  USING (auth.role() = 'authenticated');
