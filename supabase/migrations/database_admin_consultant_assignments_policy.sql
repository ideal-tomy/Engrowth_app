-- 管理者が consultant_assignments / coach_missions を操作できるようにする
-- B13 権限付与・配信デモのため
-- 前提: consultant_assignments, coach_missions が作成済みであること
-- テーブルが存在しない場合はスキップ（エラーにしない）

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'consultant_assignments') THEN
    DROP POLICY IF EXISTS "Admins can manage consultant_assignments" ON consultant_assignments;
    CREATE POLICY "Admins can manage consultant_assignments"
      ON consultant_assignments FOR ALL
      USING ((auth.jwt()->>'app_role')::text = 'admin')
      WITH CHECK ((auth.jwt()->>'app_role')::text = 'admin');
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'coach_missions') THEN
    DROP POLICY IF EXISTS "Admins can view coach_missions" ON coach_missions;
    CREATE POLICY "Admins can view coach_missions"
      ON coach_missions FOR SELECT
      USING ((auth.jwt()->>'app_role')::text = 'admin');
  END IF;
END $$;
