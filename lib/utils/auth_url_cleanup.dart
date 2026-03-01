/// OAuth 後に URL から認証パラメータを除去（Web のみ実装、他は No-op）
library;

import 'auth_url_cleanup_stub.dart'
    if (dart.library.html) 'auth_url_cleanup_web.dart' as impl;

/// OAuth リダイレクト後の URL から access_token / refresh_token / code を除去する。
/// 共有 URL でセッション漏洩しないよう、本番 Web で呼び出すこと。
void cleanAuthParamsFromUrl() => impl.cleanAuthParamsFromUrl();
