import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/voice_submission.dart';
import '../services/voice_submission_service.dart';
import '../theme/engrowth_theme.dart';

/// 1ヶ月前 vs 今日の録音を左右並べて聞き比べ
class AudioComparisonPlayer extends ConsumerStatefulWidget {
  const AudioComparisonPlayer({super.key});

  @override
  ConsumerState<AudioComparisonPlayer> createState() => _AudioComparisonPlayerState();
}

class _AudioComparisonPlayerState extends ConsumerState<AudioComparisonPlayer> {
  final VoiceSubmissionService _service = VoiceSubmissionService();
  final AudioPlayer _leftPlayer = AudioPlayer();
  final AudioPlayer _rightPlayer = AudioPlayer();

  VoiceSubmission? _oldSubmission;
  VoiceSubmission? _recentSubmission;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
    _leftPlayer.playerStateStream.listen((s) {
      if (mounted && s.processingState == ProcessingState.completed) {
        setState(() {});
      }
    });
    _rightPlayer.playerStateStream.listen((s) {
      if (mounted && s.processingState == ProcessingState.completed) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _leftPlayer.dispose();
    _rightPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadSubmissions() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() {
        _loading = false;
        _error = 'ログインが必要です';
      });
      return;
    }

    try {
      final all = await _service.getUserSubmissions(userId: userId);
      if (all.isEmpty) {
        if (mounted) setState(() {
          _loading = false;
          _error = 'まだ録音がありません';
        });
        return;
      }

      all.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final oldest = all.first;
      final latest = all.last;
      final old = oldest == latest ? null : oldest;

      if (mounted) setState(() {
        _oldSubmission = old;
        _recentSubmission = latest;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _loading = false;
        _error = '読み込みに失敗しました';
      });
    }
  }

  Future<void> _play(VoiceSubmission s, AudioPlayer player) async {
    if (player.playing) {
      await player.stop();
      if (mounted) setState(() {});
      return;
    }
    await _leftPlayer.stop();
    await _rightPlayer.stop();
    final url = await _service.getSignedPlaybackUrl(s.audioUrl);
    if (url == null) return;
    await player.setUrl(url);
    await player.play();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_error != null) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.mic_none, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Colors.grey[700])),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.compare_arrows, color: EngrowthColors.primary),
                const SizedBox(width: 8),
                const Text(
                  '成長を耳で確認',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '過去 vs 最近の録音',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ComparisonPane(
                    label: _oldSubmission != null ? '過去の録音' : '（複数の録音で比較）',
                    submission: _oldSubmission,
                    player: _leftPlayer,
                    onPlay: _oldSubmission != null ? () => _play(_oldSubmission!, _leftPlayer) : null,
                    service: _service,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.swap_horiz, color: EngrowthColors.primary),
                ),
                Expanded(
                  child: _ComparisonPane(
                    label: '最近の録音',
                    submission: _recentSubmission,
                    player: _rightPlayer,
                    onPlay: _recentSubmission != null ? () => _play(_recentSubmission!, _rightPlayer) : null,
                    service: _service,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonPane extends StatelessWidget {
  final String label;
  final VoiceSubmission? submission;
  final AudioPlayer player;
  final VoidCallback? onPlay;
  final VoiceSubmissionService service;

  const _ComparisonPane({
    required this.label,
    required this.submission,
    required this.player,
    required this.onPlay,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaying = player.playing;

    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 8),
        Material(
          color: EngrowthColors.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onPlay,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isPlaying ? Icons.stop_circle : Icons.play_circle_filled,
                size: 48,
                color: submission != null ? EngrowthColors.primary : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
