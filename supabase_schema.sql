-- Engrowth App Database Schema
-- Supabase DashboardのSQL Editorで実行してください

-- 単語テーブル
CREATE TABLE IF NOT EXISTS words (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  word_number INTEGER UNIQUE NOT NULL,
  word TEXT NOT NULL,
  meaning TEXT NOT NULL,
  part_of_speech TEXT,
  word_group TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 例文テーブル
CREATE TABLE IF NOT EXISTS sentences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  english_text TEXT NOT NULL,
  japanese_text TEXT NOT NULL,
  image_url TEXT,
  difficulty INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 例文と単語の関連テーブル
CREATE TABLE IF NOT EXISTS sentence_words (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sentence_id UUID REFERENCES sentences(id) ON DELETE CASCADE,
  word_id UUID REFERENCES words(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ユーザー進捗テーブル
CREATE TABLE IF NOT EXISTS user_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  sentence_id UUID REFERENCES sentences(id) ON DELETE CASCADE,
  is_mastered BOOLEAN DEFAULT FALSE,
  last_studied_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, sentence_id)
);

-- インデックスの作成（パフォーマンス向上）
CREATE INDEX IF NOT EXISTS idx_words_word_number ON words(word_number);
CREATE INDEX IF NOT EXISTS idx_words_word_group ON words(word_group);
CREATE INDEX IF NOT EXISTS idx_sentences_difficulty ON sentences(difficulty);
CREATE INDEX IF NOT EXISTS idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_sentence_id ON user_progress(sentence_id);

-- RLS (Row Level Security) ポリシー（デモ段階では全開放）
-- 本番環境では適切なポリシーを設定してください

-- wordsテーブル: 全ユーザーが読み取り可能
ALTER TABLE words ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Words are viewable by everyone" ON words
  FOR SELECT USING (true);

-- sentencesテーブル: 全ユーザーが読み取り可能
ALTER TABLE sentences ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Sentences are viewable by everyone" ON sentences
  FOR SELECT USING (true);

-- user_progressテーブル: ユーザーは自分の進捗のみアクセス可能
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own progress" ON user_progress
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own progress" ON user_progress
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own progress" ON user_progress
  FOR UPDATE USING (auth.uid() = user_id);
