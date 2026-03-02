import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/voice_submission.dart';
import '../services/analytics_service.dart';
import '../services/voice_submission_service.dart';
import '../providers/auth_provider.dart';
import '../providers/daily_report_status_provider.dart';
import '../theme/engrowth_theme.dart';
import '../widgets/submission/share_boundary_notice.dart';

/// 今日の提出ステータスバナー
class _TodayReportStatusBanner extends ConsumerWidget {
  const _TodayReportStatusBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(dailyReportStatusProvider);
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return const SizedBox.shrink();

    return statusAsync.when(
      data: (state) {
        final (label, color) = _statusLabel(state.status);
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.today, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                '今日の報告: $label',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  (String, Color) _statusLabel(DailyReportStatus status) {
    switch (status) {
      case DailyReportStatus.notStarted:
        return ('未報告', EngrowthColors.primary);
      case DailyReportStatus.recorded:
        return ('録音済み', Colors.orange);
      case DailyReportStatus.submitted:
        return ('提出済み', Colors.teal);
      case DailyReportStatus.reviewed:
        return ('完了', EngrowthColors.success);
    }
  }
}

/// マイ録音履歴画面
/// 練習 / 提出済み タブ、ステータス表示、再生、提出遷移
class RecordingHistoryScreen extends ConsumerStatefulWidget {
  final String? initialTab;

  const RecordingHistoryScreen({super.key, this.initialTab});

  @override
  ConsumerState<RecordingHistoryScreen> createState() =>
      _RecordingHistoryScreenState();
}

class _RecordingHistoryScreenState extends ConsumerState<RecordingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final VoiceSubmissionService _submissionService = VoiceSubmissionService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<VoiceSubmission> _practice = [];
  List<VoiceSubmission> _submitted = [];
  bool _loading = true;
  final Map<String, String?> _contextLabels = {};

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTab == 'submitted' ? 1 : 0;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    _loadSubmissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadSubmissions() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      setState(() {
        _practice = [];
        _submitted = [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);
    try {
      final list = await _submissionService.getUserSubmissions(userId: userId);
      final labels = <String, String?>{};
      for (final s in list) {
        final label = await _submissionService.getSubmissionContextLabel(s);
        labels[s.id] = label;
      }
      if (mounted) {
        setState(() {
          _practice = list.where((s) => s.submissionType == 'practice').toList();
          _submitted = list.where((s) => s.submissionType == 'submitted').toList();
          _contextLabels.clear();
          _contextLabels.addAll(labels);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _practice = [];
          _submitted = [];
          _loading = false;
        });
      }
    }
  }

  Future<void> _playAudio(VoiceSubmission s) async {
    try {
      final url = await _submissionService.getSignedPlaybackUrl(s.audioUrl);
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final userId = ref.watch(currentUserIdProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            HapticFeedback.selectionClick();
            context.pop();
          },
          tooltip: '戻る',
        ),
        title: const Text('マイ録音履歴'),
        actions: [
          if (userId != null)
            IconButton(
              icon: const Icon(Icons.contact_support_outlined),
              tooltip: '担当コンサルに連絡',
              onPressed: () => context.push('/consultant-contact'),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '練習'),
            Tab(text: '提出済み'),
          ],
        ),
      ),
      body: Column(
        children: [
          const _TodayReportStatusBanner(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: ShareBoundaryNotice(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(_practice, 'practice'),
                _buildTabContent(_submitted, 'submitted'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(List<VoiceSubmission> list, String type) {
    final userId = ref.read(currentUserIdProvider);

    Widget child;
    if (_loading) {
      child = const Center(child: CircularProgressIndicator());
    } else if (userId == null) {
      child = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'アカウントを作成すると録音履歴が保存されます',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.push('/account'),
                child: const Text('アカウント作成'),
              ),
            ],
          ),
        ),
      );
    } else if (list.isEmpty) {
      child = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic_none_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              type == 'practice'
                  ? '練習録音はまだありません'
                  : '提出済みの録音はまだありません',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            if (type == 'practice') ...[
              const SizedBox(height: 8),
              Text(
                '会話トレーニングや例文学習で録音するとここに表示されます',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ],
        ),
      );
    } else {
      child = ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final s = list[index];
          return _RecordingCard(
            submission: s,
            contextLabel: _contextLabels[s.id],
            onPlay: () => _playAudio(s),
            showSubmitButton: type == 'practice',
            onSubmitted: () {
              ref.invalidate(dailyReportStatusProvider);
              _tabController.animateTo(1);
              _loadSubmissions();
            },
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSubmissions,
      child: child is ListView
          ? child
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 200,
                ),
                child: child,
              ),
            ),
    );
  }
}

class _RecordingCard extends StatelessWidget {
  final VoiceSubmission submission;
  final String? contextLabel;
  final VoidCallback onPlay;
  final bool showSubmitButton;
  final VoidCallback? onSubmitted;

  const _RecordingCard({
    required this.submission,
    this.contextLabel,
    required this.onPlay,
    required this.showSubmitButton,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton.filled(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onPlay();
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(submission.createdAt),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (contextLabel != null && contextLabel!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          contextLabel!,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      _buildStatusChip(context),
                    ],
                  ),
                ),
              ],
            ),
            if (showSubmitButton) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _showSubmitConfirm(context, submission, onSubmitted);
                  },
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('コンサルタントに提出'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    String label;
    Color? bgColor;

    if (submission.submissionType == 'submitted') {
      if (submission.reviewStatus == 'reviewed') {
        label = 'フィードバック済';
        bgColor = Colors.green.withOpacity(0.2);
      } else {
        label = '提出済み';
        bgColor = colorScheme.primary.withOpacity(0.15);
      }
    } else {
      label = '未提出';
      bgColor = colorScheme.surfaceContainerHighest;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'たった今';
    if (diff.inHours < 1) return '${diff.inMinutes}分前';
    if (diff.inDays < 1) return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showSubmitConfirm(
    BuildContext context,
    VoiceSubmission submission,
    VoidCallback? onSubmitted,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('今日の報告を送る'),
        content: const Text(
          'この録音を担当コンサルタントに共有します。\n'
          '提出後も取り消すことはできません。送信しますか？',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await VoiceSubmissionService().markAsSubmitted(submission.id);
                AnalyticsService().logSubmissionCtaTap(
                      surface: 'recording_history',
                      submissionId: submission.id,
                    );
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('提出しました！アドバイスをお待ちください。'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  onSubmitted?.call();
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text('送信エラー: $e'),
                      action: SnackBarAction(
                        label: '再試行',
                        onPressed: () {
                          _showSubmitConfirm(ctx, submission, onSubmitted);
                        },
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('送信'),
          ),
        ],
      ),
    );
  }
}
