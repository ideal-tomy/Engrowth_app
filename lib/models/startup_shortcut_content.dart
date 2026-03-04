/// 起動時ショートカットポップアップの表示内容
class StartupShortcutContent {
  /// 表示ソース: consultant=コンサル課題, app=アプリ推奨
  final String source;

  /// メッセージ本文
  final String message;

  /// CTAラベル
  final String ctaLabel;

  /// 遷移先ルート
  final String route;

  /// コンサル課題の場合は担当者アイコン表示
  final bool showConsultantAvatar;

  const StartupShortcutContent({
    required this.source,
    required this.message,
    required this.ctaLabel,
    required this.route,
    this.showConsultantAvatar = false,
  });
}
