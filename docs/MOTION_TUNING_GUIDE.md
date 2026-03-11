# モーション・遷移スピード 微調整ガイド

ページ遷移やボタン・ポップアップの表示スピードを変えたいときの「このファイルのこの数字」一覧です。

---

## 1. ページ遷移の長さ（全体）

**ファイル:** `lib/theme/engrowth_theme.dart`  
**クラス:** `EngrowthRouteTokens`

| 用途 | 定数名 | 現在値（目安） | 変更すると効くこと |
|------|--------|----------------|--------------------|
| 学習系・通常 push | `standardPushDuration` | 1100 ms | 一覧→詳細など、標準の画面遷移の「入り」の長さ |
| 学習系・戻る | `standardPushReverseDuration` | 900 ms | 戻るボタンで前の画面に戻るときの長さ |
| チュートリアル専用（5倍水準） | `tutorialCrossfadeDuration` | 1800 ms | オンボーディング中の画面切り替え（クロスフェード） |
| チュートリアル・戻る | `tutorialCrossfadeReverseDuration` | 1400 ms | チュートリアルから戻るとき |
| モーダル（設定など） | `modalPushDuration` | 900 ms | 下から出てくるシートの長さ |
| リザルト画面 | `resultPushDuration` | 1300 ms | 完了画面の表示時間 |

- **遅くしたい:** 数値を大きくする（例: 1100 → 1500）。
- **速くしたい:** 数値を小さくする（例: 1100 → 700）。

---

## 2. どの画面でどの遷移が使われているか

**ファイル:** `lib/utils/router.dart`

- `_standardPushPage` … `standardPushDuration` / `standardPushReverseDuration` を使用（学習一覧→詳細など）。
- `_tutorialCrossfadePage` … `tutorialCrossfadeDuration` / `tutorialCrossfadeReverseDuration` を使用（オンボーディング中のシナリオ学習・パターンスプリント・チュートリアル会話など）。
- `_modalPushPage` … `modalPushDuration` / `modalPushReverseDuration` を使用（設定・補助画面）。
- `_resultPushPage` … `resultPushDuration` / `resultPushReverseDuration` を使用（リザルト画面）。

遷移の「種類」を変えたい場合は、各ルートの `pageBuilder` で上記のどれを呼んでいるかを確認してください。

---

## 3. 画面内の要素（ボタン・ポップアップ・テキスト切替）

**ファイル:** `lib/theme/engrowth_theme.dart`  
**クラス:** `EngrowthElementTokens`

| 定数名 | 現在値（目安） | 変更すると効くこと |
|--------|----------------|--------------------|
| `switchDuration` | 900 ms | AnimatedSwitcher・フェード・ボタンのパルスなど「画面内の切替」の長さ |
| `switchCurveIn` | Curves.easeOutCubic | 表示側のイージング |
| `switchCurveOut` | Curves.easeOut | 非表示側のイージング |

- チュートリアル内の「今日あった出来事」のテキスト切替、ハイライトの長さなども、多くの箇所で `EngrowthElementTokens.switchDuration` を参照しています。

### 3.1 チュートリアル/オンボーディングの「現行基準値」

**ファイル:** `lib/screens/onboarding_flow_screen.dart`, `lib/screens/tutorial_conversation_screen.dart`  

`EngrowthElementTokens` とは別に、チュートリアル/オンボーディング固有の Duration・ディレイがいくつか存在します。  
これらは **現行の体感テンポを基準とした値** として採用しており、トークン化する場合もまずこの数値を写す想定です。

| 用途 | 実装箇所 | 現行値 | 備考 |
|------|----------|--------|------|
| オンボーディング内 `PageView` ページ送り | `OnboardingFlowScreen._goToNext` / `previousPage` | 300 ms | `EngrowthElementTokens.switchDuration (900ms)` より短いが、オンボーディング標準としてこの値を採用する。将来トークン化する場合は `OnboardingPageDuration = 300ms` 相当で定義。 |
| 日次提出疑似体験の説明切り替えディレイ | `OnboardingFlowScreen._maybeStartMockDailyIntro` | 3 sec 間隔 | Speak風UXの「滞在 2〜3秒」に対応するドメイン固有値。1→2→3ステップの自動進行に使用。 |
| チュートリアル会話の自動録音開始までの余白 | `TutorialConversationScreen._scheduleAutoRecord` | 600 ms | プロンプト音声再生後の「一拍置いてから録音開始」用余白。 |
| チュートリアル会話完了時の余韻 | `TutorialConversationScreen._handleRecordingComplete` | 800 ms | 応答TTS再生後、体験完了メッセージ表示から画面遷移までの余白。 |

> 上記の値は、`EngrowthRouteTokens` / `EngrowthElementTokens` と完全には一致していませんが、**チュートリアル体験の現在の基準値**としてこのガイドに記載します。  
> モーションを調整する際は、まずここに書かれた数値を起点に検討し、そのうえで必要であればトークン側を拡張・正規化してください。

---

## 4. 段階表示（スタッガー）のテンポ

**ファイル:** `lib/theme/engrowth_theme.dart`  
**クラス:** `EngrowthStaggerTokens`

| 定数名 | 現在値（目安） | 変更すると効くこと |
|--------|----------------|--------------------|
| `itemDelay` | 250 ms | 要素が順番に表示されるときの「1つあたりの遅延」 |
| `itemDuration` | 900 ms | 各要素のアニメーションの長さ |

---

## 5. まとめ：よく触る場所

- **「ページの切り替わりを全体的に遅く/速くしたい」**  
  → `lib/theme/engrowth_theme.dart` の `EngrowthRouteTokens` の `*Duration` を変更。

- **「チュートリアルだけゆっくりにしたい」**  
  → 同上の `tutorialCrossfadeDuration` / `tutorialCrossfadeReverseDuration` を変更（`router.dart` はそのままで、テーマの数値だけ変えれば反映されます）。

- **「ボタンやポップアップの出方・消え方を遅く/速くしたい」**  
  → `lib/theme/engrowth_theme.dart` の `EngrowthElementTokens.switchDuration` を変更。

- **「どの画面がどの遷移を使っているか確認したい」**  
  → `lib/utils/router.dart` でルートごとの `pageBuilder` と、`_standardPushPage` / `_tutorialCrossfadePage` / `_modalPushPage` / `_resultPushPage` の対応を確認。
