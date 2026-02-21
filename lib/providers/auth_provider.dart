import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// 現在のユーザーID（匿名時はnull）
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// 現在のユーザーID（従来の currentUserIdProvider 互換）
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.id;
});

/// 認証段階（匿名 / ログイン済み / 伴走契約）
/// 伴走契約は user_plans テーブルまたは app_metadata で判定（将来実装）
final authStageProvider = Provider<AuthStage>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return AuthStage.anonymous;
  // TODO: user_plans テーブルまたは app_metadata で coaching 判定
  // 現時点ではログイン済み = signedIn
  return AuthStage.signedIn;
});

/// 匿名ユーザーかどうか
final isAnonymousProvider = Provider<bool>((ref) {
  return ref.watch(authStageProvider) == AuthStage.anonymous;
});

/// 伴走契約中かどうか
final isCoachingProvider = Provider<bool>((ref) {
  return ref.watch(authStageProvider) == AuthStage.coaching;
});
