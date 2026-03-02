-- B15: クライアント→コンサルタントのアプリ内クイック報告
-- シンプルな client_reports テーブルで報告を保存

CREATE TABLE IF NOT EXISTS client_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  consultant_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  report_type TEXT NOT NULL CHECK (report_type IN ('today_submitted', 'consultation', 'question', 'other')),
  message TEXT NOT NULL,
  related_submission_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_client_reports_consultant ON client_reports(consultant_id);
CREATE INDEX IF NOT EXISTS idx_client_reports_client ON client_reports(client_id);

ALTER TABLE client_reports ENABLE ROW LEVEL SECURITY;

-- クライアントは自分の報告のみ INSERT 可能（担当コンサルへのみ）
DROP POLICY IF EXISTS "Clients can insert reports to assigned consultant" ON client_reports;
CREATE POLICY "Clients can insert reports to assigned consultant"
  ON client_reports FOR INSERT
  WITH CHECK (
    auth.uid() = client_id
    AND consultant_id IN (
      SELECT consultant_id FROM consultant_assignments
      WHERE client_id = auth.uid() AND status = 'active'
    )
  );

-- コンサルタントは担当クライアントの報告のみ SELECT 可能
DROP POLICY IF EXISTS "Consultants can view assigned client reports" ON client_reports;
CREATE POLICY "Consultants can view assigned client reports"
  ON client_reports FOR SELECT
  USING (
    consultant_id = auth.uid()
    AND client_id IN (
      SELECT client_id FROM consultant_assignments
      WHERE consultant_id = auth.uid() AND status = 'active'
    )
  );
