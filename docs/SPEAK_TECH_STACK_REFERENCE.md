# Speak風UX 技術スタック・実装リファレンス

Speak や Duolingo などの事例をもとに、Engrowth で採用・検討したい技術や実装パターンを整理する。  
ここは **「どんな道具でどう作るか」** を書く場所。

---

## 0. 目的と前提

- `SPEAK_STYLE_UX_PRINCIPLES.md` が「どう動かしたいか（原則）」を定義。
- 本ドキュメントは、それを支える**技術候補・実装パターン**をまとめる。
- 現時点では「構想〜候補」の段階のものも含める（採用・却下は今後整理）。

---

## 1. アニメーション / キャラクター表現

### 1.1 Rive / Lottie でのベクターアニメーション

**ベンチマーク（主に Duolingo）**

- Rive:
  - ベクター＋リアルタイムアニメーションエンジン。
  - iOS / Android / Web / Flutter / React にランタイムあり。
  - State Machine 機能で、`isSpeaking`, `isThinking`, `isCorrect` などの **入力に応じてアニメーション状態を切り替え・ブレンド**。
  - キャラクターごとに 20 以上の口形（viseme）を用意し、音声タイミングに合わせて口を動かしている。
- Lottie:
  - After Effects 由来の JSON アニメーション。
  - 再生主体で、状態遷移・インタラクションは Rive より弱いが、**簡単なループやトランジションには十分**。

**Engrowthでの想定パターン**

- 初期フェーズ:
  - Flutter 標準の `Animated*` / `AnimatedSwitcher` / `Hero` / `TweenAnimationBuilder` を中心に構成。
  - 一部で Lottie を採用（例: 完了時の小さな祝福アニメーション）。
- 将来フェーズ:
  - 「マスコット」や「口パク付きキャラクター」を導入する場合、Rive を候補に。
  - `TTS` の phoneme / viseme データと組み合わせて、Duolingo 風のリアルタイムリップシンクも検討余地あり。

---

### 1.2 リップシンク（viseme）連携の考え方

**Duolingo のやり方（要約）**

1. TTS / 音声エンジンから phoneme / word timing を取得。
2. phoneme を 20 種類程度の viseme（口形）にマッピング。
3. 再生中の音声のタイムスタンプに合わせて、Rive State Machine に mouthShape を流し込む。

**Engrowthでの現実的なステップ**

- 当面は「口パクなし or シンプルな口パク」で十分。
- もし将来やるなら：
  - OpenAI TTS や他のTTSが提供する phoneme / viseme 情報を取得。
  - Flutter 側で mouthIndex を時間ごとに計算し、アニメーション（Rive or カスタム）に渡す。
- いきなり実装する必要はなく、**音声再生サービス層（`openai_tts_service.dart` など）に拡張ポイントを用意**しておけばよい。

---

## 2. Reactive State Management と UI更新

### 2.1 音声・会話進行と UI の結びつけ

**Speak の特徴**

- Roleplay / Live Roleplays 中に、音声解析や AI からのレスポンスに合わせて、
  - 波紋エフェクト
  - 表情変化
  - 会話ログのスクロール
  がリアルタイムで動く。
- これは「音声エンジンの状態」と「UI状態」がしっかり同期しているから可能。

**Engrowthでの基本パターン（Riverpod 前提）**

- 例: 30秒会話
  - `ConversationSessionState` に
    - currentUtteranceIndex
    - isPlaying
    - isListening
    - isThinking
    などを持たせる。
  - 音声イベント（再生開始/終了、録音開始/終了）から state を更新。
  - Widget は `ref.watch(...)` で state に応じて
    - 波紋表示
    - ボタンの有効/無効
    - ハイライトカード
    を切り替える。

---

### 2.2 Chaining Animations の実装パターン

- Timer と AnimationController を組み合わせる定型：

```dart
// 疑似コード（構造だけ）
Future<void> runTutorialSequence() async {
  await Future.delayed(const Duration(seconds: 1)); // 登場前の静寂
  _backdropController.forward();                    // ぼかし開始
  await Future.delayed(const Duration(milliseconds: 300));
  _popupController.forward();                       // ポップアップ登場
  await Future.delayed(const Duration(seconds: 3)); // 読む時間
  await _runDemoAnimation();                        // ボタン擬似タップなど
  await Future.delayed(const Duration(milliseconds: 1200)); // 余韻
  await _fadeOutAndNavigateNext();                  // フェードアウト＋遷移
}

重要なのは、「登場 → 滞在 → 演出 → 余白 → 退場」を 1本の Future チェーンとして書くこと。
これにより、「Speak風の振付」がコード上で明示される。


## 3. Dynamic Asset Loading / 先読み

### 3.1 なぜ必要か
SpeakやDuolingoのような「止まらない体験」を実現するには、
画面切り替え中（余白の時間）に次の音声やリソースをロードしておく必要がある。
いきなり全てを真似る必要はないが、Engrowth でも TTS / 画像 / 一部アニメーションのプリフェッチを検討する。

### 3.2 一般的なパターン（要約）
Preload:
「先に読み始めてはおくが、完全には待たない」。
Flutter であれば precacheImage、ブラウザであれば <link rel="preload"> など。
Prefetch:
完全にダウンロードしてから使う。
「次の画面が表示されるまでに終われば、遷移後はゼロレイテンシ」。
Engrowthでの応用例

チュートリアルで 30秒会話 → パターンスプリント → 日々報告 と進む流れの中で、
30秒会話の音声再生中に、パターンスプリント用の TTS データを先読み。
Onboarding の前ステップで、次ステップで使う画像やサムネイルを precacheImage。
実装場所は、
openai_tts_service.dart に簡易プリフェッチ API を追加
Onboarding / 学習画面の initState で「次に必要になる ID」を渡す といった構成を想定。


## 4. Live Roleplays / Realtime Voice
※ここは将来的な構想メモであり、今すぐ実装するものではない。

Speak の Live Roleplays:
OpenAI Realtime API（音声ストリーミング）＋ LiveKit などを使い、 300ms 程度の応答レイテンシで会話を実現。
Realtime API 側が、音声入力・音声出力・テキスト情報を一括管理。
Engrowth で本格導入する場合:
Flutter Web / Mobile から WebSocket or WebRTC 経由で Realtime API を叩く層を設計。
現行の「TTS → 再生 → 録音 → STT → LLM」直列フローを、 将来的に「ストリーミング会話フロー」に置き換えやすいよう、サービス層を抽象化しておく。


## 5. 参考リンク（人間向け）
Micro-fluency / Learn-Drill-Apply:
Hands On With Speak's AI Language Tutor（micro-fluency 解説記事）
Home / Speak Level / ストリーク:
Speak Winter 2025 リリースノート（ホームリデザイン、Speak Level、ストリーク freeze/repair）
Rive / キャラクターアニメーション:
How Duolingo Uses Rive for Their Character Animation
How Duolingo Animates Its World Characters（viseme / 口形設計）
Dynamic Asset Loading 一般:
各種 prefetch / preload の解説記事（Remotion / THEOplayer など）
※ Engrowth の実装に取り込んだ内容は、適宜 SPEAK_STYLE_UX_PRINCIPLES.md や各 PLAN / 実装ドキュメントに昇格させていく。
