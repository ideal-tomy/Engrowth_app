# 起動性能計測イベントとクエリ

起動遅延改善の before/after 比較用。`analytics_events` に送信されるイベントと、現状値採取用のクエリ例。

## 計測ポイント（定義）

| イベント | 送信タイミング | event_properties |
|----------|----------------|------------------|
| `app_boot_started` | 初回フレーム描画後（main 開始からの経過を付与） | `boot_to_first_frame_ms` |
| `first_frame_rendered` | 同上 | `boot_to_first_frame_ms` |
| `home_critical_ready` | Home タブでスケルトン/ヘッダーが表示された直後 | `boot_to_critical_ms` |
| `home_full_ready` | Home で userStats 取得完了（data or error）時 | `boot_to_full_ms` |

- ブート基準時刻は `main()` 先頭で `BootMetrics.setStarted()` が呼ばれた時点。
- ローカル・本番ともに同じイベントが送信される（Supabase 接続済みである必要あり）。

## 現状値採取クエリ例（Supabase SQL）

直近 N 件の起動ごとの経過 ms を取得する例:

```sql
-- 直近 50 起動の first_frame / critical / full の平均・中央値
WITH startup_events AS (
  SELECT
    user_id,
    created_at,
    event_type,
    (event_properties->>'boot_to_first_frame_ms')::int AS boot_to_first_frame_ms,
    (event_properties->>'boot_to_critical_ms')::int   AS boot_to_critical_ms,
    (event_properties->>'boot_to_full_ms')::int       AS boot_to_full_ms
  FROM analytics_events
  WHERE event_type IN ('first_frame_rendered', 'home_critical_ready', 'home_full_ready')
    AND created_at > now() - interval '7 days'
)
SELECT
  event_type,
  count(*) AS n,
  round(avg(boot_to_first_frame_ms)) AS avg_first_frame_ms,
  round(avg(boot_to_critical_ms))   AS avg_critical_ms,
  round(avg(boot_to_full_ms))        AS avg_full_ms
FROM startup_events
GROUP BY event_type;
```

改善後は上記と同じクエリで比較し、`avg_*_ms` の短縮を確認する。
