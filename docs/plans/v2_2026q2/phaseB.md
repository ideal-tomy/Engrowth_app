# Phase B: ふわっと表示統一（PLANモード用プロンプト）

## 使い方

- Cursor の PLAN モードを開く
- 下の「Prompt」をそのまま貼る
- 返ってきた PLAN で、まず共通 Widget 設計を固めてから実装に進む

## Prompt（そのまま貼り付け）

```text
Engrowth アプリの UI/UX 強化として、Phase B「ふわっと表示統一」を実装したいです。
Speak のような滑らかさを目標に、AnimatedSwitcher と Staggered Animation を使った実装 PLAN を作成してください。
MASTER_PLAN.md の Sound-First / Zero-Latency / Guardrails に従ってください。

【目的】
- 画面内の切り替えを「パッと変わる」から「自然に流れる」へ統一する
- テキスト/ボタン/セクション表示をフェード+スライドで一貫化する
- 主要画面で表示タイミングの物語性（順番表示）を持たせる

【前提】
- 既存で一部 AnimatedSwitcher や段階表示は導入済み
- ルーティング遷移は lib/utils/router.dart で共通遷移が存在
- テーマは lib/theme/engrowth_theme.dart を基準に統一済み

【必須要件】
1) PLAN は以下の章立てで作成する
   - Goal
   - Non-goal
   - Exit Criteria
   - 影響ファイル一覧
   - 共通アニメーション仕様（duration/curve/offset）
   - 実装ステップ（1PR=1目的）
   - 計測イベント設計
   - テスト観点（視覚確認 + パフォーマンス）

2) 共通 Widget 設計を先に定義する
   - 例: FadeSlideSwitcher（AnimatedSwitcher ラップ）
   - 例: StaggerReveal（複数要素の時間差表示）
   - 既存画面への導入時の差分最小化方針

3) アニメーション基準値を明文化する
   - 切替: 300ms〜500ms / easeInOut 系
   - 初回表示: 80ms〜120ms ずつ遅延
   - 大きすぎる移動は避け、Y方向 8〜16px 程度

4) 適用優先画面を指定する
   - Home
   - Scenario Learning
   - Story Training
   - Onboarding Result
   （必要なら追加）

5) Zero-Latency 観点を含める
   - 60fps維持のための注意点
   - 過剰な再ビルド回避策
   - 低スペック端末での劣化防止

【制約】
- 1PR=1目的を守る
- 既存導線を壊さず段階導入
- デザイン値の直書きを避ける（theme/token 経由）

【出力形式】
- PR単位で「対象ファイル」「実装内容」「受け入れ条件」「計測」を明記
- 最初のPRで作る共通 Widget のAPI案（引数）まで示す
```
