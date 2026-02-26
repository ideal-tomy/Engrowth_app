-- Phase B: RLS 厳格化
-- UI/機能検証完了後に適用すること
-- 事前に Supabase Dashboard で admin 用の JWT claim (app_role=admin) を設定すること

-- === 1. voice_submissions ===
-- 既存の緩いポリシーを削除して置換
DROP POLICY IF EXISTS "Consultants can view all submissions" ON voice_submissions;
DROP POLICY IF EXISTS "Consultants can update submissions for feedback" ON voice_submissions;

-- コンサル: 担当クライアントのみ閲覧・更新
CREATE POLICY "Consultants can view assigned client submissions"
  ON voice_submissions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM consultant_assignments ca
      WHERE ca.client_id = voice_submissions.user_id
      AND ca.consultant_id = auth.uid()
      AND ca.status = 'active'
    )
  );

CREATE POLICY "Consultants can update assigned client submissions"
  ON voice_submissions FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM consultant_assignments ca
      WHERE ca.client_id = voice_submissions.user_id
      AND ca.consultant_id = auth.uid()
      AND ca.status = 'active'
    )
  );

-- 管理者: 全件閲覧・更新（JWT app_role=admin で判定）
-- Supabase では auth.jwt()->>'app_role' でカスタムクレーム取得
-- 注意: app_role は Supabase Dashboard > Authentication > JWT Templates で設定
CREATE POLICY "Admins can view all voice_submissions"
  ON voice_submissions FOR SELECT
  USING (
    (auth.jwt()->>'app_role')::text = 'admin'
  );

CREATE POLICY "Admins can update all voice_submissions"
  ON voice_submissions FOR UPDATE
  USING (
    (auth.jwt()->>'app_role')::text = 'admin'
  );

-- === 2. voice_feedbacks ===
DROP POLICY IF EXISTS "Anyone can view feedbacks" ON voice_feedbacks;

-- 提出者本人・担当コンサル・管理者のみ
CREATE POLICY "Users can view own feedbacks"
  ON voice_feedbacks FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM voice_submissions vs
      WHERE vs.id = voice_feedbacks.voice_submission_id
      AND vs.user_id = auth.uid()
    )
  );

CREATE POLICY "Consultants can view assigned feedbacks"
  ON voice_feedbacks FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM voice_submissions vs
      JOIN consultant_assignments ca ON ca.client_id = vs.user_id AND ca.status = 'active'
      WHERE vs.id = voice_feedbacks.voice_submission_id
      AND ca.consultant_id = auth.uid()
    )
  );

CREATE POLICY "Admins can view all voice_feedbacks"
  ON voice_feedbacks FOR SELECT
  USING ((auth.jwt()->>'app_role')::text = 'admin');

-- === 3. user_sessions ===
-- 本人用ポリシーは Phase A のまま維持。担当コンサル・管理者用を追加
CREATE POLICY "Consultants can view assigned client sessions"
  ON user_sessions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM consultant_assignments ca
      WHERE ca.client_id = user_sessions.user_id
      AND ca.consultant_id = auth.uid()
      AND ca.status = 'active'
    )
  );

CREATE POLICY "Admins can view all user_sessions"
  ON user_sessions FOR SELECT
  USING ((auth.jwt()->>'app_role')::text = 'admin');

-- === 4. consultant_client_permissions ===
-- 管理者のみ挿入・更新
DROP POLICY IF EXISTS "Authenticated can view consultant_client_permissions" ON consultant_client_permissions;
DROP POLICY IF EXISTS "Authenticated can insert consultant_client_permissions" ON consultant_client_permissions;
DROP POLICY IF EXISTS "Authenticated can update consultant_client_permissions" ON consultant_client_permissions;

CREATE POLICY "Consultants can view own permissions"
  ON consultant_client_permissions FOR SELECT
  USING (consultant_id = auth.uid());

CREATE POLICY "Admins can manage consultant_client_permissions"
  ON consultant_client_permissions FOR ALL
  USING ((auth.jwt()->>'app_role')::text = 'admin');
