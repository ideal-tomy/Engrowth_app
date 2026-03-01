-- お気に入りに pattern タイプを追加（パターンスプリント用）
ALTER TABLE user_favorites
  DROP CONSTRAINT IF EXISTS user_favorites_target_type_check;

ALTER TABLE user_favorites
  ADD CONSTRAINT user_favorites_target_type_check
  CHECK (target_type IN ('word', 'sentence', 'conversation', 'story', 'pattern'));
