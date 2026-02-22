import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 認証状態: 匿名 / ログイン済み / 伴走契約
enum AuthStage {
  anonymous,
  signedIn,
  coaching,
}

/// Supabaseの認証状態を監視するProvider
final authStateProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange
      .map((event) => event.session?.user);
});

/// 現在のユーザーID（匿名時も Supabase 匿名ユーザーの ID が入る）
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// 現在のユーザーID（従来の currentUserIdProvider 互換）
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.id;
});

const _kDevViewAsSignedInKey = 'dev_view_as_signed_in';

/// 開発用: ログイン済み画面を確認するため、匿名のまま signedIn として表示する
/// 設定のロングプレス等で切り替え可能
final devViewAsSignedInProvider =
    StateNotifierProvider<DevViewAsSignedInNotifier, bool>((ref) {
  return DevViewAsSignedInNotifier();
});

class DevViewAsSignedInNotifier extends StateNotifier<bool> {
  DevViewAsSignedInNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kDevViewAsSignedInKey) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDevViewAsSignedInKey, state);
  }
}

/// 認証段階（匿名 / ログイン済み / 伴走契約）
/// 伴走契約は user_plans テーブルまたは app_metadata で判定（将来実装）
/// 開発時: devViewAsSignedInProvider が true なら常に signedIn を返す
final authStageProvider = Provider<AuthStage>((ref) {
  final devOverride = ref.watch(devViewAsSignedInProvider);
  if (kDebugMode && devOverride) return AuthStage.signedIn;

  final user = ref.watch(currentUserProvider);
  if (user == null) return AuthStage.anonymous;
  if (user.isAnonymous) return AuthStage.anonymous;
  // TODO: user_plans テーブルまたは app_metadata で coaching 判定
  return AuthStage.signedIn;
});

/// 匿名ユーザーかどうか（Supabase の匿名セッション）
final isAnonymousProvider = Provider<bool>((ref) {
  final devOverride = ref.watch(devViewAsSignedInProvider);
  if (kDebugMode && devOverride) return false;
  final user = ref.watch(currentUserProvider);
  return user?.isAnonymous ?? true;
});

/// 伴走契約中かどうか
final isCoachingProvider = Provider<bool>((ref) {
  return ref.watch(authStageProvider) == AuthStage.coaching;
});
