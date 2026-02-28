-- tts-audio バケットを Public に変更
-- Public URL で即時返却し、createSignedUrl の往復を省略（1回目から爆速化）
-- 注意: path は SHA256 ハッシュで推測困難なため、公開範囲は限定的
UPDATE storage.buckets SET public = true WHERE id = 'tts-audio';
