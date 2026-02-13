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

  /// サーフェス（カード等）
  static const Color surface = Color(0xFFFFFFFF);

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
      scaffoldBackgroundColor: EngrowthColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: EngrowthColors.primary,
        foregroundColor: EngrowthColors.onPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EngrowthColors.primary,
          foregroundColor: EngrowthColors.onPrimary,
          elevation: 2,
        ),
      ),
    );
  }
}
