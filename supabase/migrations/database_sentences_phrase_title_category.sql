-- sentences テーブルに phrase_title / category_label_ja を追加
-- センテンス一覧の「ネイティブ言い回しタイトル」と「日本語カテゴリタグ」用
-- Supabase Dashboard → SQL Editor で実行

-- 1. カラム追加（冪等）
ALTER TABLE sentences
  ADD COLUMN IF NOT EXISTS phrase_title TEXT,
  ADD COLUMN IF NOT EXISTS category_label_ja TEXT;

-- 2. インデックス（冪等）
CREATE INDEX IF NOT EXISTS idx_sentences_category_label_ja
  ON sentences(category_label_ja)
  WHERE category_label_ja IS NOT NULL AND category_label_ja != '';

CREATE INDEX IF NOT EXISTS idx_sentences_phrase_title
  ON sentences(phrase_title)
  WHERE phrase_title IS NOT NULL AND phrase_title != '';

-- 3. コメント
COMMENT ON COLUMN sentences.phrase_title IS 'ネイティブ言い回しタイトル（例: Can I have ...?, Would you like ...?）';
COMMENT ON COLUMN sentences.category_label_ja IS '日本語カテゴリタグ（例: 接客, 道案内, 買い物）';
