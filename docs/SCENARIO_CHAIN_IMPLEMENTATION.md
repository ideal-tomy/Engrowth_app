# シチュエーション連鎖学習（ストーリー型）導入手順

## 目的
「シチュエーションからの英語想起」を強化し、場面の流れで記憶を定着させる。

## 対象機能
- シーン連鎖ストーリー（例: 空港 → ホテル → レストラン）
- シナリオ単位の進捗管理
- シナリオ完了演出

## UI/UX要件（スマホ前提）
- シナリオ一覧はカード型で「所要時間/難易度/進捗率」を表示
- 学習モードはシナリオ内の順序で自動遷移
- 完了時に小さな達成演出（バッジ連動可）

## 技術要件
### 1) データモデル追加
新規テーブル:
`scenarios`
- `id` (uuid)
- `title` (text)
- `description` (text)
- `thumbnail_url` (text)
- `difficulty` (text)
- `estimated_minutes` (int)

`scenario_steps`
- `id` (uuid)
- `scenario_id` (uuid)
- `sentence_id` (uuid)
- `order_index` (int)

`user_scenario_progress`
- `user_id` (uuid)
- `scenario_id` (uuid)
- `last_step_index` (int)
- `completed_at` (timestamptz)

## 実装手順
1. **DB追加**
   - `scenarios` / `scenario_steps` / `user_scenario_progress`
2. **モデル追加**
   - `Scenario`, `ScenarioStep`, `UserScenarioProgress`
3. **一覧画面追加**
   - シナリオ一覧（カード）
   - 進捗率表示
4. **学習導線**
   - シナリオ選択 → 学習モードへ遷移
   - `order_index`で順番に進む
5. **完了判定**
   - 最終ステップ学習後に`completed_at`更新

## 受け入れ条件
- シナリオ選択から順番に学習できる
- 進捗が中断/再開で維持される
- 完了時に視覚的な達成演出がある

