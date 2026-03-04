import 'package:flutter/material.dart';

/// Engrowth ブランドカラー
/// https://engrowth 提供アプリのテーマ
class EngrowthColors {
  /// プライマリ（ブランドレッド）
  static const Color primary = Color(0xFFD30306);

  /// プライマリの薄いバリアント
  static const Color primaryLight = Color(0xFFE83538);

  /// プライマリの濃いバリアント
  static const Color primaryDark = Color(0xFFA00204);

  /// 背景・オフホワイト
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundSoft = Color(0xFFF9F9FA);
  static const Color backgroundElevated = Color(0xFFFCFCFD);

  /// サーフェス（カード等）
  static const Color surface = Color(0xFFFFFFFF);
  /// 進捗カードのデフォルト背景（薄いグレー）
  static const Color cardSurfaceLight = Color(0xFFF5F5F5);
  static const Color surfaceGlass = Color(0xCCFFFFFF);
  static const Color silverBorder = Color(0xFFE2E5EA);
  static const Color silverShadow = Color(0x1A9BA4B2);

  /// テキスト
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF212121);
  static const Color onSurface = Color(0xFF424242);
  static const Color onSurfaceVariant = Color(0xFF757575);

  /// セマンティック
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFD30306);

  /// A役（お客様）・B役（店員）の色（テーマに合わせて調整）
  static const Color roleA = Color(0xFF1565C0);
  static const Color roleB = Color(0xFF2E7D32);
}

/// Engrowth アプリのテーマデータ
class EngrowthTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: EngrowthColors.primary,
        onPrimary: EngrowthColors.onPrimary,
        primaryContainer: EngrowthColors.primaryLight,
        surface: EngrowthColors.surface,
        onSurface: EngrowthColors.onSurface,
        surfaceContainerHighest: EngrowthColors.background,
        error: EngrowthColors.error,
        onError: EngrowthColors.onPrimary,
      ),
      scaffoldBackgroundColor: EngrowthColors.backgroundSoft,
      appBarTheme: const AppBarTheme(
        backgroundColor: EngrowthColors.surfaceGlass,
        foregroundColor: EngrowthColors.onBackground,
        elevation: 0,
      ),
      dividerColor: EngrowthColors.silverBorder,
      cardTheme: CardTheme(
        color: EngrowthColors.cardSurfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: EngrowthColors.silverBorder),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          fontFamilyFallback: ['Playfair Display', 'Noto Serif JP'],
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          fontFamilyFallback: ['Playfair Display', 'Noto Serif JP'],
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EngrowthColors.primary,
          foregroundColor: EngrowthColors.onPrimary,
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EngrowthColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: EngrowthColors.background,
        selectedColor: EngrowthColors.primaryLight,
        side: const BorderSide(color: EngrowthColors.silverBorder),
        labelStyle: const TextStyle(color: EngrowthColors.onSurface),
        secondaryLabelStyle: const TextStyle(color: EngrowthColors.onPrimary),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: EngrowthColors.onSurfaceVariant,
        textColor: EngrowthColors.onSurface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: EngrowthColors.surface.withOpacity(0.95),
        indicatorColor: EngrowthColors.primary.withOpacity(0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: EngrowthColors.primary);
          }
          return const IconThemeData(color: EngrowthColors.onSurfaceVariant);
        }),
      ),
      dividerTheme: const DividerThemeData(color: EngrowthColors.silverBorder),
      iconTheme: const IconThemeData(color: EngrowthColors.onSurfaceVariant),
    );
  }

  static ThemeData get darkTheme {
    const bg = Color(0xFF121212);
    const surface = Color(0xFF1E1E1E);
    const onSurface = Color(0xFFE0E0E0);
    const accent = Color(0xFFFF6B6B);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: accent,
        onPrimary: const Color(0xFF1A1A1A),
        primaryContainer: accent.withOpacity(0.2),
        surface: surface,
        onSurface: onSurface,
        surfaceContainerLowest: const Color(0xFF1A1C23),
        surfaceContainerHighest: const Color(0xFF2D2D2D),
        outline: onSurface.withOpacity(0.5),
        outlineVariant: onSurface.withOpacity(0.3),
        error: accent,
        onError: const Color(0xFF1A1A1A),
        shadow: const Color(0x40000000),
      ),
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
      ),
      dividerColor: onSurface.withOpacity(0.2),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: onSurface.withOpacity(0.15)),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          fontFamilyFallback: ['Playfair Display', 'Noto Serif JP'],
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          fontFamilyFallback: ['Playfair Display', 'Noto Serif JP'],
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: const Color(0xFF1A1A1A),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: accent.withOpacity(0.3),
        side: BorderSide(color: onSurface.withOpacity(0.3)),
        labelStyle: TextStyle(color: onSurface),
        secondaryLabelStyle: const TextStyle(color: Color(0xFF1A1A1A)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: onSurface.withOpacity(0.7),
        textColor: onSurface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface.withOpacity(0.92),
        indicatorColor: accent.withOpacity(0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: accent);
          }
          return IconThemeData(color: onSurface.withOpacity(0.7));
        }),
      ),
      dividerTheme: DividerThemeData(color: onSurface.withOpacity(0.2)),
      iconTheme: IconThemeData(color: onSurface.withOpacity(0.7)),
    );
  }
}

/// Motion Token: Route遷移（ページ間）
/// Zero-Latency: 1秒超は禁止。通常 <= 240ms、結果系 <= 320ms
class EngrowthRouteTokens {
  /// standardPush: 学習系詳細（fade + slightSlide）
  static const Duration standardPushDuration = Duration(milliseconds: 220);
  static const Duration standardPushReverseDuration = Duration(milliseconds: 180);
  static const double standardPushSlideOffset = 0.03;
  static const Curve standardPushCurve = Curves.easeOutCubic;

  /// modalPush: 設定/補助導線（fade + upFromBottom）
  static const Duration modalPushDuration = Duration(milliseconds: 180);
  static const Duration modalPushReverseDuration = Duration(milliseconds: 160);
  static const double modalPushSlideOffset = 0.06;
  static const Curve modalPushCurve = Curves.easeOutCubic;

  /// resultPush: リザルト画面（fade + scale）
  static const Duration resultPushDuration = Duration(milliseconds: 260);
  static const Duration resultPushReverseDuration = Duration(milliseconds: 200);
  static const double resultPushScaleBegin = 0.98;
  static const Curve resultPushCurve = Curves.easeOutCubic;
}

/// Motion Token: Element（画面内切替・AnimatedSwitcher）
/// 同期された滑らかさを優先。小振幅で体感遅延を抑える
class EngrowthElementTokens {
  /// 画面内切替の duration
  static const Duration switchDuration = Duration(milliseconds: 180);

  /// 表示側 curve
  static const Curve switchCurveIn = Curves.easeOutCubic;

  /// 非表示側 curve
  static const Curve switchCurveOut = Curves.easeInCubic;

  /// 切替時の Y オフセット（小振幅 0.02〜0.03）
  static const double switchOffsetY = 0.025;
}

/// Motion Token: Stagger（段階表示）
/// 要素間の遅延を抑え、同期感を保つ
class EngrowthStaggerTokens {
  /// 1 要素あたり遅延
  static const Duration itemDelay = Duration(milliseconds: 50);

  /// 各要素の duration
  static const Duration itemDuration = Duration(milliseconds: 180);

  /// curve
  static const Curve staggerCurve = Curves.easeOutCubic;

  /// Y オフセット
  static const double staggerOffsetY = 0.02;
}

/// Phase B: ふわっと表示統一のアニメーション基準値（後方互換）
/// 新規実装は EngrowthElementTokens / EngrowthStaggerTokens を参照すること
@Deprecated('Use EngrowthElementTokens for switch, EngrowthStaggerTokens for stagger')
class EngrowthAnimationTokens {
  static const Duration switchDuration = EngrowthElementTokens.switchDuration;
  static const Curve switchCurve = EngrowthElementTokens.switchCurveIn;
  static const double switchOffsetY = EngrowthElementTokens.switchOffsetY;
  static const Duration staggerBaseDelay = EngrowthStaggerTokens.itemDelay;
  static const Duration staggerItemDuration = EngrowthStaggerTokens.itemDuration;
  static const Curve staggerCurve = EngrowthStaggerTokens.staggerCurve;
  static const double staggerOffsetY = EngrowthStaggerTokens.staggerOffsetY;
}

class EngrowthShadows {
  static const List<BoxShadow> softCard = [
    BoxShadow(
      color: EngrowthColors.silverShadow,
      blurRadius: 22,
      spreadRadius: 1,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x10FFFFFF),
      blurRadius: 6,
      offset: Offset(-2, -2),
    ),
  ];
}
