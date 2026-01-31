-- Supabase Storage設定SQL
-- Supabase Dashboard → SQL Editor で実行してください

-- ============================================
-- 1. ストレージポリシーの設定
-- ============================================

-- sentences-imagesバケットの公開読み取りポリシー
CREATE POLICY "Public Access for sentences-images"
ON storage.objects FOR SELECT
USING (bucket_id = 'sentences-images');

-- words-imagesバケットの公開読み取りポリシー
CREATE POLICY "Public Access for words-images"
ON storage.objects FOR SELECT
USING (bucket_id = 'words-images');

-- 認証済みユーザーのアップロード許可（sentences-images）
CREATE POLICY "Authenticated users can upload to sentences-images"
ON storage.objects FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated' AND
  bucket_id = 'sentences-images'
);

-- 認証済みユーザーのアップロード許可（words-images）
CREATE POLICY "Authenticated users can upload to words-images"
ON storage.objects FOR INSERT
WITH CHECK (
  auth.role() = 'authenticated' AND
  bucket_id = 'words-images'
);

-- 認証済みユーザーの更新許可（sentences-images）
CREATE POLICY "Authenticated users can update sentences-images"
ON storage.objects FOR UPDATE
USING (
  auth.role() = 'authenticated' AND
  bucket_id = 'sentences-images'
);

-- 認証済みユーザーの更新許可（words-images）
CREATE POLICY "Authenticated users can update words-images"
ON storage.objects FOR UPDATE
USING (
  auth.role() = 'authenticated' AND
  bucket_id = 'words-images'
);

-- 認証済みユーザーの削除許可（sentences-images）
CREATE POLICY "Authenticated users can delete sentences-images"
ON storage.objects FOR DELETE
USING (
  auth.role() = 'authenticated' AND
  bucket_id = 'sentences-images'
);

-- 認証済みユーザーの削除許可（words-images）
CREATE POLICY "Authenticated users can delete words-images"
ON storage.objects FOR DELETE
USING (
  auth.role() = 'authenticated' AND
  bucket_id = 'words-images'
);

-- ============================================
-- 完了メッセージ
-- ============================================
DO $$
BEGIN
  RAISE NOTICE 'Supabase Storageポリシーの設定が完了しました！';
  RAISE NOTICE '次に、Supabase Dashboard → Storage でバケットを作成してください:';
  RAISE NOTICE '  - sentences-images (Public bucket)';
  RAISE NOTICE '  - words-images (Public bucket)';
END $$;
