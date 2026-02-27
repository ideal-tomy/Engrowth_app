import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/voice_submission.dart';
import '../models/feedback_template.dart';
import '../services/consultant_dashboard_service.dart';
import '../services/voice_submission_service.dart';
import '../providers/coach_provider.dart';
import '../widgets/consultant/submission_detail_drawer.dart';
import '../widgets/dashboard/readable_tab_bar.dart';

/// コンサルタント用ダッシュボード
/// 2層構造: 主導線（提出キュー + クイック操作）、詳細（ドロワー）
class ConsultantDashboardScreen extends ConsumerStatefulWidget {
  const ConsultantDashboardScreen({super.key});

  @override
  ConsumerState<ConsultantDashboardScreen> createState() => _ConsultantDashboardScreenState();
}

class _ConsultantDashboardScreenState extends ConsumerState<ConsultantDashboardScreen>
    with SingleTickerProviderStateMixin {
  final ConsultantDashboardService _dashboardService = ConsultantDashboardService();
  final VoiceSubmissionService _submissionService = VoiceSubmissionService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<VoiceSubmission> _submissions = [];
  Map<String, int> _kpis = {};
  bool _loading = true;
  String? _error;
  final Map<String, TextEditingController> _feedbackControllers = {};
  final Map<String, bool> _submitting = {};
  Map<String, dynamic>? _learningStats;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _tabController.dispose();
    for (final c in _feedbackControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final kpis = await _dashboardService.getKpis();
      final list = await _dashboardService.getSubmittedQueue();
      await _loadLearningStats();

      for (final s in list) {
        _feedbackControllers[s.id] ??= TextEditingController();
      }

      if (mounted) {
        setState(() {
          _kpis = kpis;
          _submissions = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadLearningStats() async {
    try {
      final response = await Supabase.instance.client
          .from('conversation_learning_events')
          .select('event_type, role');

      final events = response as List;
      int listenCompleted = 0;
      int roleACompleted = 0;
      int roleBCompleted = 0;
      int autoAdvanceUsed = 0;
      int manualNextUsed = 0;

      for (final e in events) {
        final map = e as Map<String, dynamic>;
        final type = map['event_type'] as String?;
        final role = map['role'] as String?;
        switch (type) {
          case 'listen_completed':
            listenCompleted++;
            break;
          case 'role_completed':
            if (role == 'A') roleACompleted++;
            else if (role == 'B') roleBCompleted++;
            break;
          case 'auto_advance_used':
            autoAdvanceUsed++;
            break;
          case 'manual_next_used':
            manualNextUsed++;
            break;
        }
      }

      if (mounted) {
        setState(() {
          _learningStats = {
            'listen_completed': listenCompleted,
            'role_a_completed': roleACompleted,
            'role_b_completed': roleBCompleted,
            'auto_advance_used': autoAdvanceUsed,
            'manual_next_used': manualNextUsed,
          };
        });
      }
    } catch (_) {
      // テーブル未作成時等は無視
    }
  }

  Future<void> _playAudio(VoiceSubmission s) async {
    try {
      final url = await _dashboardService.getPlaybackUrl(s.audioUrl);
      if (url == null) return;
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('再生エラー: $e')),
        );
      }
    }
  }

  void _openDetailDrawer(VoiceSubmission s) {
    HapticFeedback.selectionClick();
    _dashboardService.getSubmissionDetail(s).then((detail) {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (ctx) => DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.25,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) => SubmissionDetailDrawer(
              submission: s,
              detail: detail,
              scrollController: scrollController,
            ),
        ),
      );
    });
  }

  Future<void> _submitFeedback(VoiceSubmission s) async {
    final controller = _feedbackControllers[s.id];
    final message = controller?.text.trim() ?? '';
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('フィードバックを入力してください')),
      );
      return;
    }

    setState(() => _submitting[s.id] = true);

    try {
      await Supabase.instance.client.from('voice_feedbacks').insert({
        'voice_submission_id': s.id,
        'client_message': message,
      });
      await Supabase.instance.client
          .from('voice_submissions')
          .update({
            'review_status': 'reviewed',
            'reviewed_at': DateTime.now().toIso8601String(),
            'consultant_id': Supabase.instance.client.auth.currentUser?.id,
          })
          .eq('id', s.id);

      controller?.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('フィードバックを送信しました'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('送信エラー: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting[s.id] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('コンサルタント'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadData,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReadableTabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '提出キュー'),
              Tab(text: '課題発行'),
            ],
          ),
          Expanded(
            child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: 16),
                        Text('エラー: $_error', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _loadData,
                          child: const Text('再試行'),
                        ),
                      ],
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildQueueTab(),
                    _buildMissionTab(),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  /// サンプル表示用のダミー提出（何ができるか把握できるようにする）
  List<VoiceSubmission> get _displaySubmissions {
    if (_submissions.isNotEmpty) return _submissions;
    return _dummySubmissions;
  }

  bool get _isShowingDummy => _submissions.isEmpty;

  static List<VoiceSubmission> get _dummySubmissions => [
        VoiceSubmission(
          id: 'dummy-1',
          userId: '00000000-0000-0000-0000-000000000001',
          audioUrl: '/dummy/1.m4a',
          submissionType: 'submitted',
          reviewStatus: 'pending',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        VoiceSubmission(
          id: 'dummy-2',
          userId: '00000000-0000-0000-0000-000000000002',
          audioUrl: '/dummy/2.m4a',
          submissionType: 'submitted',
          reviewStatus: 'reviewed',
          reviewedAt: DateTime.now().subtract(const Duration(days: 1)),
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  Widget _buildMissionTab() {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment_outlined, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '課題発行でできること',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _missionRow('3分会話をフルで録音して1本提出'),
                  _missionRow('A役を3回提出'),
                  _missionRow('指定ストーリーの音声提出'),
                  const SizedBox(height: 8),
                  Text(
                    '担当クライアントを選択し、プリセットまたは自由文で課題を送信できます。',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'プリセット選択・送信UIは実装準備中です。',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _missionRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('・ ', style: TextStyle(fontSize: 14)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildQueueTab() {
    final showDummy = _isShowingDummy;
    final kpis = showDummy && (_kpis['pending'] == 0 && _kpis['today_reviewed'] == 0)
        ? {'pending': 2, 'today_reviewed': 1, 'assigned_clients': 3}
        : _kpis;
    final stats = showDummy && (_learningStats == null || _isStatsEmpty)
        ? {
            'listen_completed': 5,
            'role_a_completed': 3,
            'role_b_completed': 2,
            'auto_advance_used': 4,
            'manual_next_used': 1,
          }
        : _learningStats;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (showDummy)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.visibility, size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'サンプル表示：実際のデータがなくても操作イメージを確認できます',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),
        _buildKpiCard(kpis),
        if (stats != null && !_isStatsEmptyFor(stats)) _buildLearningStatsCardFrom(stats),
        ...List.generate(
          _displaySubmissions.length,
          (i) => _buildSubmissionCard(_displaySubmissions[i], isDummy: _displaySubmissions[i].id.startsWith('dummy')),
        ),
      ],
    );
  }

  bool _isStatsEmptyFor(Map<String, dynamic> s) {
    return (s['listen_completed'] as int? ?? 0) == 0 &&
        (s['role_a_completed'] as int? ?? 0) == 0 &&
        (s['role_b_completed'] as int? ?? 0) == 0;
  }

  Widget _buildKpiCard(Map<String, int> kpis) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _kpiItem('未対応', '${kpis['pending'] ?? 0}', colorScheme.error),
            _kpiItem('本日対応', '${kpis['today_reviewed'] ?? 0}', colorScheme.primary),
            _kpiItem('担当', '${kpis['assigned_clients'] ?? 0}', colorScheme.tertiary),
          ],
        ),
      ),
    );
  }

  Widget _kpiItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  bool get _isStatsEmpty {
    if (_learningStats == null) return true;
    return (_learningStats!['listen_completed'] as int? ?? 0) == 0 &&
        (_learningStats!['role_a_completed'] as int? ?? 0) == 0 &&
        (_learningStats!['role_b_completed'] as int? ?? 0) == 0;
  }

  Widget _buildLearningStatsCardFrom(Map<String, dynamic> stats) {
    final colorScheme = Theme.of(context).colorScheme;
    final listenCount = stats['listen_completed'] as int? ?? 0;
    final roleA = stats['role_a_completed'] as int? ?? 0;
    final roleB = stats['role_b_completed'] as int? ?? 0;
    final autoAdv = stats['auto_advance_used'] as int? ?? 0;
    final manual = stats['manual_next_used'] as int? ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  '会話学習サマリー',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _statChip('再聴取', listenCount),
                _statChip('A役完了', roleA),
                _statChip('B役完了', roleB),
                _statChip('自動進行', autoAdv),
                _statChip('手動次へ', manual),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, int count) {
    return Chip(
      label: Text('$label: $count'),
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
    );
  }

  Widget _buildSubmissionCard(VoiceSubmission s, {bool isDummy = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isReviewed = s.reviewStatus == 'reviewed';
    final controller = _feedbackControllers[s.id] ??= TextEditingController();
    final isSubmitting = _submitting[s.id] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDummy)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Chip(
                  label: const Text('サンプル', style: TextStyle(fontSize: 11)),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primary.withOpacity(0.2),
                  child: Text(
                    s.userId.length >= 2 ? s.userId.substring(0, 2).toUpperCase() : '??',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDummy ? 'サンプルユーザー A' : 'ユーザー: ${s.userId.substring(0, 8)}...',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatDate(s.createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (!isDummy)
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _openDetailDrawer(s),
                    tooltip: '詳細ログ',
                  ),
                if (!isReviewed && !isDummy)
                  IconButton.filled(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => _playAudio(s),
                  ),
                if (isReviewed || isDummy)
                  Chip(
                    label: Text(isReviewed ? '対応済み' : '未対応（サンプル）'),
                    backgroundColor: isReviewed ? Colors.green[100] : colorScheme.surfaceContainerHighest,
                  ),
              ],
            ),
            if (!isReviewed && !isDummy) ...[
              const SizedBox(height: 12),
              _QuickFeedbackTemplates(
                onSelect: (text) {
                  controller.text = text;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'フィードバック（クライアントへ）',
                  hintText: '励ましや具体的な添削を入力...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isSubmitting ? null : () => _submitFeedback(s),
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send, size: 18),
                  label: Text(isSubmitting ? '送信中...' : 'フィードバックを送信'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
            if (isDummy && !isReviewed)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '実際の提出があると、ここに再生・テンプレ・フィードバック入力が表示されます。',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'たった今';
    if (diff.inHours < 1) return '${diff.inMinutes}分前';
    if (diff.inDays < 1) return '${diff.inHours}時間前';
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// クイック返信テンプレート（1タップで挿入）
class _QuickFeedbackTemplates extends ConsumerWidget {
  final void Function(String text) onSelect;

  const _QuickFeedbackTemplates({required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(feedbackTemplatesProvider);
    return async.when(
      data: (templates) {
        if (templates.isEmpty) return const SizedBox.shrink();
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: templates.map((t) {
            return ActionChip(
              label: Text(t.name, style: const TextStyle(fontSize: 12)),
              onPressed: () => onSelect(t.content),
            );
          }).toList(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
