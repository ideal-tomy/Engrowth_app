-- Phase C: RLS 追加厳格化
-- analytics_events, conversation_learning_events, voice_feedbacks の緩いポリシーを置換
--
-- 各テーブルが存在する場合のみポリシーを適用（未作成テーブルはスキップ）
-- 前提: consultant_assignments テーブル（voice_feedbacks / conversation_learning_events の consultant ポリシーで参照）

-- === 0. voice_feedbacks INSERT ===
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'voice_feedbacks') THEN
    DROP POLICY IF EXISTS "Authenticated can insert feedbacks" ON voice_feedbacks;
    CREATE POLICY "Consultants can insert feedbacks for assigned"
      ON voice_feedbacks FOR INSERT
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM voice_submissions vs
          JOIN consultant_assignments ca ON ca.client_id = vs.user_id AND ca.status = 'active'
          WHERE vs.id = voice_feedbacks.voice_submission_id
          AND ca.consultant_id = auth.uid()
        )
        OR (auth.jwt()->>'app_role')::text = 'admin'
      );
  END IF;
END $$;

-- === 1. analytics_events ===
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'analytics_events') THEN
    DROP POLICY IF EXISTS "Users can insert analytics events" ON analytics_events;
    CREATE POLICY "Users can insert analytics events"
      ON analytics_events FOR INSERT
      WITH CHECK ((user_id IS NULL) OR (auth.uid() = user_id));
  END IF;
END $$;

-- === 2. conversation_learning_events ===
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'conversation_learning_events') THEN
    DROP POLICY IF EXISTS "Consultants can view all learning events" ON conversation_learning_events;
    DROP POLICY IF EXISTS "Users can view own learning events" ON conversation_learning_events;
    DROP POLICY IF EXISTS "Consultants can view assigned client learning events" ON conversation_learning_events;
    DROP POLICY IF EXISTS "Admins can view all learning events" ON conversation_learning_events;
    CREATE POLICY "Users can view own learning events"
      ON conversation_learning_events FOR SELECT
      USING (auth.uid() = user_id);
    CREATE POLICY "Consultants can view assigned client learning events"
      ON conversation_learning_events FOR SELECT
      USING (
        EXISTS (
          SELECT 1 FROM consultant_assignments ca
          WHERE ca.client_id = conversation_learning_events.user_id
          AND ca.consultant_id = auth.uid()
          AND ca.status = 'active'
        )
      );
    CREATE POLICY "Admins can view all learning events"
      ON conversation_learning_events FOR SELECT
      USING ((auth.jwt()->>'app_role')::text = 'admin');
  END IF;
END $$;
