# チュートリアル・導線 ファネルQAと最適化ガイド

## 計測イベント（analytics_events）

チュートリアルと初回体験の到達率・離脱分析に使用するイベント一覧。

| event_type | 用途 |
|------------|------|
| `tutorial_started` | 挨拶体験画面のオープン数（entry_source: onboarding / direct） |
| `tutorial_step_started` | 各ステップ開始（step_id, step_order） |
| `tutorial_step_completed` | ステップ完了（intent, used_fallback） |
| `tutorial_fallback_used` | 意図不明→フォールバック使用（離脱リスク指標） |
| `tutorial_completed` | チュートリアル完了 |
| `tutorial_skipped` | スキップ／閉じる（at_step_id・AppBar経路含む） |
| `tutorial_load_failed` | 読み込み失敗・セッション未取得（reason） |
| `onboarding_started` | 初回体験開始（variant で A/B 比較） |
| `onboarding_entry_tapped` | バナー/導線タップ（daily_report_card_shown から移行） |
| `onboarding_step_completed` | 各ステップ完了（variant） |
| `onboarding_completed` | 初回体験完了（variant） |
| `onboarding_skipped` | スキップ（at_step, variant） |
| `onboarding_home_handoff_shown` | 完了後ホーム誘導バナー表示 |
| `onboarding_home_handoff_tapped` | 誘導先タップ（target: resume_card） |
| `marquee_tap` | Marquee導線タップ（tap_id, target_route, source, label） |
| `learning_entry_started` | 学習画面表示時（entry_source: marquee, tap_id, learning_mode） |

## ファネル算出クエリ例（Supabase SQL）

```sql
-- チュートリアル完了率
SELECT
  COUNT(*) FILTER (WHERE event_type = 'tutorial_started') AS started,
  COUNT(*) FILTER (WHERE event_type = 'tutorial_completed') AS completed,
  COUNT(*) FILTER (WHERE event_type = 'tutorial_skipped') AS skipped
FROM analytics_events
WHERE event_type IN ('tutorial_started', 'tutorial_completed', 'tutorial_skipped')
  AND created_at > NOW() - INTERVAL '7 days';

-- 離脱ステップ（tutorial_fallback_used の step_id 別件数）
SELECT
  event_properties->>'step_id' AS step_id,
  COUNT(*) AS fallback_count
FROM analytics_events
WHERE event_type = 'tutorial_fallback_used'
  AND created_at > NOW() - INTERVAL '7 days'
GROUP BY event_properties->>'step_id'
ORDER BY fallback_count DESC;
```

## marquee_tap から学習開始までの到達率（B08）

tap_id で接続し、60秒以内の learning_entry_started を到達とみなす:

```sql
-- marquee_tap → learning_entry_started 到達率（60秒ウィンドウ）
WITH taps AS (
  SELECT
    user_id,
    (event_properties->>'tap_id')::text AS tap_id,
    created_at AS tap_at
  FROM analytics_events
  WHERE event_type = 'marquee_tap'
    AND created_at > NOW() - INTERVAL '7 days'
    AND event_properties->>'tap_id' IS NOT NULL
),
reached AS (
  SELECT t.user_id, t.tap_id
  FROM taps t
  WHERE EXISTS (
    SELECT 1 FROM analytics_events e
    WHERE e.event_type = 'learning_entry_started'
      AND e.user_id = t.user_id
      AND (e.event_properties->>'tap_id') = t.tap_id
      AND e.created_at >= t.tap_at
      AND e.created_at <= t.tap_at + INTERVAL '60 seconds'
  )
)
SELECT
  (SELECT COUNT(*) FROM taps) AS marquee_taps,
  (SELECT COUNT(*) FROM reached) AS learning_reached,
  ROUND(100.0 * (SELECT COUNT(*) FROM reached) / NULLIF((SELECT COUNT(*) FROM taps), 0), 1) AS reach_rate_pct;
```

## 導線別到達率の比較

Marquee ON/OFF や導線文言を変えた場合、以下を比較する:

- `marquee_tap` の source（header/bottom）別、label 別タップ数
- tap_id による marquee_tap → learning_entry_started 到達率

## 最適化の進め方

1. **離脱が多いステップ**: `tutorial_fallback_used` や `tutorial_skipped` の at_step_id を集計し、該当ステップの文言・UX を改善
2. **フォールバック頻度**: intent 判定のキーワード追加または unknown 応答の改善
3. **導線効果**: Marquee の label や表示順を変え、到達率の差分を計測
