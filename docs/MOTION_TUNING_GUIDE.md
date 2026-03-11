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
