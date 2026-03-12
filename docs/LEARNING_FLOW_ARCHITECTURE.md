# LEARNING_FLOW_ARCHITECTURE

3分会話などの学習体験を「1枚の学習ページ（Scaffold）の上で、ポップアップが入れ替わる舞台」として扱うための設計メモです。

## コンポーネント概要

- `EngrowthPopup` / `EngrowthPopupVariant`
  - `standard`: 通常の確認・ガイド用。ボタン/外タップで閉じる。
  - `bridge`: 学習ステップ間の橋渡し。自動表示 → 一定時間滞在 → 退場。
  - `missionClear`: ミッション達成など、ユーザーに余韻を味わってもらう節目用。
- `EngrowthPopupTokens`
  - `bridgeShowDuration` / `bridgeFadeOutDuration` / `bridgeBlurExitDuration` で Bridge 演出の黄金比を定義。
- `LearningStep`（sealed class）
  - `ListeningStep` / `SpeakingStep` / `ExplanationStep` / `MilestoneStep` など、1ステップを型として表現。
- `LearningFlowController`
  - 現在のステップ index を管理し、`onStepCompleted()` で次ステップへの遷移と Bridge ポップアップ表示イベントを発行。
- `LearningFlowScaffold`
  - 単一の `Scaffold` 上で `AnimatedSwitcher` によりステップ UI を切り替え、上部に進捗バーを表示。

## Bridge ポップアップのライフサイクル

- 登場: `AnimatedBackdrop` で背景ぼかし → `StaggerReveal` で要素を時間差表示。
- 滞在: `EngrowthPopupTokens.bridgeShowDuration` ミリ秒だけ表示。
- 退場: `_isExiting = true` により、カードは `bridgeFadeOutDuration` でフェードアウト＋スライドダウン、背景ぼかしは `bridgeBlurExitDuration` でゆっくり晴れる。
- 完了: 退場アニメーション完了後に `Navigator.maybePop()` でポップアップを閉じる。

## LearningFlowController の役割

- `steps: List<LearningStep>` と現在 index (`state`) を保持。
- `onStepCompleted()`:
  - 最終ステップであれば `LearningFlowCompleted` を emit。
  - そうでなければ次ステップを参照し、`bridgeTitle` が設定されていれば `LearningFlowShowBridge` イベントを emit。
- `goToNextStep()`:
  - Bridge 演出が終わったタイミングで呼ばれ、`state` をインクリメントして次ステップに進める。

Widget 側では `events` ストリームを subscribe し、

- `LearningFlowShowBridge` 受信時: `EngrowthPopup.show(variant: EngrowthPopupVariant.bridge, ...)` を呼び、閉じたあとに `goToNextStep()`。
- `LearningFlowCompleted` 受信時: 一覧画面などに戻る遷移を行う。

## 3分会話フローへの適用イメージ

- Step1: `ListeningStep(storyId: current)`
  - 完了 → 6択ポップアップ（A/B/両方/もう一度聴く/次の学習へ/学習進捗）
  - 「次の学習へ」選択時に `onStepCompleted()` を呼ぶ。
- Step2: `ListeningStep(storyId: next, bridgeTitle: '次のストーリータイトル へ進みます')`
  - Step1 完了時に Bridge ポップアップが挟まり、3秒表示後に自動で次のストーリー学習ステップへ進む。

この設計により、「ページ遷移を極力減らしつつ、ポップアップの入れ替わりだけで学習フローを表現する」Speak 風 UX を実現します。

