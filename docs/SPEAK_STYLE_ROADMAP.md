# Speak風UX ページ別ロードマップ

Engrowth を Speak風のUI/UXに近づけるための**ページ別ロードマップ**。  
「どの順番で」「どの観点から」「どういうPLAN→実装サイクルで」進めるかを整理する。

参照元:
- 原則: `SPEAK_STYLE_UX_PRINCIPLES.md`
- ベンチマーク: `SPEAK_BENCHMARK_UX_NOTES.md`
- 技術スタック: `SPEAK_TECH_STACK_REFERENCE.md`
- 既存PLANの書き方: `docs/plans/SPEAK_LIKE_GUIDED_FLOW_PLAN.md`

---

## 0. 進め方の共通ルール

- 各ページごとの作業は、必ず **「PLAN.md → 実装」** の順で進める。
- PLAN には最低限、次の4つを含める。
  - Goal（何を達成するか）
  - Non-goal（今回はやらないこと）
  - Exit Criteria（完了判定）
  - 参照ドキュメントと影響ファイル（画面・サービス・ルートなど）
- 実装は、基本的に **小さなPR単位**（1PR=1ページ or 1フェーズ）で出す。
- UXの判断に迷ったら:
  1. `MASTER_PLAN.md` の哲学 / Guardrails
  2. `SPEAK_STYLE_UX_PRINCIPLES.md`
  3. 各ページ専用PLAN
  の順で優先する。

---

## 1. 全体の順番

1. チュートリアル（Onboarding / Tutorial Flow）
2. パターンスクリプトページ（Pattern Sprint）
3. 学習進捗ページ（Progress / Dashboard 内「深堀進捗」を含む）
4. 3分会話（長尺会話）
5. 単語一覧（Word List）
6. センテンス一覧（Sentence List）
7. 30秒会話（Scenario / Quick Conversation）
8. 学習進捗内「深堀進捗」の詳細化（3と並行・後半フェーズ）

※ 3 と 8 は実装上は同じ画面グループだが、PLAN上は「基礎リデザイン」と「深堀表現強化」に分けて扱う。

---

## 2. チュートリアル（Onboarding / Tutorial Flow）

- **目的**: 初回体験で、「静寂と動きの振付」「自動進行＋余韻」「Speak風テンポ」を全体として確立する。
- **参照**:
  - 原則: `SPEAK_STYLE_UX_PRINCIPLES.md` の「振付テンプレート」「3.1〜3.4」
  - 技術: `SPEAK_TECH_STACK_REFERENCE.md` の「2.2 Chaining Animations」
  - 既存PLAN: `SPEAK_LIKE_GUIDED_FLOW_PLAN.md`
- **PLANで決めること（例）**:
  - TutorialSequencer 的な共通コンポーネントの設計（登場→滞在→演出→余白→退場）。
  - Onboarding 各ステップ（挨拶 / 30秒会話導線 / パターンスプリント導線 / 日々報告導線）に、どのシークエンスを適用するか。
  - 自動進行のタイミングと「ユーザーに任せる」ポイントの境界。
- **Exit Criteria のイメージ**:
  - 初回チュートリアルが、ほぼ手放しで Speak風の流れ（説明→デモ→余韻→次へ）を体験できる。
  - 主要な遷移が `EngrowthRouteTokens` / `EngrowthElementTokens` 準拠の時間設定になっている。

---

## 3. パターンスクリプトページ（Pattern Sprint）

- **目的**: マイクロフルエンシーの「Practice」部分として、1セット単位の「これだけは言える」を体験させる。
- **参照**:
  - ベンチマーク: `SPEAK_BENCHMARK_UX_NOTES.md` の「2.1 Goldilocks Zone」「2.2 Variable Rewards」
  - 原則: `SPEAK_STYLE_UX_PRINCIPLES.md` の「余韻」「静かな祝福」に関する部分
  - 技術: `SPEAK_TECH_STACK_REFERENCE.md` のアニメーション / 先読み（必要に応じて）
- **PLANで決めること（例）**:
  - 1セットの中で「ここまでできたらOK」という**ゴールの定義**（秒数・回数・パターン数）。
  - セット完了時の「静かな祝福」演出（小さなアニメ・一言メッセージ・余韻時間）。
  - チュートリアル導線から入った場合と、通常利用の場合の挙動差。
- **Exit Criteria のイメージ**:
  - 1〜2セットやるだけで、「この言い回しなら口から出る」という感覚が残る。
  - 完了演出が毎回少しずつ違い（可変報酬）、それでも過剰にうるさくない。

---

## 4. 学習進捗ページ（Progress / Dashboard + 深堀進捗）

- **目的**: Speak のホームのように、「どこにいる・何が次・どれだけ進んだか」を一目で分かる状態にする。
- **参照**:
  - ベンチマーク: `SPEAK_BENCHMARK_UX_NOTES.md` の「3. Home / Progress UI」「3.2 Speak Level / ストリーク」
  - 原則: `MASTER_PLAN.md` の KPI / Consultant Bridge（提出とのつながり）
- **PLANで決めること（例）**:
  - Engrowth版の指標（例: 日々提出数・今週のミッション達成・Engrowth Level など）。
  - 進捗パス（バブル / カード）の単位（ユニット / ミッション / 期間）。
  - 深堀進捗（ある単元をタップした時の詳細ビュー）で見せる情報と演出。
- **Exit Criteria のイメージ**:
  - ホーム or 進捗ページを1〜2秒見るだけで、「今日は何をやればよいか」が分かる。
  - ストリークや連続提出が、**優しい設計（freeze / repair 的な考え）**で組み込まれている。

---

## 5. 3分会話（長尺会話）

- **目的**: マイクロフルエンシーの「Apply」に近い、本番寄りの長尺体験を提供する。
- **参照**:
  - ベンチマーク: `SPEAK_BENCHMARK_UX_NOTES.md` の「マイクロフルエンシー」関連メモ
  - 原則: チュートリアルと同じ「振付テンプレート」（特に登場・余韻・退場）
  - 既存PLAN: `SPEAK_LIKE_GUIDED_FLOW_PLAN.md`（3分会話導線部分）
- **PLANで決めること（例）**:
  - チュートリアルでは「価値紹介のみ」、本番画面では「フル体験」と割り切る境界。
  - 長尺ゆえの疲労を軽減するための、途中の**小さな区切りとご褒美**。
- **Exit Criteria のイメージ**:
  - 「きついけど、終わると達成感が大きい」長尺体験になっている。
  - 終了後は、日々報告や次のPracticeに自然に橋渡しされる。

---

## 6. 単語一覧（Word List）

- **目的**: メインフローの外側にある「Practice（サイドクエスト）」として、迷子にならない単語学習の場を提供する。
- **参照**:
  - ベンチマーク: `SPEAK_BENCHMARK_UX_NOTES.md` の「3.1 Learn / Practice / Apply」
  - 原則: 1画面1目的・説明過多の回避（`MASTER_PLAN.md` / `ENGROWTH_DESIGN_SYSTEM.md`）
- **PLANで決めること（例）**:
  - ホームから単語一覧への導線（どのタブ / カードから入るか）。
  - 単語一覧内での「音で覚える」要素（TTS / シャドーイングミニプレイなど）。
  - メインフロー（会話・パターン）とのつながりをどう見せるか。
- **Exit Criteria のイメージ**:
  - 単語一覧に行っても、**「今日は何をやればいいか」が変に増えすぎない**。
  - 単語練習が、本流コンテンツの理解を補強していると感じられる。

---

## 7. センテンス一覧（Sentence List）

- **目的**: パターンや会話の「素材集」として、センテンスを横断的に眺め・練習できる場を作る。
- **参照**:
- ベンチマーク: `SPEAK_BENCHMARK_UX_NOTES.md` （特に Learn / Practice の層）
- 技術: センテンスの TTS / フィルタリングなどは `SPEAK_TECH_STACK_REFERENCE.md` + 既存 TTS docs
- **PLANで決めること（例）**:
  - センテンス一覧を「どの視点で切るか」（シチュエーション / 構文パターン / レベル）。
  - 1センテンスあたりのミニ体験（聞く→まねる→小さなOK演出）。
- **Exit Criteria のイメージ**:
  - センテンス一覧が、「会話やパターンで出てきたフレーズの復習ハブ」として機能している。

---

## 8. 30秒会話（Scenario / Quick Conversation）

- **目的**: チュートリアルでも触れた「30秒会話」を、本番シナリオとして磨き込む。
- **参照**:
  - ベンチマーク: `SPEAK_BENCHMARK_UX_NOTES.md`（Goldilocks / Zero-Friction）
  - 技術: `SPEAK_TECH_STACK_REFERENCE.md` の Reactive State / Chaining
  - 既存PLAN: `SPEAK_LIKE_GUIDED_FLOW_PLAN.md`（30秒シナリオ部分）
- **PLANで決めること（例）**:
  - 初回と2回目以降で、ガイドフローの強さをどう変えるか。
  - 30秒という長さの中で、「聞く」「まねる」「話す」の比率をどうするか。
- **Exit Criteria のイメージ**:
  - 30秒会話を1〜2本やるだけで、「このシチュエーションならとりあえず何とか話せる」感覚が残る。

---

## 9. このロードマップの使い方

- 新しいページ／機能に着手するときは、まずこのファイルで**対象セクションを確認**し、そこで書いた観点を PLAN にコピーして肉付けする。
- PLAN が固まったら、`ACTIVE_DOCS_INDEX.md` の Plans セクションへリンクを追加してから実装を始める。
- 実装が進んで気づきが増えたら、
  - 原則レベルの変化 → `SPEAK_STYLE_UX_PRINCIPLES.md`
  - Speak解釈レベルの変化 → `SPEAK_BENCHMARK_UX_NOTES.md`
  - 技術パターンの変化 → `SPEAK_TECH_STACK_REFERENCE.md`
  に反映し、このロードマップは**順番と粒度のガイド**として保つ。

