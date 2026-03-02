# B09: ホーム初見3秒で主要導線認識の検証

## 定量計測（イベント）

| イベント | 発火タイミング |
|----------|----------------|
| home_primary_cta_impression | ホーム初回表示時（1回/セッション） |
| home_primary_cta_recognized | 主要導線タップ時、かつ impression から3秒以内 |

### 算出

- 3秒以内認識率 = home_primary_cta_recognized / home_primary_cta_impression

### SQL例

```sql
SELECT
  COUNT(*) FILTER (WHERE event_type = 'home_primary_cta_impression') AS impressions,
  COUNT(*) FILTER (WHERE event_type = 'home_primary_cta_recognized') AS recognized_under_3s,
  ROUND(100.0 * COUNT(*) FILTER (WHERE event_type = 'home_primary_cta_recognized')
    / NULLIF(COUNT(*) FILTER (WHERE event_type = 'home_primary_cta_impression'), 0), 1) AS recognition_rate_pct
FROM analytics_events
WHERE event_type IN ('home_primary_cta_impression', 'home_primary_cta_recognized')
  AND created_at > NOW() - INTERVAL '7 days';
```

---

## 定性検証（5人簡易ユーザーテスト）

### テスト観点チェックリスト

- [ ] 初見で「次に何をすべきか」が3秒以内に認識できるか
- [ ] 主要CTA（続きから再開、Marquee、メインタイル）が目立つか
- [ ] 選択肢が多すぎず、迷いがないか
- [ ] 1画面1目的（学習開始）が達成されているか
- [ ] 親指ゾーンに主要操作が配置されているか

### 実施方法

1. 被験者5人（初見または初回から1週間以上未使用）
2. アプリ起動 → ホーム表示
3. 「ここから次に何ができそうか、3秒で答えてください」
4. 正解: 学習開始系CTA（続きから、会話トレーニング、Marquee等）を挙げられること
5. 結果を集計し、認識率を算出

### 判定基準

- 定量: 3秒以内タップ率が週次で追跡可能であること
- 定性: 5人中4人以上が3秒以内に主要導線を正しく認識すること
