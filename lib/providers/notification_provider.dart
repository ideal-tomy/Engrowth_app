import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart';
import 'auth_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final userNotificationsProvider =
    FutureProvider.family<List<NotificationItem>, String?>((ref, filter) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  final service = ref.watch(notificationServiceProvider);
  return service.getNotifications(userId: userId, filter: filter);
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return 0;
  final service = ref.watch(notificationServiceProvider);
  return service.getUnreadCount(userId);
});
