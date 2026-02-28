-- voice-recordings バケット作成と Storage ポリシー
-- 録音ファイルを保存。パス形式: {userId}/practice/{sessionId}_{timestamp}.m4a
-- 認証ユーザーは自分のフォルダのみアップロード・読み取り可能

-- バケット作成（Private）
INSERT INTO storage.buckets (id, name, public)
VALUES ('voice-recordings', 'voice-recordings', false)
ON CONFLICT (id) DO UPDATE SET public = false;

-- 既存ポリシーを削除（再実行時にエラー回避）
DROP POLICY IF EXISTS "Users can upload own recordings" ON storage.objects;
DROP POLICY IF EXISTS "Users can read own recordings" ON storage.objects;

-- ユーザーは自分のフォルダのみアップロード可能
CREATE POLICY "Users can upload own recordings"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'voice-recordings'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- ユーザーは自分の録音のみ読み取り可能（署名URL用）
CREATE POLICY "Users can read own recordings"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'voice-recordings'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );
