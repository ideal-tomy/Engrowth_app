import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/admin_permissions_provider.dart';
import '../services/admin_audit_service.dart';
import '../services/mission_delivery_demo_service.dart';
import '../providers/analytics_provider.dart';
import '../providers/role_provider.dart';
import '../services/admin_permission_service.dart';
import '../theme/engrowth_theme.dart';
import '../widgets/dashboard/readable_tab_bar.dart';

/// 管理者ダッシュボード
/// 権限付与・監査ログ・運用監視・AI要約承認
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasLoggedAdminView = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      animationDuration: EngrowthElementTokens.switchDuration,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('管理者ダッシュボード')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                '管理者権限が必要です',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    if (!_hasLoggedAdminView) {
      _hasLoggedAdminView = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(analyticsServiceProvider).logAdminDashboardViewed();
      });
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('管理者'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReadableTabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '権限付与'),
              Tab(text: '監査'),
              Tab(text: '運用'),
              Tab(text: 'AI承認'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PermissionGrantPanel(),
                _AuditLogPanel(),
                _OpsMetricsPanel(),
                _AiInsightsApprovalPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionGrantPanel extends ConsumerWidget {
  static Widget _buildPhaseNote(ColorScheme colorScheme, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final async = ref.watch(consultantSummariesProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => _showGrantDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('権限を追加'),
        ),
        const SizedBox(height: 16),
        async.when(
          data: (summaries) {
            if (summaries.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '担当割当がありません。権限を追加してください。',
                    style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  _buildPhaseNote(
                    colorScheme,
                    'consultant_id と client_id（UUID）を入力して割当を追加できます。',
                  ),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: summaries.entries.map((e) {
                final s = e.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        s.consultantId.length >= 2
                            ? s.consultantId.substring(0, 2).toUpperCase()
                            : '??',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    title: Text(
                      'コンサルタント: ${s.consultantId.substring(0, 8)}...',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('クライアント${s.clientCount}件'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'revoke' && s.assignments.isNotEmpty) {
                          _showRevokeDialog(context, ref, s);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'revoke', child: Text('取り消し')),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          )),
          error: (e, _) => Text(
            '読み込みエラー: $e',
            style: TextStyle(fontSize: 13, color: colorScheme.error),
          ),
        ),
        const SizedBox(height: 16),
        _buildPhaseNote(
          colorScheme,
          'consultant_assignments で担当割当を管理。取り消しは status=inactive に更新。',
        ),
      ],
    );
  }

  void _showGrantDialog(BuildContext context, WidgetRef ref) {
    final consultantController = TextEditingController();
    final clientController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('権限を追加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: consultantController,
              decoration: const InputDecoration(
                labelText: 'consultant_id (UUID)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: clientController,
              decoration: const InputDecoration(
                labelText: 'client_id (UUID)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () async {
              final consultantId = consultantController.text.trim();
              final clientId = clientController.text.trim();
              if (consultantId.isEmpty || clientId.isEmpty) return;

              try {
                await ref.read(adminPermissionServiceProvider).grantAssignment(
                  consultantId: consultantId,
                  clientId: clientId,
                );
                ref.read(analyticsServiceProvider).logAdminPermissionGranted(
                  consultantId: consultantId,
                  clientId: clientId,
                );
                if (ctx.mounted) {
                  ref.invalidate(consultantSummariesProvider);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('権限を追加しました'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('エラー: $e')),
                  );
                }
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  void _showRevokeDialog(
    BuildContext context,
    WidgetRef ref,
    ConsultantAssignmentSummary summary,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('権限を取り消し'),
        content: Text(
          'コンサルタント ${summary.consultantId.substring(0, 8)}... の割当 '
          '${summary.assignments.length}件をすべて取り消しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final service = ref.read(adminPermissionServiceProvider);
              final analytics = ref.read(analyticsServiceProvider);
              for (final a in summary.assignments) {
                await service.revokeAssignment(a.id, a.consultantId, a.clientId);
                analytics.logAdminPermissionRevoked(
                  consultantId: a.consultantId,
                  clientId: a.clientId,
                );
              }
              if (ctx.mounted) {
                ref.invalidate(consultantSummariesProvider);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('権限を取り消しました')),
                );
              }
            },
            child: const Text('取り消し'),
          ),
        ],
      ),
    );
  }
}

class _AuditLogPanel extends ConsumerWidget {
  static Widget _auditRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 72, child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final async = ref.watch(auditLogsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.invalidate(auditLogsProvider);
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('更新'),
              ),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('権限のみ'),
              selected: ref.watch(auditLogFiltersProvider)?.resourceType == 'permission',
              onSelected: (v) {
                ref.read(auditLogFiltersProvider.notifier).state = v
                    ? (resourceType: 'permission', from: null, to: null)
                    : null;
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        async.when(
          data: (logs) {
            if (logs.isEmpty) {
              return Text(
                '監査ログがありません。権限付与・取り消しを行うと記録されます。',
                style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: logs.map((log) {
                final clientId = log.metadata['client_id'] as String?;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _auditRow('実行者', '${log.viewerId.substring(0, 8)}...'),
                        _auditRow('対象', '${log.targetUserId.substring(0, 8)}...'),
                        if (clientId != null) _auditRow('クライアント', '${clientId.substring(0, 8)}...'),
                        _auditRow('日時', _formatAuditDate(log.accessedAt)),
                        _auditRow('種別', log.actionLabel),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Text(
            '読み込みエラー: $e',
            style: TextStyle(fontSize: 13, color: colorScheme.error),
          ),
        ),
      ],
    );
  }

  String _formatAuditDate(DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _DeliveryDemoCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final async = ref.watch(missionDeliveryDemosProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.send_outlined, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '課題配信デモ（LINE / LINE WORKS）',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '連携時に想定される配信状態のイメージです。実API接続は行いません。',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            async.when(
              data: (demos) {
                if (demos.isEmpty) {
                  return Text(
                    '直近の課題がありません。コンサルタントダッシュボードで課題を発行すると表示されます。',
                    style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: demos.take(5).map((d) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.mission.missionText.length > 40
                                ? '${d.mission.missionText.substring(0, 40)}...'
                                : d.mission.missionText,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: d.channelStatuses.map((c) {
                              final stateColor = c.state == DeliveryState.sent
                                  ? Colors.green
                                  : c.state == DeliveryState.failed
                                      ? Colors.red
                                      : c.state == DeliveryState.pending
                                          ? Colors.orange
                                          : Colors.grey;
                              return Chip(
                                label: Text(
                                  '${c.channelLabel}: ${c.stateLabel}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                backgroundColor: stateColor.withOpacity(0.2),
                                side: BorderSide(color: stateColor.withOpacity(0.5)),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text(
                '取得エラー: $e',
                style: TextStyle(fontSize: 13, color: colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpsMetricsPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadOpsMetrics(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? _emptyMetrics();
        final useDummy = (data['pending'] == 0 &&
            data['today_submitted'] == 0 &&
            data['today_reviewed'] == 0);
        final display = useDummy
            ? {
                'pending': 3,
                'today_submitted': 5,
                'today_reviewed': 2,
                'today_missions_issued': 4,
                'consultants_without_mission_today': 1,
              }
            : data;
        final colorScheme = Theme.of(context).colorScheme;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (useDummy)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'サンプル：運用指標の表示イメージです',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '日課提出運用の状況',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '未対応の報告・本日の提出数・本日のレビュー数を把握できます。',
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    _metricRow('未対応の報告', '${display['pending']}件'),
                    _metricRow('本日の提出数', '${display['today_submitted']}件'),
                    _metricRow('本日のレビュー数', '${display['today_reviewed']}件'),
                    _metricRow('本日の課題発行数', '${display['today_missions_issued']}件'),
                    _metricRow('未発行の担当コンサル数', '${display['consultants_without_mission_today']}人'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _DeliveryDemoCard(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '日課提出運用の全体状況を把握できます。'
                      '次フェーズでレビュー遅延アラート・週間継続率を追加予定。',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadOpsMetrics() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      final pendingRes = await Supabase.instance.client
          .from('voice_submissions')
          .select('id, created_at, reviewed_at, review_status')
          .eq('submission_type', 'submitted');
      final rows = pendingRes as List;
      final pending = rows
          .where((r) => (r as Map<String, dynamic>)['review_status'] == 'pending')
          .length;

      int todaySubmitted = 0;
      int todayReviewed = 0;
      for (final r in rows) {
        final map = r as Map<String, dynamic>;
        final createdAt = map['created_at'] as String?;
        if (createdAt != null && createdAt.startsWith(today)) todaySubmitted++;
        final reviewedAt = map['reviewed_at'] as String?;
        if (reviewedAt != null && reviewedAt.startsWith(today)) todayReviewed++;
      }

      int todayMissionsIssued = 0;
      int consultantsWithMissionsToday = 0;
      int totalConsultantsWithClients = 0;
      try {
        final missionRes = await Supabase.instance.client
            .from('coach_missions')
            .select('id, consultant_id')
            .eq('mission_date', today);
        final missionRows = missionRes as List;
        todayMissionsIssued = missionRows.length;
        final issuedConsultantIds = missionRows
            .map((r) => (r as Map<String, dynamic>)['consultant_id'] as String?)
            .where((id) => id != null && id.isNotEmpty)
            .toSet();
        consultantsWithMissionsToday = issuedConsultantIds.length;

        final assignRes = await Supabase.instance.client
            .from('consultant_assignments')
            .select('consultant_id')
            .eq('status', 'active');
        final assignRows = assignRes as List;
        totalConsultantsWithClients = assignRows
            .map((r) => (r as Map<String, dynamic>)['consultant_id'] as String)
            .toSet()
            .length;
      } catch (_) {
        // coach_missions / consultant_assignments が未作成の場合は無視
      }

      return {
        'pending': pending,
        'today_submitted': todaySubmitted,
        'today_reviewed': todayReviewed,
        'today_missions_issued': todayMissionsIssued,
        'consultants_without_mission_today':
            totalConsultantsWithClients - consultantsWithMissionsToday,
      };
    } catch (_) {
      return _emptyMetrics();
    }
  }

  Map<String, dynamic> _emptyMetrics() => {
        'pending': 0,
        'today_submitted': 0,
        'today_reviewed': 0,
        'today_missions_issued': 0,
        'consultants_without_mission_today': 0,
      };

  Widget _metricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _AiInsightsApprovalPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.visibility, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'サンプル：AI要約承認の表示イメージです',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                ),
              ),
            ],
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(label: const Text('draft', style: TextStyle(fontSize: 11))),
                    const SizedBox(width: 8),
                    Text('2025/02/27 の要約', style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'ハイライト: 提出数が先週比+2。要望で「再生速度」が複数件。',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton(onPressed: () {}, child: const Text('承認')),
                    const SizedBox(width: 8),
                    OutlinedButton(onPressed: () {}, child: const Text('却下')),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'daily_ai_insights テーブル導入後、draft の一覧と承認・却下が可能になります。',
          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
