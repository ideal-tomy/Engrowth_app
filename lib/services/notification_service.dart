import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_item.dart';

/// 通知サービス
class NotificationService {
  final SupabaseClient _client = Supabase.instance.client;

  /// ユーザーの通知一覧を取得
  /// [filter] null=すべて, 'unread'=未読のみ, 'read'=既読のみ
  Future<List<NotificationItem>> getNotifications({
    required String userId,
    String? filter,
  }) async {
    try {
      var query = _client
          .from('notifications')
          .select()
          .eq('user_id', userId);

      if (filter == 'unread') {
        query = query.isFilter('read_at', null);
      } else if (filter == 'read') {
        query = query.filter('read_at', 'not.is', null);
      }

      final response = await query.order('created_at', ascending: false);
      return (response as List)
          .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('NotificationService.getNotifications: $e');
      return [];
    }
  }

  /// 未読件数
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .isFilter('read_at', null);
      return (response as List).length;
    } catch (e) {
      print('NotificationService.getUnreadCount: $e');
      return 0;
    }
  }

  /// 既読にする
  Future<void> markAsRead(String notificationId) async {
    await _client.from('notifications').update({
      'read_at': DateTime.now().toIso8601String(),
    }).eq('id', notificationId);
  }

  /// 全件既読にする
  Future<void> markAllAsRead(String userId) async {
    await _client
        .from('notifications')
        .update({'read_at': DateTime.now().toIso8601String()})
        .eq('user_id', userId)
        .isFilter('read_at', null);
  }
}
