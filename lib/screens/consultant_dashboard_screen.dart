import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/voice_submission.dart';
import '../models/feedback_template.dart';
import '../services/consultant_dashboard_service.dart';
import '../services/voice_submission_service.dart';
import '../providers/analytics_provider.dart';
import '../providers/coach_provider.dart';
import '../widgets/consultant/submission_detail_drawer.dart';
import '../theme/engrowth_theme.dart';
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
  List<String> _assignedClientIds = [];
  String? _selectedClientId;
  int _selectedPresetIndex = 0;
  final TextEditingController _missionTextController = TextEditingController();
  bool _missionIssuing = false;
  Map<String, dynamic>? _lastIssuedMission;
  List<Map<String, dynamic>> _clientReports = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: EngrowthElementTokens.switchDuration,
    );
    _loadData();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _tabController.dispose();
    _missionTextController.dispose();
    for (final c in _feedbackControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  static const _missionPresets = [
    {'text': '今日の報告（音声）を提出', 'route': '/recordings'},
    {'text': '3分会話をフルで録音して1本提出', 'route': '/conversation-training'},
    {'text': 'A役・指定ストーリーの音声提出依頼', 'route': '/library'},
  ];

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final kpis = await _dashboardService.getKpis();
      final list = await _dashboardService.getSubmittedQueue();
      final clientIds = await _dashboardService.getAssignedClientIds();
      List<Map<String, dynamic>> reports = [];
      try {
        reports = await _dashboardService.getClientReports();
      } catch (_) {
        // client_reports テーブル未作成時は無視
      }
      await _loadLearningStats();

      for (final s in list) {
        _feedbackControllers[s.id] ??= TextEditingController();
      }

      if (mounted) {
        setState(() {
          _kpis = kpis;
          _submissions = list;
          _assignedClientIds = clientIds;
          _clientReports = reports;
          _selectedClientId ??= clientIds.isNotEmpty ? clientIds.first : null;
          if (_missionTextController.text.isEmpty &&
              _missionPresets.isNotEmpty) {
            _missionTextController.text = _missionPresets[0]['text'] as String;
          }
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
    _dashboardService.getSubmissionDetail(s).then((detail) async {
      if (!mounted) return;
      final hasSessionData = detail != null && detail['reason'] == null;
      if (detail != null && detail['reason'] != null) {
        ref.read(analyticsServiceProvider).logConsultantDetailError(
          reason: detail['reason'] as String,
          submissionId: s.id,
        );
      }
      ref.read(analyticsServiceProvider).logConsultantDetailOpened(
        submissionId: s.id,
        hasSessionData: hasSessionData,
      );
      await showModalBottomSheet<void>(
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
      if (mounted) {
        ref.read(analyticsServiceProvider).logConsultantDetailClosed(submissionId: s.id);
      }
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
              Tab(text: '今日の報告'),
              Tab(text: '日課運用'),
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
                        '課題を発行',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_assignedClientIds.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '担当クライアントがありません。管理者に割当を依頼してください。',
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: _selectedClientId ?? _assignedClientIds.first,
                      decoration: const InputDecoration(
                        labelText: '担当クライアント',
                        border: OutlineInputBorder(),
                      ),
                      items: _assignedClientIds
                          .map((id) => DropdownMenuItem(
                                value: id,
                                child: Text(
                                  id.length > 12 ? '${id.substring(0, 8)}...' : id,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedClientId = v),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'プリセット',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < _missionPresets.length; i++)
                        FilterChip(
                          label: Text(
                            _missionPresets[i]['text'] as String,
                            style: const TextStyle(fontSize: 12),
                          ),
                          selected: _selectedPresetIndex == i,
                          onSelected: (v) {
                            setState(() {
                              _selectedPresetIndex = i;
                              _missionTextController.text =
                                  _missionPresets[i]['text'] as String;
                            });
                          },
                        ),
                      FilterChip(
                        label: const Text('カスタム', style: TextStyle(fontSize: 12)),
                        selected: _selectedPresetIndex == _missionPresets.length,
                        onSelected: (v) {
                          setState(() {
                            _selectedPresetIndex = _missionPresets.length;
                            _missionTextController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _missionTextController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: '課題文言（プリセット選択で自動入力）',
                      hintText: '例：今日の報告を提出してください',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) {
                      if (_selectedPresetIndex < _missionPresets.length) {
                        setState(() => _selectedPresetIndex = _missionPresets.length);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _missionIssuing || _selectedClientId == null
                          ? null
                          : _issueMission,
                      icon: _missionIssuing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send, size: 18),
                      label: Text(_missionIssuing ? '発行中...' : '課題を発行'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_lastIssuedMission != null) ...[
            const SizedBox(height: 16),
            Card(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          '発行しました',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastIssuedMission!['mission_text'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'クライアント: ${(_lastIssuedMission!['client_id'] as String).substring(0, 8)}...',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.today_outlined, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '日課運用でできること',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _missionRow('今日の報告（音声）のフィードバック'),
                  _missionRow('3分会話をフルで録音して1本提出の依頼'),
                  _missionRow('A役・指定ストーリーの音声提出依頼'),
                  const SizedBox(height: 8),
                  Text(
                    'クライアントの「今日の報告」は提出キューに届きます。'
                    'フィードバックで励ましや具体的な添削を送れます。',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _issueMission() async {
    final clientId = _selectedClientId;
    final text = _missionTextController.text.trim();
    if (clientId == null || text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('クライアントを選択し、課題文言を入力してください')),
      );
      return;
    }

    setState(() => _missionIssuing = true);

    try {
      final route = _selectedPresetIndex < _missionPresets.length
          ? (_missionPresets[_selectedPresetIndex]['route'] as String?)
          : null;
      await ref.read(consultantServiceProvider).createMission(
            clientId: clientId,
            missionText: text,
            actionRoute: route,
          );

      ref.read(analyticsServiceProvider).logMissionIssued(
            clientId: clientId,
            hasPreset: _selectedPresetIndex < _missionPresets.length,
          );

      if (mounted) {
        setState(() {
          _lastIssuedMission = {
            'client_id': clientId,
            'mission_text': text,
          };
          _missionIssuing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('課題を発行しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ref.read(analyticsServiceProvider).logMissionIssueFailed(reason: e.toString());
      if (mounted) {
        setState(() => _missionIssuing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('発行エラー: $e')),
        );
      }
    }
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
        _buildKpiCard(kpis, Theme.of(context).colorScheme),
        if (_clientReports.isNotEmpty) _buildClientReportsCard(Theme.of(context).colorScheme),
        if (stats != null && !_isStatsEmptyFor(stats)) _buildLearningStatsCardFrom(stats),
        ...List.generate(
          _displaySubmissions.length,
          (i) => _buildSubmissionCard(_displaySubmissions[i], isDummy: _displaySubmissions[i].id.startsWith('dummy')),
        ),
      ],
    );
  }

  Widget _buildClientReportsCard(ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.chat_bubble_outline, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'クライアントからの報告',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._clientReports.take(5).map((r) {
              final type = r['report_type'] as String? ?? 'other';
              final reportTypeLabel = _reportTypeLabel(type);
              final msg = r['message'] as String? ?? '';
              final createdAt = r['created_at'] != null
                  ? DateTime.tryParse(r['created_at'] as String)
                  : null;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            reportTypeLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                          if (createdAt != null) ...[
                            const Spacer(),
                            Text(
                              _formatReportDate(createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (msg.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          msg.length > 100 ? '${msg.substring(0, 100)}...' : msg,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _reportTypeLabel(String type) {
    switch (type) {
      case 'today_submitted':
        return '今日の提出報告';
      case 'consultation':
        return '相談';
      case 'question':
        return '質問';
      default:
        return 'その他';
    }
  }

  String _formatReportDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'たった今';
    if (diff.inHours < 1) return '${diff.inMinutes}分前';
    if (diff.inDays < 1) return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    return '${dt.month}/${dt.day}';
  }

  bool _isStatsEmptyFor(Map<String, dynamic> s) {
    return (s['listen_completed'] as int? ?? 0) == 0 &&
        (s['role_a_completed'] as int? ?? 0) == 0 &&
        (s['role_b_completed'] as int? ?? 0) == 0;
  }

  Widget _buildKpiCard(Map<String, int> kpis, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _kpiItem('未対応の報告', '${kpis['pending'] ?? 0}', colorScheme.error),
            _kpiItem('本日対応', '${kpis['today_reviewed'] ?? 0}', colorScheme.primary),
            _kpiItem('担当クライアント', '${kpis['assigned_clients'] ?? 0}', colorScheme.tertiary),
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
            if (!isDummy && _isToday(s.createdAt))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Chip(
                  label: const Text('今日の報告', style: TextStyle(fontSize: 11)),
                  backgroundColor: colorScheme.primaryContainer.withOpacity(0.6),
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

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day;
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
