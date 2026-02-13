-- 会話インポート用 RLS ポリシー
-- CSVインポートスクリプトで anon キーから INSERT できるようにする
-- Supabase Dashboard → SQL Editor で実行してください
--
-- 注意: 開発・インポート用途です。本番では適切に制限してください。

-- conversations: anon でも INSERT 可能
DROP POLICY IF EXISTS "Allow insert for import" ON conversations;
CREATE POLICY "Allow insert for import"
  ON conversations FOR INSERT
  WITH CHECK (true);

-- conversation_utterances: anon でも INSERT 可能
DROP POLICY IF EXISTS "Allow insert for import" ON conversation_utterances;
CREATE POLICY "Allow insert for import"
  ON conversation_utterances FOR INSERT
  WITH CHECK (true);
