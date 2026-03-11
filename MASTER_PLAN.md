# MASTER_PLAN.md: Engrowth UI/UX Transformation

## 0. この文書の役割（Single Source of Truth）
- 本ファイルを、Engrowthのプロダクト判断・実装優先度・受け入れ基準の唯一基準とする。
- 迷った場合は、必ず本書の「哲学」「ガードレール」「現在Phase」を優先する。
- 詳細仕様は各Runbookに切り出してよいが、最終判断は本書に戻す。

---

## 1. アプリの哲学・コンセプト（The Soul of Engrowth）
Engrowthは、単なる英会話学習アプリではない。
**「音で覚え、身体で慣れる」ことを徹底し、最終的に「コンサルタントによる伴走」で成果を出す、コーチング連動型ハイブリッドアプリ**である。

### 1.1 Core Principles
- **Sound-First**: テキストの前に、聴く・喋るを優先。画面は補助、主役は音。
- **Zero-Latency**: 学習のテンポを削がない。待ち時間はUX負債とみなす。
- **Consultant Bridge**: 学習を「報告」価値として可視化し、伴走へ繋ぐ。

### 1.2 Product Promise
- 初回3分で「音で覚える」体験価値を理解できる。
- 迷ったときは、1タップで正しい次アクションに戻れる。
- 毎日の小さな達成が、継続と提出につながる。

---

## 2. UI/UX ベンチマーク方針
業界の優れた体験を参照し、Engrowthの哲学に沿って再解釈する。

### 2.1 Tempo & Flow
- オートアドバンスでタップ回数を最小化。
- 思考中アニメーションで自然な「溜め」を設計。

### 2.2 Dopamine Loop
- 学習完了時のリザルト演出（カウントアップ、成功音、ハプティクス）。
- 成功時・押下時の触感品質を統一。

### 2.3 Ergonomics
- 主要操作は親指ゾーン（下部）へ。
- 1画面1目的を徹底し、説明過多を避ける。

---

## 3. 成功指標（KPI）
### 3.1 North Star
- 7日継続率（D7 Retention）
- 日課提出率（daily_report_submitted / active_users）

### 3.2 Onboarding / Tutorial
- `tutorial_started` -> `tutorial_completed` 完了率
- `tutorial_fallback_used` 発生率
- `onboarding_started` -> `onboarding_completed` 完了率

### 3.3 Navigation / UX
- `marquee_tap` から学習開始までの到達率
- 主要導線のタップ後離脱率

---

## 4. 実装ロードマップ（Phases）
## Phase 1: 基盤UIの磨き込み & 整理
### Goal
- ホームをコンパクトかつ迷わない導線に再設計。

### Scope
- ダッシュボード固定カード整理、Marquee導線強化。
- TTS再生の安定化（DB優先 + フォールバック）。
- Theme統一（ライト/ダークの可読性最適化）。

### Exit Criteria
- ホーム初見3秒で主要導線を認識できる。
- 主要画面のカラー・余白・タイポがテーマ準拠。

## Phase 2: 魔法の3分間（オンボーディング & チュートリアル）
### Goal
- 「音で覚える」価値を初回で体験理解させる。

### Scope
- 事前生成音声で低遅延チュートリアル。
- 使い方ページとコンセプトページ。

### Exit Criteria
- 60〜90秒で「聞く→話す→返答」を完了可能。
- 初回導線から迷子にならずホームに戻れる。

## Phase 3: 達成感の爆上げ（リザルト & 継続）
### Goal
- 完了時の気持ちよさと再訪動機を高める。

### Scope
- リザルト画面刷新（星、ゲージ、スコア演出）。
- 学習ログ可視化（継続日数、カレンダー）。

### Exit Criteria
- 学習完了後の次アクション率が向上。
- 継続導線（次回学習）が1タップで起動可能。

## Phase 4: コンサルタント・管理者機能
### Goal
- 学習データを伴走品質に変換する運用基盤を完成。

### Scope
- ロール別ダッシュボード。
- 報告連携（録音・進捗・レビュー）強化。

### Exit Criteria
- 提出からフィードバックまでの運用導線が確立。
- 権限/監査の要件を満たす。

---

## 5. 開発・実装ルール（Guardrails）
- **DB参照原則**: 音声URL取得は Supabase Client で直接参照を基本。
- **UI一貫性**: `engrowth_theme.dart` 準拠（色・フォント・角丸・余白）。
- **Speak風UX（ユーザー向け画面）**: 静寂と動きの同期・説明は自動表示/切り替え・ゆっくりした自然な流れで誘導。コンサルタント/管理者ダッシュボードは対象外。詳細は `docs/SPEAK_STYLE_UX_PRINCIPLES.md` および `.cursor/rules/speak-style-ux-app-wide.mdc`。
- **Analytics徹底**: 主要アクションにイベントを必ず仕込む。
- **速度優先**: 新機能追加時は遅延増加を必ず計測。
- **小さく出す**: 1PR = 1目的。A/Bや計測を先に仕込む。

---

## 6. ドキュメント運用ルール（新旧の見分け基準）
- ルート直下 `docs/` は **Active Docs のみ**。
- 完了済み・旧計画・参考資料は `docs/archive/` へ移動または`ARCHIVED`明示。
- マイグレーションSQLは履歴保全のため **`supabase/migrations` から移動しない**。
- SQLの新旧区分はファイル移動ではなく、`supabase/migrations/MIGRATION_CATALOG.md` で管理。

---

## 7. 現在のフェーズ（更新用）
- Current Phase: `Phase 2`
- This Week Focus: `チュートリアル体験の離脱改善`
- Owner: `@ryoji`
- Updated At: `YYYY-MM-DD`

---

## 8. 意思決定ログ（ADR簡易）
| Date | Decision | Why | Impact |
|------|----------|-----|--------|
| YYYY-MM-DD | 例: チュートリアルは事前生成音声を採用 | 低遅延・低コスト | 初回完了率向上 |
