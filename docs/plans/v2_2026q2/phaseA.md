# Phase A: 触覚統一（PLANモード用プロンプト）

## 実装済み運用ルール（2026 Q2）

### 計測イベント設計
- イベント: `haptic_fired`（`event_properties.trigger` 必須）
- 命名規約: `surface_action_level` 形式
  - 例: `dashboard_menu_selection`, `audio_record_stop_medium`, `tutorial_stepComplete_light`

### Before/After 比較指標
- 分析単位: 主要導線トップ5（Dashboard, Scenario Learning, Story Training, Tutorial, AudioControls）
- 指標:
  - タップ成功率（タップイベント→次画面到達）
  - タップ後離脱率（タップ後N秒以内離脱）
  - 触覚発火率（意図した操作に対する `haptic_fired` 比率）
- 実施: リリース前1週間を baseline、導入後1週間を treatment として同条件比較

### QAチェックリスト（手動）
- [ ] iOS/Android実機で selection/light/medium の強度差を確認
- [ ] 連打時の過剰振動・遅延・フリーズ有無
- [ ] 非対応端末（エミュレータ制限）で無害に動作すること
- [ ] CTA操作で従来同等以上の体感反応
- [ ] 主要導線5画面で触覚の強度とタイミングが基準どおり

### ハプティクス方針（明文化）
- `selectionClick`: リスト選択、タブ切替、軽いCTA押下など高頻度・軽操作
- `lightImpact`: 再生開始、1ステップ完了、補助アクション成功など中頻度
- `mediumImpact`: セッション完了、学習完了、重要遷移確定など低頻度で意味の重い操作
- 連打時: 同種トリガーを最小間隔（100ms）で間引く
- 非対応端末時: no-op（エラーをUIに出さない）
- 失敗時: 原則 `lightImpact` 以下に抑制

---

## 使い方

- Cursor の PLAN モードを開く
- 下の「Prompt」をそのまま貼る
- 返ってきた PLAN をレビューし、必要なら「計測イベント」「対象画面」を追加指示する
ZZ
## Prompt（そのまま貼り付け）

```text

Engrowth アプリの UI/UX 強化として、Phase A「触覚統一」を実装したいです。
MASTER_PLAN.md の Sound-First / Zero-Latency / Guardrails を最優先で、実装前の詳細 PLAN を作成してください。

【目的】
- ボタンタップ時の無反応感をなくし、アプリ全体で触覚品質を統一する
- 主要アクション（再生/録音/遷移/完了）に適切なハプティクスを割り当てる
- 画面ごとのバラバラ実装を減らし、共通ルール化する

【前提】
- 既存コードには HapticFeedback.selectionClick() が部分導入済み
- 主要コンポーネントとして lib/widgets/common/engrowth_cta.dart が存在
- analytics は lib/services/analytics_service.dart 経由でイベント送信可能

【必須要件】
1) PLAN は以下の章立てで作成する
   - Goal
   - Non-goal
   - Exit Criteria
   - 影響ファイル一覧
   - 実装ステップ（1PR=1目的）
   - リスクとフォールバック
   - 計測イベント設計
   - テスト観点（手動 + 自動）

2) ハプティクス方針を明文化する
   - selectionClick / lightImpact / mediumImpact の使い分け基準
   - 連打時・非対応端末時の扱い
   - 失敗時（エラー通知）での扱い方針

3) 共通化方針を明確にする
   - 既存 CTA コンポーネントに寄せるか
   - ユーティリティ層（例: feedback_service）を新設するか
   - 既存画面への段階導入順（優先画面トップ5）

4) 計測イベントを先に設計する
   - haptic_fired の trigger 命名規約
   - 主要導線での before/after 比較方法（離脱率・タップ成功率）

【制約】
- 色・余白などのUI実装は engrowth_theme.dart 準拠
- パフォーマンス劣化を避ける（Zero-Latency）
- 1PR=1目的の粒度を守る

【出力形式】
- 実装に着手できるレベルの具体性で、PR単位のタスク分解まで提示
- 「最初のPRで変更する具体ファイル」と「受け入れ条件」を明記
```
