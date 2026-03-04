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

---

## B09-Extension: 起動時ショートカットポップアップ検証

### 目的

- 起動直後の迷いを減らし、3秒以内に「次の学習行動」へ到達させる。
- ポップアップをお知らせではなく、学習ショートカットとして機能させる。

### 表示ルール

- 表示頻度: 1日1回
- 優先度:
  1. コンサルタント課題がある場合: 「コンサルタントからの課題」を表示
  2. 課題がない場合: 「アプリからの推奨」を表示

### UI要件

- 背景を軽く透過 + Blur し、ポップアップに集中を誘導
- コンサル課題は担当者アイコン付きで表示
- CTAは1つに絞り、タップで即遷移

### 定量計測（イベント）

| イベント | 発火タイミング |
|----------|----------------|
| home_shortcut_popup_shown | ポップアップ表示時（source, has_mission） |
| home_shortcut_popup_cta_tapped | CTAタップ時（route, source） |
| home_shortcut_popup_dismissed | 閉じた時（reason） |

### 算出

- ポップアップCTA到達率 = cta_tapped / popup_shown

### SQL例

```sql
SELECT
  COUNT(*) FILTER (WHERE event_type = 'home_shortcut_popup_shown') AS shown,
  COUNT(*) FILTER (WHERE event_type = 'home_shortcut_popup_cta_tapped') AS tapped,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE event_type = 'home_shortcut_popup_cta_tapped')
    / NULLIF(COUNT(*) FILTER (WHERE event_type = 'home_shortcut_popup_shown'), 0),
    1
  ) AS cta_rate_pct
FROM analytics_events
WHERE event_type IN (
  'home_shortcut_popup_shown',
  'home_shortcut_popup_cta_tapped'
)
  AND created_at > NOW() - INTERVAL '7 days';
```

---

## B09-Extension: パターンスプリント3段階練習の検証

### 仕様

- 同一英文を3回再生する
  - 1回目: 日英同時表示
  - 2回目: 英文のみ表示
  - 3回目: テキスト表示なし
- 3回目終了後、シャドーイング用の無音待機を音声長連動で挿入
  - 目安: 再生実測時間の1.2倍（下限・上限あり）

### 期待学習効果

- 1回目: 理解（意味と音の一致）
- 2回目: 定着（綴りと音の接続）
- 3回目: 自動化（耳主体で即応）

### 定量計測（イベント）

| イベント | 発火タイミング |
|----------|----------------|
| pattern_sprint_phase_started | 各フェーズ開始時（phase, item_index） |
| pattern_sprint_phase_completed | 各フェーズ完了時 |
| pattern_sprint_shadowing_gap_ms | 3回目後の待機（play_ms, gap_ms） |

### 判定基準

- 3段階を完走できるユーザー比率が週次で追跡可能
- 3回目後の待機時間が極端な偏りなく運用できる

---

## B09-Extension: パターンカテゴリ集中トレーニング検証

### 目的

- 「どんな時に使うか」をカテゴリで理解しつつ、同型フレーズ反復で発音と運用を同時強化する。

### カテゴリ例

- 注文（Can I have..., I'd like..., Can I get...）
- 買い物
- 道案内
- 依頼
- 感謝

### UI要件

- 一覧は「カテゴリ > パターン」構造で表示
- 各カテゴリに集中開始CTAを配置
- 使用シーン説明を1行で付与

### 定量計測（イベント）

| イベント | 発火タイミング |
|----------|----------------|
| pattern_sprint_category_selected | カテゴリ内パターン選択時 |
| pattern_sprint_category_started | カテゴリ起点でセッション開始時 |
| pattern_sprint_session_complete | セッション完了時 |

### 算出

- カテゴリ開始率 = category_started / category_selected
- カテゴリ別完了率 = session_complete / category_started
