# Motion Sync 計測クエリ（before/after 比較用）

`transition_complete_ms` / `tap_to_first_content_ms` / `cta_tap_rate` の before/after 比較に使用する SQL テンプレート。

## 前提

- `analytics_events` テーブルが存在すること
- イベント: `transition_complete`, `tap_to_first_content`, `primary_cta_visible`, `primary_cta_tapped`
- `variant`: `motion_sync` = 適用後、未指定 = 適用前

## transition_complete_ms（中央値・P95）

```sql
-- 適用後（variant = motion_sync）
SELECT
  event_properties->>'route_type' AS route_type,
  COUNT(*) AS cnt,
  ROUND(AVG((event_properties->>'transition_complete_ms')::int)) AS avg_ms,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (event_properties->>'transition_complete_ms')::int) AS median_ms,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY (event_properties->>'transition_complete_ms')::int) AS p95_ms
FROM analytics_events
WHERE event_type = 'transition_complete'
  AND event_properties->>'variant' = 'motion_sync'
  AND created_at > NOW() - INTERVAL '7 days'
GROUP BY event_properties->>'route_type';

-- 適用前（variant 未指定または null）は同クエリで variant IS NULL に変更
```

## tap_to_first_content_ms（Story導線）

```sql
SELECT
  event_properties->>'screen_name' AS screen_name,
  COUNT(*) AS cnt,
  ROUND(AVG((event_properties->>'tap_to_first_content_ms')::int)) AS avg_ms,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY (event_properties->>'tap_to_first_content_ms')::int) AS p95_ms
FROM analytics_events
WHERE event_type = 'tap_to_first_content'
  AND created_at > NOW() - INTERVAL '7 days'
GROUP BY event_properties->>'screen_name', event_properties->>'variant';
```

## cta_tap_rate（primary_cta_tapped / primary_cta_visible）

```sql
WITH visible AS (
  SELECT
    event_properties->>'screen_name' AS screen_name,
    event_properties->>'surface' AS surface,
    event_properties->>'variant' AS variant,
    COUNT(*) AS visible_cnt
  FROM analytics_events
  WHERE event_type = 'primary_cta_visible'
    AND created_at > NOW() - INTERVAL '7 days'
  GROUP BY 1, 2, 3
),
tapped AS (
  SELECT
    event_properties->>'screen_name' AS screen_name,
    event_properties->>'surface' AS surface,
    event_properties->>'variant' AS variant,
    COUNT(*) AS tapped_cnt
  FROM analytics_events
  WHERE event_type = 'primary_cta_tapped'
    AND created_at > NOW() - INTERVAL '7 days'
  GROUP BY 1, 2, 3
)
SELECT
  COALESCE(v.screen_name, t.screen_name) AS screen_name,
  COALESCE(v.surface, t.surface) AS surface,
  COALESCE(v.variant, t.variant) AS variant,
  COALESCE(v.visible_cnt, 0) AS visible_cnt,
  COALESCE(t.tapped_cnt, 0) AS tapped_cnt,
  ROUND(100.0 * COALESCE(t.tapped_cnt, 0) / NULLIF(COALESCE(v.visible_cnt, 0), 0), 1) AS cta_tap_rate_pct
FROM visible v
FULL OUTER JOIN tapped t ON v.screen_name = t.screen_name AND v.surface = t.surface AND v.variant = t.variant;
```
