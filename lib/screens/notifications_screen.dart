import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/notification_item.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../theme/engrowth_theme.dart';

/// 通知一覧ページ - 未読/既読管理と遷移アクション
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onNotificationTap(NotificationItem n) async {
    if (!n.isRead) {
      final service = ref.read(notificationServiceProvider);
      await service.markAsRead(n.id);
      ref.invalidate(userNotificationsProvider);
      ref.invalidate(unreadNotificationCountProvider);
    }
    _navigateByType(n);
  }

  void _navigateByType(NotificationItem n) {
    switch (n.type) {
      case 'feedback_received':
      case 'submission_received':
        if (n.relatedId != null) {
          context.push('/recordings?tab=submitted&highlight=${n.relatedId}');
        } else {
          context.push('/recordings?tab=submitted');
        }
        break;
      case 'assignment':
        if (n.relatedId != null) {
          context.push('/recordings?highlight=${n.relatedId}');
        } else {
          context.push('/recordings');
        }
        break;
      case 'daily_summary':
        context.push('/progress');
        break;
      case 'mission':
        context.push('/study');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          tooltip: '戻る',
        ),
        title: const Text('通知'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final countAsync = ref.watch(unreadNotificationCountProvider);
              return countAsync.when(
                data: (count) {
                  if (count == 0) return const SizedBox.shrink();
                  return TextButton(
                    onPressed: () async {
                      final userId = ref.read(currentUserIdProvider);
                      if (userId != null) {
                        await ref.read(notificationServiceProvider).markAllAsRead(userId);
                        ref.invalidate(userNotificationsProvider);
                        ref.invalidate(unreadNotificationCountProvider);
                      }
                    },
                    child: const Text('すべて既読'),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'すべて'),
            Tab(text: '未読'),
            Tab(text: '既読'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(ref.watch(userNotificationsProvider(null))),
          _buildList(ref.watch(userNotificationsProvider('unread'))),
          _buildList(ref.watch(userNotificationsProvider('read'))),
        ],
      ),
    );
  }

  Widget _buildList(AsyncValue<List<NotificationItem>> asyncList) {
    return asyncList.when(
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  '通知はありません',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userNotificationsProvider);
            ref.invalidate(unreadNotificationCountProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final n = list[index];
              return _NotificationCard(
                notification: n,
                onTap: () => _onNotificationTap(n),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '通知の取得に失敗しました: $e',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? colorScheme.surface
                  : colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: notification.isRead
                    ? colorScheme.outlineVariant
                    : colorScheme.primary.withOpacity(0.3),
              ),
              boxShadow: Theme.of(context).brightness == Brightness.dark
                  ? null
                  : EngrowthShadows.softCard,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _iconForType(notification.type),
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              notification.isRead ? FontWeight.w500 : FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(notification.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'feedback_received':
      case 'submission_received':
        return Icons.mic;
      case 'assignment':
        return Icons.assignment;
      case 'daily_summary':
        return Icons.summarize;
      case 'mission':
        return Icons.flag;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}分前';
    if (diff.inHours < 24) return '${diff.inHours}時間前';
    return '${dt.month}/${dt.day}';
  }
}
