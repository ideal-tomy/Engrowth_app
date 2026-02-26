-- Phase A: consultant_client_permissions
-- 期間外閲覧を管理者が制御
CREATE TABLE IF NOT EXISTS consultant_client_permissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  consultant_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  client_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  can_view_historical BOOLEAN DEFAULT FALSE,
  valid_from TIMESTAMPTZ,
  valid_to TIMESTAMPTZ,
  granted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ccp_consultant ON consultant_client_permissions(consultant_id);
CREATE INDEX IF NOT EXISTS idx_ccp_client ON consultant_client_permissions(client_id);

ALTER TABLE consultant_client_permissions ENABLE ROW LEVEL SECURITY;

-- Phase A: 暫定ポリシー（authenticated で全件参照・管理者のみ挿入・更新）
CREATE POLICY "Authenticated can view consultant_client_permissions"
  ON consultant_client_permissions FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated can insert consultant_client_permissions"
  ON consultant_client_permissions FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated can update consultant_client_permissions"
  ON consultant_client_permissions FOR UPDATE
  USING (auth.role() = 'authenticated');
