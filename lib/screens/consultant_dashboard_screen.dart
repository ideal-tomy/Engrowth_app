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
        title: const Text('コンサルタントダッシュボード'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '提出キュー'),
            Tab(text: '課題発行'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadData,
          ),
        ],
      ),
      body: _loading
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
    );
  }

  Widget _buildMissionTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '課題発行',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'プリセット「3分会話をフルで録音して1本提出」等は準備中です。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueTab() {
    if (_submissions.isEmpty && (_learningStats == null || _isStatsEmpty)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '提出された音声はありません',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildKpiCard(),
        if (_learningStats != null && !_isStatsEmpty) _buildLearningStatsCard(),
        if (_submissions.isNotEmpty)
          ...List.generate(
            _submissions.length,
            (i) => _buildSubmissionCard(_submissions[i]),
          )
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '提出された音声はありません',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildKpiCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _kpiItem('未対応', '${_kpis['pending'] ?? 0}', colorScheme.error),
            _kpiItem('本日対応', '${_kpis['today_reviewed'] ?? 0}', colorScheme.primary),
            _kpiItem('担当', '${_kpis['assigned_clients'] ?? 0}', colorScheme.tertiary),
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

  Widget _buildLearningStatsCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final stats = _learningStats!;
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

  Widget _buildSubmissionCard(VoiceSubmission s) {
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
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primary.withOpacity(0.2),
                  child: Text(
                    s.userId.substring(0, 2).toUpperCase(),
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
                        'ユーザー: ${s.userId.substring(0, 8)}...',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatDate(s.createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _openDetailDrawer(s),
                  tooltip: '詳細ログ',
                ),
                if (!isReviewed)
                  IconButton.filled(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => _playAudio(s),
                  ),
                if (isReviewed)
                  Chip(
                    label: const Text('対応済み'),
                    backgroundColor: Colors.green[100],
                  ),
              ],
            ),
            if (!isReviewed) ...[
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
