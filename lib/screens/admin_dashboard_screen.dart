import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/role_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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

class _PermissionGrantPanel extends StatelessWidget {
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
                  'サンプル：権限付与でできる操作のイメージです',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                ),
              ),
            ],
          ),
        ),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('コンサルタント A'),
            subtitle: const Text('クライアント3件・期間外閲覧可'),
            trailing: PopupMenuButton<String>(
              onSelected: (_) {},
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('編集')),
                const PopupMenuItem(value: 'revoke', child: Text('取り消し')),
              ],
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('コンサルタント B'),
            subtitle: const Text('クライアント1件・期間外閲覧不可'),
            trailing: PopupMenuButton<String>(
              onSelected: (_) {},
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('編集')),
                const PopupMenuItem(value: 'revoke', child: Text('取り消し')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('権限を追加'),
        ),
        const SizedBox(height: 24),
        Text(
          'consultant_client_permissions テーブル導入後、実際の付与・編集が可能になります。',
          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        _buildPhaseNote(
          colorScheme,
          '今できること: 日課提出の運用指標確認、コンサル権限のサンプル表示',
        ),
        const SizedBox(height: 8),
        _buildPhaseNote(
          colorScheme,
          '次フェーズ（DB追加後）: 権限付与・監査ログ・AI要約承認',
        ),
      ],
    );
  }
}

class _AuditLogPanel extends StatelessWidget {
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
                  'サンプル：監査ログの表示イメージです',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                ),
              ),
            ],
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _auditRow('閲覧者', 'コンサルA'),
                _auditRow('対象', 'クライアント X'),
                _auditRow('日時', '2025/02/27 10:30'),
                _auditRow('種別', '提出一覧'),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _auditRow('閲覧者', '管理者'),
                _auditRow('対象', '期間外ログ'),
                _auditRow('日時', '2025/02/26 15:00'),
                _auditRow('種別', 'user_sessions'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'access_audit_logs テーブル導入後、実際の閲覧履歴が記録・表示されます。',
          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _auditRow(String label, String value) {
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
            ? {'pending': 3, 'today_submitted': 5, 'today_reviewed': 2}
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
                  ],
                ),
              ),
            ),
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

      return {
        'pending': pending,
        'today_submitted': todaySubmitted,
        'today_reviewed': todayReviewed,
      };
    } catch (_) {
      return _emptyMetrics();
    }
  }

  Map<String, dynamic> _emptyMetrics() =>
      {'pending': 0, 'today_submitted': 0, 'today_reviewed': 0};

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
