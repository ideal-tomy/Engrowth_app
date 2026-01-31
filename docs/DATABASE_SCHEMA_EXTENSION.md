# データベーススキーマ拡張

## 概要

ヒントシステムと学習ログ機能のためのデータベーススキーマ拡張です。

## 新規テーブル

### 1. learning_logs テーブル

学習セッションとヒント使用の詳細ログを記録します。

```sql
CREATE TABLE IF NOT EXISTS learning_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  sentence_id UUID REFERENCES sentences(id) ON DELETE CASCADE,
  
  -- 学習セッション情報
  session_id UUID,  -- 学習セッションID（同じセッション内の複数ログをグループ化）
  session_start_time TIMESTAMP WITH TIME ZONE,
  
  -- ヒント使用情報
  hint_phase TEXT,  -- 'none', 'initial', 'extended', 'keywords'
  thinking_time_seconds INTEGER,  -- 考えていた時間（秒）
  used_hint BOOLEAN DEFAULT FALSE,  -- ヒントを使用したか
  
  -- 学習結果
  mastered BOOLEAN DEFAULT FALSE,  -- 覚えたか
  answer_shown BOOLEAN DEFAULT FALSE,  -- 答えを見たか
  
  -- メタデータ
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- インデックス
  INDEX idx_learning_logs_user_id (user_id),
  INDEX idx_learning_logs_sentence_id (sentence_id),
  INDEX idx_learning_logs_session_id (session_id),
  INDEX idx_learning_logs_created_at (created_at)
);
```

### 2. hint_settings テーブル

ユーザーごとのヒント設定を保存します。

```sql
CREATE TABLE IF NOT EXISTS hint_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  
  -- ヒントタイミング設定
  initial_hint_delay_seconds INTEGER DEFAULT 2,  -- 初期ヒントまでの秒数
  extended_hint_delay_seconds INTEGER DEFAULT 6,  -- 拡張ヒントまでの秒数
  keywords_hint_delay_seconds INTEGER DEFAULT 10,  -- 重要単語ヒントまでの秒数
  
  -- ヒント表示設定
  hint_opacity DOUBLE PRECISION DEFAULT 0.6,  -- ヒントの透明度（0.0-1.0）
  hint_phases_enabled TEXT[] DEFAULT ARRAY['initial', 'extended', 'keywords'],  -- 有効なヒント段階
  
  -- フィードバック設定
  haptic_feedback_enabled BOOLEAN DEFAULT TRUE,  -- バイブレーション有効
  visual_feedback_enabled BOOLEAN DEFAULT TRUE,  -- 視覚的フィードバック有効
  
  -- メタデータ
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 既存テーブルの拡張

### user_progress テーブルの拡張

```sql
-- 既存のuser_progressテーブルにカラムを追加
ALTER TABLE user_progress 
  ADD COLUMN IF NOT EXISTS hint_usage_count INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS used_hint_to_master BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS average_thinking_time_seconds INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS last_hint_phase TEXT;

-- インデックスの追加
CREATE INDEX IF NOT EXISTS idx_user_progress_hint_usage 
  ON user_progress(user_id, hint_usage_count);
```

## RLSポリシー

### learning_logs テーブル

```sql
ALTER TABLE learning_logs ENABLE ROW LEVEL SECURITY;

-- ユーザーは自分のログのみ閲覧可能
CREATE POLICY "Users can view own learning logs" 
  ON learning_logs FOR SELECT 
  USING (auth.uid() = user_id);

-- ユーザーは自分のログのみ挿入可能
CREATE POLICY "Users can insert own learning logs" 
  ON learning_logs FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- ユーザーは自分のログのみ更新可能
CREATE POLICY "Users can update own learning logs" 
  ON learning_logs FOR UPDATE 
  USING (auth.uid() = user_id);
```

### hint_settings テーブル

```sql
ALTER TABLE hint_settings ENABLE ROW LEVEL SECURITY;

-- ユーザーは自分の設定のみ閲覧可能
CREATE POLICY "Users can view own hint settings" 
  ON hint_settings FOR SELECT 
  USING (auth.uid() = user_id);

-- ユーザーは自分の設定のみ挿入可能
CREATE POLICY "Users can insert own hint settings" 
  ON hint_settings FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- ユーザーは自分の設定のみ更新可能
CREATE POLICY "Users can update own hint settings" 
  ON hint_settings FOR UPDATE 
  USING (auth.uid() = user_id);
```

## ビュー（統計用）

### hint_usage_stats ビュー

ヒント使用統計を簡単に取得するためのビューです。

```sql
CREATE OR REPLACE VIEW hint_usage_stats AS
SELECT 
  user_id,
  sentence_id,
  COUNT(*) as total_attempts,
  COUNT(*) FILTER (WHERE used_hint = TRUE) as hint_used_count,
  COUNT(*) FILTER (WHERE hint_phase = 'initial') as initial_hint_count,
  COUNT(*) FILTER (WHERE hint_phase = 'extended') as extended_hint_count,
  COUNT(*) FILTER (WHERE hint_phase = 'keywords') as keywords_hint_count,
  AVG(thinking_time_seconds) as avg_thinking_time,
  MAX(created_at) as last_studied_at
FROM learning_logs
GROUP BY user_id, sentence_id;
```

## 関数（統計計算用）

### get_user_hint_statistics 関数

ユーザーのヒント使用統計を取得する関数です。

```sql
CREATE OR REPLACE FUNCTION get_user_hint_statistics(p_user_id UUID)
RETURNS TABLE (
  total_sentences INTEGER,
  sentences_with_hints INTEGER,
  hint_usage_rate DOUBLE PRECISION,
  avg_thinking_time DOUBLE PRECISION,
  most_used_hint_phase TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(DISTINCT sentence_id)::INTEGER as total_sentences,
    COUNT(DISTINCT sentence_id) FILTER (WHERE used_hint = TRUE)::INTEGER as sentences_with_hints,
    CASE 
      WHEN COUNT(*) > 0 THEN 
        (COUNT(*) FILTER (WHERE used_hint = TRUE)::DOUBLE PRECISION / COUNT(*)::DOUBLE PRECISION) * 100
      ELSE 0
    END as hint_usage_rate,
    AVG(thinking_time_seconds)::DOUBLE PRECISION as avg_thinking_time,
    MODE() WITHIN GROUP (ORDER BY hint_phase) as most_used_hint_phase
  FROM learning_logs
  WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;
```

## マイグレーション手順

1. Supabase Dashboard → SQL Editor を開く
2. 上記のSQLを順番に実行
3. 既存データがある場合は、デフォルト値を設定

```sql
-- 既存のuser_progressレコードにデフォルト値を設定
UPDATE user_progress 
SET 
  hint_usage_count = 0,
  used_hint_to_master = FALSE,
  average_thinking_time_seconds = 0
WHERE hint_usage_count IS NULL;
```

## データ整合性

### トリガー（updated_at自動更新）

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_hint_settings_updated_at
  BEFORE UPDATE ON hint_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### トリガー（user_progress自動更新）

学習ログが追加されたときに、user_progressを自動更新するトリガーです。

```sql
CREATE OR REPLACE FUNCTION update_user_progress_from_log()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_progress (
    user_id,
    sentence_id,
    hint_usage_count,
    used_hint_to_master,
    average_thinking_time_seconds,
    last_hint_phase,
    last_studied_at,
    is_mastered
  )
  VALUES (
    NEW.user_id,
    NEW.sentence_id,
    1,
    NEW.used_hint AND NEW.mastered,
    NEW.thinking_time_seconds,
    NEW.hint_phase,
    NEW.created_at,
    NEW.mastered
  )
  ON CONFLICT (user_id, sentence_id)
  DO UPDATE SET
    hint_usage_count = user_progress.hint_usage_count + 1,
    used_hint_to_master = CASE 
      WHEN NEW.used_hint AND NEW.mastered THEN TRUE 
      ELSE user_progress.used_hint_to_master 
    END,
    average_thinking_time_seconds = (
      (user_progress.average_thinking_time_seconds * (user_progress.hint_usage_count - 1) + NEW.thinking_time_seconds) 
      / user_progress.hint_usage_count
    ),
    last_hint_phase = NEW.hint_phase,
    last_studied_at = NEW.created_at,
    is_mastered = NEW.mastered OR user_progress.is_mastered;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_progress_on_learning_log
  AFTER INSERT ON learning_logs
  FOR EACH ROW
  EXECUTE FUNCTION update_user_progress_from_log();
```
