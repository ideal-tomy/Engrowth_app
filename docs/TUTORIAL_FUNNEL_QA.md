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
| `marquee_tap` | Marquee導線タップ（source, label） |

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

## 導線別到達率の比較

Marquee ON/OFF や導線文言を変えた場合、以下を比較する:

- `marquee_tap` の source（header/bottom）別、label 別タップ数
- `/scenario-learning` や `/story-training` への遷移元（必要に応じて遷移前イベントを追加）

## 最適化の進め方

1. **離脱が多いステップ**: `tutorial_fallback_used` や `tutorial_skipped` の at_step_id を集計し、該当ステップの文言・UX を改善
2. **フォールバック頻度**: intent 判定のキーワード追加または unknown 応答の改善
3. **導線効果**: Marquee の label や表示順を変え、到達率の差分を計測
