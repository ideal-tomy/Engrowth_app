import 'package:supabase_flutter/supabase_flutter.dart';

/// 認証サービス
/// 匿名ログイン・サインアップ・アカウントリンク・サインアウトを提供
class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// 現在のユーザーが匿名かどうか
  bool get isAnonymous => _client.auth.currentUser?.isAnonymous ?? true;

  /// セッションがあるか（匿名を含む）
  bool get hasSession => _client.auth.currentSession != null;

  /// 未ログイン時は匿名サインインを実行
  /// 既にセッションがあれば何もしない
  Future<void> ensureSignedIn() async {
    if (_client.auth.currentSession != null) return;
    await _client.auth.signInAnonymously();
  }

  /// メール・パスワードで新規登録
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return _client.auth.signUp(email: email, password: password);
  }

  /// メール・パスワードでログイン
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  /// 匿名ユーザーを永続アカウントに昇格（既存データを保持）
  /// updateUser でメール・パスワードを設定すると、同じ user_id のまま永続化される
  Future<UserResponse> linkAnonymousToPermanent({
    required String email,
    required String password,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null || !user.isAnonymous) {
      throw StateError(
        '匿名ユーザーでのみ実行できます。既にログイン中の場合は signUp/signIn を使ってください。',
      );
    }
    return _client.auth.updateUser(
      UserAttributes(email: email, password: password),
    );
  }

  /// Google OAuth でサインイン or 匿名ユーザーをリンク
  /// 匿名時: linkIdentity で同一 user_id を保持（Manual linking が Supabase で有効である必要あり）
  /// 非匿名時: signInWithOAuth で通常ログイン
  /// リダイレクト先は Supabase の Authentication > URL Configuration に登録すること
  Future<bool> signInWithGoogle() async {
    final user = _client.auth.currentUser;
    final isAnon = user != null && user.isAnonymous;
    final redirectTo = _redirectUrl;
    if (isAnon) {
      // 匿名のまま Google をリンク → 同じ user_id で永続アカウントになる（データ保持）
      await _client.auth.linkIdentity(
        OAuthProvider.google,
        redirectTo: redirectTo,
      );
    } else {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectTo,
      );
    }
    return true;
  }

  /// ログアウト（匿名の場合はサインアウト後、ensureSignedIn で匿名再ログイン可能）
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// OAuth リダイレクト先。Supabase の Redirect URLs に登録必須。
  /// 本番: https://engrowth-app.web.app。localhost の場合は本番URLに寄せてスマホ等で正しく戻れるようにする。
  static const String _productionRedirectUrl = 'https://engrowth-app.web.app';

  String get _redirectUrl {
    final origin = Uri.base.origin;
    if (origin.contains('localhost')) {
      return _productionRedirectUrl;
    }
    return origin;
  }
}
