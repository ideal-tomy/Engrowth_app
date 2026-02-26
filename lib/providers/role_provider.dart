import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _kDevViewAsConsultantKey = 'dev_view_as_consultant';
const _kDevViewAsAdminKey = 'dev_view_as_admin';

/// 開発用: 匿名のままコンサルタント画面を表示する
final devViewAsConsultantProvider =
    StateNotifierProvider<DevViewAsConsultantNotifier, bool>((ref) {
  return DevViewAsConsultantNotifier();
});

class DevViewAsConsultantNotifier extends StateNotifier<bool> {
  DevViewAsConsultantNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kDevViewAsConsultantKey) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDevViewAsConsultantKey, state);
  }
}

/// 開発用: 管理者ダッシュボードを表示する
final devViewAsAdminProvider =
    StateNotifierProvider<DevViewAsAdminNotifier, bool>((ref) {
  return DevViewAsAdminNotifier();
});

class DevViewAsAdminNotifier extends StateNotifier<bool> {
  DevViewAsAdminNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kDevViewAsAdminKey) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDevViewAsAdminKey, state);
  }
}

/// 現在のユーザーがコンサルタントかどうか
/// consultant_assignments に consultant_id として登録されている場合 true
/// 開発時: devViewAsConsultantProvider が true なら true
final isConsultantProvider = FutureProvider<bool>((ref) async {
  if (kDebugMode) {
    final devOverride = ref.watch(devViewAsConsultantProvider);
    if (devOverride) return true;
  }

  final uid = Supabase.instance.client.auth.currentUser?.id;
  if (uid == null) return false;

  try {
    final res = await Supabase.instance.client
        .from('consultant_assignments')
        .select('id')
        .eq('consultant_id', uid)
        .limit(1);
    return (res as List).isNotEmpty;
  } catch (_) {
    return false;
  }
});

/// 現在のユーザーが管理者かどうか
/// 本番では JWT claim app_role=admin で判定（将来実装）
/// 開発時: devViewAsAdminProvider が true なら true
final isAdminProvider = Provider<bool>((ref) {
  if (kDebugMode) {
    final devOverride = ref.watch(devViewAsAdminProvider);
    if (devOverride) return true;
  }
  // TODO: auth.jwt()->>'app_role' = 'admin'
  return false;
});
