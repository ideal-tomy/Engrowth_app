# Phase B 実装記録（ふわっと表示統一）

## 概要
phaseB.md の PLAN に基づき、共通 Widget 先行・段階導入で実装済み。

## 実装済み

### 共通 Widget（PR1）
- `lib/widgets/common/fade_slide_switcher.dart` — FadeSlideSwitcher
- `lib/widgets/common/stagger_reveal.dart` — StaggerReveal
- `lib/theme/engrowth_theme.dart` — EngrowthAnimationTokens 追加

### 適用画面（PR2–PR3）
- **Home** (`dashboard_screen.dart`): StaggerReveal で 3 ブロック段階表示
- **Scenario Learning** (`scenario_learning_screen.dart`): FadeSlideSwitcher + StaggerReveal
- **Story Training** (`story_training_screen.dart`): FadeSlideSwitcher + StaggerReveal
- **UnifiedResultContent** (`unified_result_content.dart`): StaggerReveal（見出し→要点→CTA）

### 計測イベント（analytics_service.dart）
- `logUiRevealStarted` / `logUiRevealCompleted`
- `logUiSwitcherTransition`
- `logPrimaryCtaVisible` / `logPrimaryCtaTapped`

## アニメーション基準値（EngrowthAnimationTokens）
- 切替: 360ms / easeInOutCubic / offsetY 0.06
- 段階表示: 100ms 遅延 / 320ms duration / offsetY 0.05

## 今後の拡張
- 各画面での `logUiReveal*` / `logPrimaryCta*` の実際の呼び出し
- Reduce motion 対応（slide 量縮退）
- 低スペック端末フォールバック
