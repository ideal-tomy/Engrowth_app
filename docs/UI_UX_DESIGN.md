# UI/UX設計ドキュメント

## 概要

EngrowthアプリのUI/UXを最高レベルに引き上げるための包括的な設計ドキュメントです。

## デザイン原則

### 1. ユーザー中心設計（User-Centered Design）
- 学習効率を最大化するUI
- 直感的な操作
- 視覚的なフィードバック

### 2. モダンなデザインシステム
- Material Design 3準拠
- 一貫性のあるデザイン言語
- アクセシビリティ対応

### 3. パフォーマンス最適化
- スムーズなアニメーション（60fps）
- 画像の最適化とキャッシュ
- 遅延読み込み（Lazy Loading）

## カラーパレット

```dart
// プライマリカラー
primary: Color(0xFF2196F3) // Blue
primaryVariant: Color(0xFF1976D2)
secondary: Color(0xFF03DAC6) // Teal
secondaryVariant: Color(0xFF018786)

// セマンティックカラー
success: Color(0xFF4CAF50) // Green
warning: Color(0xFFFF9800) // Orange
error: Color(0xFFF44336) // Red
info: Color(0xFF2196F3) // Blue

// ニュートラル
background: Color(0xFFFAFAFA) // Light Gray
surface: Color(0xFFFFFFFF) // White
onPrimary: Color(0xFFFFFFFF) // White
onSecondary: Color(0xFF000000) // Black
onBackground: Color(0xFF212121) // Dark Gray
onSurface: Color(0xFF212121) // Dark Gray
```

## タイポグラフィ

```dart
// 見出し
displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)
displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)

// タイトル
titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)
titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)

// 本文
bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)
bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)
bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)

// ラベル
labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)
labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)
labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)
```

## スペーシングシステム

```dart
// 8pxベースのグリッドシステム
spacing: {
  xs: 4.0,
  sm: 8.0,
  md: 16.0,
  lg: 24.0,
  xl: 32.0,
  xxl: 48.0,
}
```

## アニメーション

### トランジション
- **Duration**: 200-300ms（標準）、150ms（高速）、400ms（スムーズ）
- **Curve**: `Curves.easeInOut`（標準）、`Curves.easeOut`（表示）、`Curves.easeIn`（非表示）

### マイクロインタラクション
- ボタンタップ: スケールアニメーション（0.95 → 1.0）
- カードタップ: エレーション変化
- スワイプ: スムーズなページ遷移

### 学習モード専用アニメーション
- **ヒントフェードイン**: 300ms、`Curves.easeOut`
- **画面の光る効果**: 200ms、`Curves.easeInOut`
- **パルスアニメーション**: 1000ms、無限ループ
- **スライドイン**: 300ms、`Curves.easeOut`

## 触覚的フィードバック（Haptic Feedback）

### バイブレーションパターン
- **軽いタップ**: `HapticFeedback.lightImpact()` - ヒント表示時
- **選択クリック**: `HapticFeedback.selectionClick()` - 拡張ヒント表示時
- **中程度のインパクト**: `HapticFeedback.mediumImpact()` - 重要単語表示時
- **強いインパクト**: `HapticFeedback.heavyImpact()` - 覚えた時

### 設定
- ユーザーがON/OFFを切り替え可能
- アクセシビリティ設定に準拠
