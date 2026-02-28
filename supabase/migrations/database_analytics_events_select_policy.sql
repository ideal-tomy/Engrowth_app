-- ユーザーが自分の analytics_events を読み取り可能にする
-- ダッシュボード・進捗画面で会話ターン数等を表示するため
CREATE POLICY "Users can read own analytics events"
  ON analytics_events FOR SELECT
  USING (auth.uid() = user_id);
