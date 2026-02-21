import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/voice_submission.dart';
import '../models/feedback_template.dart';
import '../services/voice_submission_service.dart';
import '../providers/coach_provider.dart';
import '../theme/engrowth_theme.dart';

/// コンサルタント用ダッシュボード
/// 提出された音声の一覧・再生・フィードバック入力
class ConsultantDashboardScreen extends ConsumerStatefulWidget {
  const ConsultantDashboardScreen({super.key});

  @override
  ConsumerState<ConsultantDashboardScreen> createState() => _ConsultantDashboardScreenState();
}

class _ConsultantDashboardScreenState extends ConsumerState<ConsultantDashboardScreen> {
  final VoiceSubmissionService _submissionService = VoiceSubmissionService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<VoiceSubmission> _submissions = [];
  bool _loading = true;
  String? _error;
  final Map<String, TextEditingController> _feedbackControllers = {};
  final Map<String, bool> _submitting = {};
  Map<String, dynamic>? _learningStats;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
    _loadLearningStats();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    for (final c in _feedbackControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSubmissions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await Supabase.instance.client
          .from('voice_submissions')
          .select()
          .eq('submission_type', 'submitted')
          .order('created_at', ascending: false);

      final list = (response as List)
          .map((e) => VoiceSubmission.fromJson(e as Map<String, dynamic>))
          .toList();

      for (final s in list) {
        _feedbackControllers[s.id] ??= TextEditingController();
      }

      if (mounted) {
        setState(() {
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
        _loadSubmissions();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('コンサルタントダッシュボード'),
        backgroundColor: EngrowthColors.primary,
        foregroundColor: EngrowthColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading
            ? null
            : () async {
                await _loadSubmissions();
                _loadLearningStats();
              },
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
                        Icon(Icons.error_outline, size: 64, color: EngrowthColors.error),
                        const SizedBox(height: 16),
                        Text('エラー: $_error', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _loadSubmissions,
                          child: const Text('再試行'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildBody(),
    );
  }

  Widget _buildBody() {
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
        if (_learningStats != null && !_isStatsEmpty) _buildLearningStatsCard(),
        if (_submissions.isNotEmpty)
          ...List.generate(
            _submissions.length,
            (i) => _buildSubmissionCard(_submissions[i]),
          )
        else
          Center(
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
                Icon(Icons.analytics, color: EngrowthColors.primary),
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
      backgroundColor: EngrowthColors.primary.withOpacity(0.1),
    );
  }

  Widget _buildSubmissionCard(VoiceSubmission s) {
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
                  backgroundColor: EngrowthColors.primary.withOpacity(0.2),
                  child: Text(
                    s.userId.substring(0, 2).toUpperCase(),
                    style: const TextStyle(
                      color: EngrowthColors.primary,
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
                    backgroundColor: EngrowthColors.primary,
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
