// Web 専用: OAuth リダイレクト後の URL から認証トークンを除去し、共有時の漏洩を防ぐ
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// OAuth コールバック後、URL の hash / query から認証トークン・code を除去する。
/// 履歴を replaceState で更新し、URL 共有時にセッション漏洩しないようにする。
void cleanAuthParamsFromUrl() {
  try {
    final uri = Uri.parse(html.window.location.href);
    final hasSensitiveHash = uri.fragment.isNotEmpty &&
        (uri.fragment.contains('access_token') ||
            uri.fragment.contains('refresh_token') ||
            uri.fragment.contains('code='));
    final hasSensitiveQuery = uri.queryParameters.containsKey('access_token') ||
        uri.queryParameters.containsKey('refresh_token') ||
        uri.queryParameters.containsKey('code') ||
        uri.queryParameters.containsKey('error');

    if (hasSensitiveHash || hasSensitiveQuery) {
      final cleanUri = Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.hasPort ? uri.port : null,
        path: uri.path.isEmpty ? '/' : uri.path,
      );
      html.window.history.replaceState(null, '', cleanUri.toString());
    }
  } catch (_) {
    // クリーンアップ失敗時は無視（アプリ継続を優先）
  }
}
