import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 初回聴き終わりフラグ永続化
/// Speak風ガイドフロー: 初回のみポップアップ→再生ボタン出現、2回目以降は全オプション表示
class FirstListenCompletedService {
  static const _keyPrefix = 'first_listen_completed_';

  String _storageKey(String contentType, String id) =>
      '$_keyPrefix${contentType}_$id';

  Future<bool> isCompleted(String contentType, String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_storageKey(contentType, id)) ?? false;
  }

  Future<void> markCompleted(String contentType, String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKey(contentType, id), true);
  }
}

final firstListenCompletedServiceProvider =
    Provider<FirstListenCompletedService>((ref) {
  return FirstListenCompletedService();
});

/// 指定コンテンツの初回聴き終わり済みかどうか
/// 使用例: ref.watch(firstListenCompletedProvider(('conversation', conversationId)))
final firstListenCompletedProvider =
    FutureProvider.family<bool, (String contentType, String id)>((ref, key) async {
  final service = ref.watch(firstListenCompletedServiceProvider);
  return service.isCompleted(key.$1, key.$2);
});
