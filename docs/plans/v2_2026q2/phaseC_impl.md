# Phase C 実装PLAN: 迷いナッジ

## Goal

- ユーザーの迷い時間を減らし、主要CTAへの到達率を上げる
- 誘導を「邪魔な割り込み」ではなく「優しい後押し」に統一する
- 起動時、学習開始前、未操作時の導線設計を全体最適する
- Speak のような快適な使用感と自然な行動要請・誘導を目指す

## Non-goal

- 既存の1日1回ルールや導線の破壊
- 新規ナッジの大量追加（疲労を招く過剰誘導）
- 複雑な機械学習ベースのパーソナライズ（今回はルールベース）
- 学習中の割り込み（Sound-First / Zero-Latency を損なうもの）

## Exit Criteria

- [ ] 起動時ナッジが最適化され、CTA到達率が計測可能
- [ ] チュートリアル3学習完了後に自動で次章へ遷移する
- [ ] 学習完了後に次学習優先シート（PostLearningNextActionSheet）が表示される
- [ ] 進捗画面に「学習に戻る」CTAが常時表示され、復帰率が計測可能
- [ ] 学習開始前ナッジが主要導線3つで統一され、迷いが減る
- [ ] 迷い検知ナッジ（3秒無操作）がホームで動作し、到達率比較が可能
- [ ] 全ナッジで `nudge_shown` / `nudge_dismissed` / `nudge_accepted` が送信される
- [ ] 同一セッションでの過剰再表示が防止されている（キュー制御）
- [ ] engrowth_theme 準拠、体験テンポを崩さない

## 影響ファイル一覧

| ファイル | 役割 |
|----------|------|
| `lib/services/analytics_service.dart` | ナッジ計測イベント追加 |
| `lib/widgets/dashboard_sections/startup_shortcut_overlay.dart` | 起動時ナッジ最適化 |
| `lib/widgets/dashboard_sections/startup_shortcut_popup.dart` | 文言・CTA改善 |
| `lib/widgets/tutorial/learning_intro_dialog.dart` | コンテキストナッジ（学習開始前） |
| `lib/widgets/nudge/post_learning_next_action_sheet.dart` | 完了後ハンドオフ（次学習優先） |
| `lib/widgets/nudge/idle_cta_nudge.dart` | 迷い検知ナッジ（新規） |
| `lib/widgets/nudge/nudge_coordinator.dart` | セッション内ナッジ優先度・制限（新規） |
| `lib/screens/dashboard_screen.dart` | 迷い検知ナッジの配置 |
| `lib/screens/scenario_learning_screen.dart` | LearningIntroDialog 導線 |
| `lib/screens/pattern_sprint_list_screen.dart` | 同上 |
| `lib/screens/story_training_screen.dart` | 同上 |
| `lib/theme/engrowth_theme.dart` | ナッジ用アニメーション値（必要時） |

---

## ナッジパターン設計

### 4層構造（完了後ハンドオフ統合済み）

| 層 | 目的 | 表示タイミング | 優先度 |
|----|------|----------------|--------|
| **起動時ナッジ** | 起動直後の迷いを減らす | 1日1回、Dashboard 表示時 | 1（最優先） |
| **完了後ハンドオフ** | 学習完了後の次行動誘導 | 学習完了時、次学習優先シート | 2 |
| **コンテキストナッジ** | 学習開始前の説明・次行動提案 | 指オーバーレイ完了後、学習画面へ遷移前 | 3 |
| **迷い検知ナッジ** | 無操作時のCTA強調 | 3秒無操作時 | 4 |

### 表示条件・非表示条件

| ナッジ | 表示条件 | 非表示条件 |
|--------|----------|------------|
| 起動時ショートカット | 当日未表示、content あり | 当日表示済み、content なし |
| LearningIntroDialog | チュートリアル導線、指オーバーレイ完了 | 通常導線、既に学習画面にいる |
| 迷い検知（3秒） | ホーム表示中、3秒無操作、起動時ナッジ非表示済み | 同一セッションで2回以上表示済み、他ナッジ表示中 |

### 同一セッション制限

- 迷い検知ナッジ: 1セッション最多1回まで
- 起動時 + 迷い検知: 同日に両方出る場合は起動時のみ（既存ルール）
- コンテキストナッジ: 学習開始前のみ（1学習1回）

---

## UI手段の使い分け

| 手段 | 使う条件 | 例 |
|------|----------|-----|
| **ダイアログ**（showDialog） | 1つの選択肢・説明を伝え、閉じたら即アクション | LearningIntroDialog、起動時ショートカット |
| **showModalBottomSheet** | 複数選択肢・詳細情報の表示、ユーザーが選ぶ | PostLearningNextActionSheet、次行動提案 |
| **インライン誘導**（バッジ/微バウンド） | 迷い検知時のCTA強調、軽い後押し | 3秒無操作時のCTA微バウンド |

---

## 計測イベント設計

### 共通イベント（全ナッジ用）

| イベント | 発火タイミング | event_properties |
|----------|----------------|------------------|
| `nudge_shown` | ナッジ表示時 | `nudge_type`, `surface`, `context` |
| `nudge_dismissed` | 閉じた時（CTA以外） | `nudge_type`, `surface`, `reason` |
| `nudge_accepted` | CTAタップ時 | `nudge_type`, `surface`, `target_route` |

### 完了後ハンドオフ・チュートリアル自動進行イベント

| イベント | 発火タイミング | event_properties |
|----------|----------------|------------------|
| `tutorial_auto_advanced` | オンボ学習完了→次章自動進行時 | `learning_mode`, `from_step`, `to_step` |
| `learning_handoff_shown` | 完了後シート表示時 | `source`, `track`, `candidate_count` |
| `learning_handoff_accepted` | 次学習/進捗/閉じる選択時 | `choice`, `track`, `target_route` |
| `learning_resume_from_progress` | 進捗画面から学習復帰時 | `route`, `source` |
| `handoff_queue_blocked` | オーケストレータ再入時 | `reason` |

### 既存イベントとの整合

- 起動時: `home_shortcut_popup_shown` を `nudge_shown` のエイリアスとして扱うか、または `nudge_shown` を追加送信
- 迷い時間: `nudge_shown` の `created_at` と `nudge_accepted` の `created_at` の差で算出

### 算出指標

- ナッジCTA到達率 = `nudge_accepted` / `nudge_shown`
- 迷い時間（秒） = `nudge_accepted.created_at` - `nudge_shown.created_at`（初回表示→CTAタップ）
- ナッジ有無での到達率比較: 迷い検知ナッジ ON/OFF の A/B 比較

### 新規メソッド（analytics_service.dart）

```dart
void logNudgeShown({required String nudgeType, required String surface, String? context}) =>
    logEvent(eventType: 'nudge_shown', eventProperties: {'nudge_type': nudgeType, 'surface': surface, if (context != null) 'context': context});
void logNudgeDismissed({required String nudgeType, required String surface, String? reason}) =>
    logEvent(eventType: 'nudge_dismissed', eventProperties: {'nudge_type': nudgeType, 'surface': surface, if (reason != null) 'reason': reason});
void logNudgeAccepted({required String nudgeType, required String surface, String? targetRoute}) =>
    logEvent(eventType: 'nudge_accepted', eventProperties: {'nudge_type': nudgeType, 'surface': surface, if (targetRoute != null) 'target_route': targetRoute});
```

---

## 失敗パターン回避

| パターン | 対策 |
|----------|------|
| 出しすぎによる疲労 | セッション内ナッジ上限、1日1回ルール遵守 |
| 読みづらい文言 | 短く（1行以内）・具体的に。CTAは動詞で始める |
| 同一セッションでの過剰再表示 | NudgeCoordinator でセッション内カウント管理 |
| 体験テンポを崩す | 迷い検知は3秒待ち、アニメーションは 300ms 以内 |
| 邪魔な割り込み感 | インライン誘導は控えめ（微バウンド 8px 程度） |

---

## 実装ステップ（1PR=1目的）

### PR1: 計測基盤の整備

**目的**: ナッジ計測イベントを先に仕込む

- **対象ファイル**: `lib/services/analytics_service.dart`
- **内容**: `logNudgeShown`, `logNudgeDismissed`, `logNudgeAccepted` を追加
- **受け入れ条件**: 既存イベントと同様に `analytics_events` へ送信されること
- **計測**: なし（基盤のみ）

---

### PR2: 起動時ナッジの最適化（MVP）

**目的**: 既存ショートカットを「優しい後押し」に統一し、文言・計測を改善

- **対象ファイル**: `startup_shortcut_overlay.dart`, `startup_shortcut_popup.dart`, `analytics_service.dart`
- **表示条件**: 既存（1日1回、content あり）
- **文言案**:
  - コンサル課題: 「今日はこの課題に挑戦してみましょう！」（既存）
  - アプリ推奨: 「今日の学習を30秒だけ始めませんか？」
  - デフォルト: 「昨日の続きを30秒だけやりませんか？」（既存）
- **受け入れ条件**: `nudge_shown` / `nudge_dismissed` / `nudge_accepted` が送信される
- **計測イベント**: `nudge_shown` (nudge_type: startup_shortcut), `nudge_dismissed`, `nudge_accepted`

---

### PR3: コンテキストナッジの統一（LearningIntroDialog）

**目的**: 3つの学習導線で LearningIntroDialog の計測を統一

- **対象ファイル**: `learning_intro_dialog.dart`, `scenario_learning_screen.dart`, `pattern_sprint_list_screen.dart`, `story_training_screen.dart`
- **表示条件**: 指オーバーレイ完了後、学習画面へ遷移前（既存）
- **受け入れ条件**: 各導線で `nudge_shown` (nudge_type: learning_intro) が送信される
- **計測イベント**: `nudge_shown` (context: quick30 / pattern_sprint / focus3), `nudge_accepted` がタップで発火

---

### PR4: 迷い検知ナッジ（MVP）

**目的**: ホームで3秒無操作時にCTAを軽く強調する

- **対象ファイル**: `lib/widgets/nudge/idle_cta_nudge.dart`（新規）, `lib/widgets/nudge/nudge_coordinator.dart`（新規）, `dashboard_screen.dart`
- **表示条件**: ホーム表示中、3秒無操作、起動時ナッジ非表示済み、同一セッション内1回まで
- **UI**: インライン誘導（主要CTAに微バウンド 8px、300ms easeOut）
- **文言案**: なし（視覚的強調のみ）
- **受け入れ条件**: 3秒無操作でCTAが微バウンドし、タップで `nudge_accepted` が送信される
- **計測イベント**: `nudge_shown` (nudge_type: idle_cta), `nudge_accepted`

---

### PR5（拡張）: 迷い検知ナッジに文言追加

**目的**: 微バウンドに加え、控えめなテキストヒントを表示

- **対象ファイル**: `idle_cta_nudge.dart`
- **文言案**: 「ここをタップして始めよう」など短い1行
- **受け入れ条件**: 微バウンド + テキスト表示、計測継続

---

### PR6（拡張）: ボトムシート型次行動提案

**目的**: 学習完了後など、複数選択肢がある場合にボトムシートで提案

- **対象ファイル**: 新規 `lib/widgets/nudge/next_action_bottom_sheet.dart`
- **表示条件**: 学習完了後、次行動候補が複数ある場合
- **受け入れ条件**: showModalBottomSheet で表示、選択で `nudge_accepted` 送信

---

## 最初の着手すべき最小構成（MVP）

1. **PR1**: 計測基盤
2. **PR2**: 起動時ナッジ最適化
3. **PR3**: コンテキストナッジ計測統一
4. **PR4**: 迷い検知ナッジ（ホーム）

この4PRで「迷いナッジ」のMVPが完了する。PR5・PR6は効果検証後に拡張。

---

## QAシナリオ

### 起動時ナッジ

- [ ] 初回起動時にショートカットが表示される
- [ ] 1日1回のみ表示される（2回目起動では表示されない）
- [ ] CTAタップで即遷移し、`nudge_accepted` が送信される
- [ ] 閉じた場合、`nudge_dismissed` が送信される
- [ ] 文言が短く読みやすい（1行以内）

### コンテキストナッジ（LearningIntroDialog）

- [ ] 30秒会話・パターンスプリント・3分会話の3つすべてで表示される
- [ ] 指オーバーレイ完了後に表示される
- [ ] タップで早期閉じ・遷移が可能
- [ ] 約5秒で自動閉じ、遷移する
- [ ] `nudge_shown` / `nudge_accepted` が送信される

### 迷い検知ナッジ

- [ ] ホーム表示中、3秒無操作でCTAが微バウンドする
- [ ] 同一セッションで2回以上表示されない
- [ ] 起動時ナッジ表示中は迷い検知は出ない
- [ ] 微バウンドアニメーションが 300ms 以内で滑らか
- [ ] CTAタップで `nudge_accepted` が送信される

### 失敗パターン回避

- [ ] 起動時 + 迷い検知が同日に両方出る場合、起動時のみ
- [ ] 連続で複数ナッジが重ならない
- [ ] テーマ準拠（engrowth_theme.dart）
- [ ] 体験テンポを崩さない（Zero-Latency）
