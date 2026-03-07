# スキーマ差異分析（CSV vs アプリ期待値）

**結論: `user_stats`・`user_progress`・`tts_assets` のいずれかのスキーマ不一致が、アプリクラッシュや TTS キャッシュ不発の原因になっている可能性が高い。**

---

## 0. CSV 完全照合サマリ（Supabase Snippet Public Schema Column List.csv）

| テーブル | CSV に存在 | アプリ/Edge が期待 | 状態 |
|----------|-------------|---------------------|------|
| **tts_assets** | id, speed, duration_ms, created_at, last_used_at | cache_key, storage_path, model, voice, language | **cache_key 等が不足** → キャッシュ lookup 失敗の可能性 |
| **user_stats** | id, user_id, total_sentences_learned, consecutive_days, last_learned_at, last_study_date | daily_done_count, daily_goal_count, daily_reset_date, streak_count, timezone, created_at, updated_at | **新スキーマ不足** → TypeError / 502 |
| **user_progress** | **テーブルなし** | next_review_at, hint_usage_count, used_hint_to_master 等 | **テーブル不在** → relation does not exist |
| analytics_events | あり | あり | OK |
| sentences | あり | あり | OK |

**tts_assets に cache_key が無い場合**: Edge Function の `.eq("cache_key", keyHash)` が失敗し、常に edge 経路（OpenAI 直呼び）になる。direct_db が 1 件しかない理由の候補。

---

## 1. user_stats の差異

| アプリが期待するカラム | CSV（実際のDB） | 状態 |
|------------------------|-----------------|------|
| daily_done_count | なし | **不足** |
| daily_goal_count | なし | **不足** |
| daily_reset_date | なし | **不足** |
| streak_count | なし | **不足**（consecutive_days はある） |
| timezone | なし | **不足** |
| updated_at | なし | **不足** |
| created_at | なし | **不足** |
| last_study_date | あり | OK |
| total_sentences_learned | あり | 旧スキーマ |
| consecutive_days | あり | 旧スキーマ |
| last_learned_at | あり | 旧スキーマ |

**エラー**: `Could not find the 'daily_done_count' column of 'user_stats'`

---

## 2. user_progress の有無

| 項目 | 状態 |
|------|------|
| CSV に user_progress テーブル | **記載なし** |
| アプリが参照 | review_service, progress_provider, supabase_service 等 |

**エラー**: `column user_progress.next_review_at does not exist` または `Could not find the table 'public.user_progress'`

---

## 3. tts_assets の差異（CSVが不完全な可能性）

CSV には `id, speed, duration_ms, created_at, last_used_at` のみ。  
キャッシュ参照に必須の `cache_key`, `storage_path`, `model`, `voice`, `language` が CSV に無い。

- prefill が 1997 ヒットしているなら、実際の DB には `cache_key` 等が存在している可能性が高い
- CSV のエクスポート範囲や対象が限定的だった可能性あり

---

## 4. 影響の流れ

```
アプリ起動
  → user_stats 取得（daily_done_count 等を SELECT）
  → カラムが無い → PostgrestException / TypeError
  → 画面表示や API が失敗
  → 502 / CORS エラー、null エラーが連鎖
  → TTS まで到達しない、または再生が不安定に
```

**TTS の設定が正しくても、user_stats / user_progress の不整合でアプリ全体が不安定になる。**

---

## 5. 修正用 SQL（1回で実行）

**推奨**: `supabase/migrations/fix_schema_gap_user_stats_progress.sql` を Supabase SQL Editor に貼り付けて一括実行。

以下は手動で分割実行する場合の参考。

### Step 0: tts_assets に cache_key 等を追加（CSV で不足時）

```sql
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'tts_assets') THEN
    ALTER TABLE tts_assets ADD COLUMN IF NOT EXISTS cache_key TEXT;
    ALTER TABLE tts_assets ADD COLUMN IF NOT EXISTS storage_path TEXT;
    ALTER TABLE tts_assets ADD COLUMN IF NOT EXISTS model TEXT DEFAULT 'tts-1-hd';
    ALTER TABLE tts_assets ADD COLUMN IF NOT EXISTS voice TEXT;
    ALTER TABLE tts_assets ADD COLUMN IF NOT EXISTS language TEXT;
    CREATE UNIQUE INDEX IF NOT EXISTS idx_tts_assets_cache_key ON tts_assets(cache_key) WHERE cache_key IS NOT NULL;
  END IF;
END $$;
```

### Step A: user_stats に不足カラムを追加

```sql
-- user_stats に不足カラムを追加（既存テーブルがある場合）
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_stats') THEN
    ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS daily_done_count INTEGER DEFAULT 0;
    ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS daily_goal_count INTEGER DEFAULT 3;
    ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS daily_reset_date DATE;
    ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS streak_count INTEGER DEFAULT 0;
    ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS timezone TEXT DEFAULT 'Asia/Tokyo';
    ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    ALTER TABLE user_stats ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
  END IF;
END $$;
```

### Step B: user_progress テーブルの存在確認と作成

```sql
-- user_progress が無ければ作成（supabase_schema.sql の基本形）
CREATE TABLE IF NOT EXISTS user_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  sentence_id UUID REFERENCES sentences(id) ON DELETE CASCADE,
  is_mastered BOOLEAN DEFAULT FALSE,
  last_studied_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, sentence_id)
);

-- 復習用カラムを追加
ALTER TABLE user_progress ADD COLUMN IF NOT EXISTS hint_usage_count INTEGER DEFAULT 0;
ALTER TABLE user_progress ADD COLUMN IF NOT EXISTS used_hint_to_master BOOLEAN DEFAULT FALSE;
ALTER TABLE user_progress ADD COLUMN IF NOT EXISTS next_review_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE user_progress ADD COLUMN IF NOT EXISTS last_review_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE user_progress ADD COLUMN IF NOT EXISTS stability DOUBLE PRECISION DEFAULT 1.0;
ALTER TABLE user_progress ADD COLUMN IF NOT EXISTS difficulty DOUBLE PRECISION DEFAULT 0.3;
ALTER TABLE user_progress ADD COLUMN IF NOT EXISTS review_count INTEGER DEFAULT 0;

-- RLS（既存ポリシーがある場合はエラーになるが、初回は必要）
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own progress" ON user_progress;
CREATE POLICY "Users can view own progress" ON user_progress FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can insert own progress" ON user_progress;
CREATE POLICY "Users can insert own progress" ON user_progress FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can update own progress" ON user_progress;
CREATE POLICY "Users can update own progress" ON user_progress FOR UPDATE USING (auth.uid() = user_id);
```

### Step C: 確認用 SQL

```sql
-- user_stats: daily_done_count が存在するか
SELECT column_name FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'user_stats' AND column_name = 'daily_done_count';

-- user_progress: next_review_at が存在するか
SELECT column_name FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'user_progress' AND column_name = 'next_review_at';
```

両方とも 1 行返れば OK。

---

## 6. 実行順序（まとめ）

1. **診断スクリプト実行** → `dart run scripts/diagnose_schema_gap.dart` で不足を確認
2. **一括修正** → `supabase/migrations/fix_schema_gap_user_stats_progress.sql` を SQL Editor で実行
3. Step C で確認
4. アプリを再起動して、`TypeError: null is not a subtype of String` や 502 が解消しているか確認
5. **tts_assets を修正した場合** → `dart run scripts/prefill_tts_assets.dart` を再実行してキャッシュを再投入

これで TTS とは別の要因によるクラッシュを抑え、音声再生まで処理が届くか確認できる。
