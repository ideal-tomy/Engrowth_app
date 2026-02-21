import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/tts_service.dart';
import '../services/recording_service.dart';
import '../services/voice_submission_service.dart';
import '../services/recording_consent_service.dart';
import '../services/analytics_service.dart';
import 'recording_waveform.dart';

/// 音声操作コントロール
/// 学習画面下部に配置。録音→アップロード→先生に送る 対応
/// 例文学習・会話トレーニング両方で使用
class AudioControls extends StatefulWidget {
  final String englishText;
  final String japaneseText;
  final String? sentenceId;
  final String? sessionId;
  final String? conversationId;
  final String? utteranceId;
  /// 会話画面用のダークテーマ（背景が暗い場合 true）
  final bool useDarkTheme;
  /// 日本語ボタンを非表示（日本人学習者向け会話画面では不要）
  final bool hideJapaneseButton;
  /// 会話モード時：英語ボタンで全文再生+トランスクリプト表示のコールバック
  final VoidCallback? onPlayFullEnglish;
  /// 会話モード時：録音完了時のコールバック（自動進行用）
  final VoidCallback? onRecordingComplete;
  /// 録音完了後のSnackBarメッセージ（例文学習向けに簡潔な案内を指定可能）
  final String? recordingCompleteMessage;

  const AudioControls({
    super.key,
    required this.englishText,
    required this.japaneseText,
    this.sentenceId,
    this.sessionId,
    this.conversationId,
    this.utteranceId,
    this.useDarkTheme = false,
    this.hideJapaneseButton = false,
    this.onPlayFullEnglish,
    this.onRecordingComplete,
    this.recordingCompleteMessage,
  });

  @override
  State<AudioControls> createState() => _AudioControlsState();
}

class _AudioControlsState extends State<AudioControls> {
  final TtsService _ttsService = TtsService();
  final RecordingService _recordingService = RecordingService();
  final VoiceSubmissionService _submissionService = VoiceSubmissionService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isRecording = false;
  bool _hasRecording = false;
  bool _isUploading = false;
  bool _isSubmitting = false;
  String? _lastSubmissionId;

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted && state.processingState == ProcessingState.completed) {
        setState(() => _isPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    _ttsService.dispose();
    _recordingService.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playEnglish() async {
    if (widget.onPlayFullEnglish != null) {
      widget.onPlayFullEnglish!();
      return;
    }
    if (_isPlaying) {
      await _ttsService.stop();
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
      return;
    }
    setState(() => _isPlaying = true);
    await _ttsService.speakEnglish(widget.englishText);
    if (mounted) setState(() => _isPlaying = false);
  }

  Future<void> _playEnglishSlow() async {
    if (_isPlaying) {
      await _ttsService.stop();
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
      return;
    }
    setState(() => _isPlaying = true);
    await _ttsService.speakEnglishSlow(widget.englishText);
    if (mounted) setState(() => _isPlaying = false);
  }

  Future<void> _playJapanese() async {
    if (_isPlaying) {
      await _ttsService.stop();
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
      return;
    }
    setState(() => _isPlaying = true);
    await _ttsService.speakJapanese(widget.japaneseText);
    if (mounted) setState(() => _isPlaying = false);
  }

  Future<void> _checkConsentAndRecord() async {
    final hasConsent = await RecordingConsentService.hasConsent();
    if (!hasConsent && mounted) {
      final ok = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('音声の記録について'),
          content: const Text(
            '学習効率向上のため、練習中の音声は記録されます。\n'
            '納得のいく録音を「先生に送る」で講師に添削依頼できます。',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('同意する'),
            ),
          ],
        ),
      );
      if (ok == true) {
        await RecordingConsentService.setConsent(true);
      } else {
        return;
      }
    }
    await _toggleRecording();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recordingService.stopRecording();
      setState(() {
        _isRecording = false;
        _hasRecording = path != null;
      });
      HapticFeedback.mediumImpact();

      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          final userId = Supabase.instance.client.auth.currentUser?.id;
          final sessionId = widget.sessionId ?? DateTime.now().millisecondsSinceEpoch.toString();
          if (userId != null) {
            setState(() => _isUploading = true);
            try {
              final submission = await _submissionService.uploadAsPractice(
                audioFile: file,
                sessionId: sessionId,
                sentenceId: widget.sentenceId,
                conversationId: widget.conversationId,
                utteranceId: widget.utteranceId,
              );
              if (mounted && submission != null) {
                _lastSubmissionId = submission.id;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.recordingCompleteMessage ??
                          '練習として保存しました。聴き直して「先生に送る」で提出できます。',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('アップロードに失敗しました: $e'), duration: const Duration(seconds: 3)),
                );
              }
            }
            if (mounted) setState(() => _isUploading = false);
          }
        }
        widget.onRecordingComplete?.call();
      }
    } else {
      try {
        await _recordingService.startRecording();
        setState(() {
          _isRecording = true;
          _hasRecording = false;
          _lastSubmissionId = null;
        });
        HapticFeedback.lightImpact();
      } catch (e) {
        if (mounted) {
          // 録音エラーはログインとは無関係（マイク権限・プラットフォームが主因）
          String msg;
          if (e.toString().contains('Permission') || e.toString().contains('権限')) {
            msg = 'マイクの使用許可をください（設定アプリから）';
          } else if (e.toString().contains('not supported') || e.toString().contains('未対応') || e.toString().contains('web') || e.toString().contains('desktop')) {
            msg = 'この環境では録音未対応です。スマホ実機でお試しください';
          } else {
            msg = '録音エラー（ログイン不要。マイク権限・実機実行をご確認ください）: $e';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
          );
        }
      }
    }
  }

  Future<void> _playRecording() async {
    final path = _recordingService.recordingPath;
    if (path == null || !_hasRecording) return;

    final file = File(path);
    if (!await file.exists()) return;

    try {
      await _ttsService.stop();
      setState(() => _isPlaying = true);
      await _audioPlayer.setFilePath(path);
      await _audioPlayer.play();
    } catch (e) {
      if (mounted) {
        setState(() => _isPlaying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('再生エラー: $e'), duration: const Duration(seconds: 2)),
        );
      }
    }
  }

  Future<void> _submitToTeacher() async {
    if (_lastSubmissionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('先に録音を保存してください（ログインが必要です）'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _submissionService.markAsSubmitted(_lastSubmissionId!);
      AnalyticsService().logVoiceSubmit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('先生に送りました！アドバイスをお待ちください。'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          _hasRecording = false;
          _lastSubmissionId = null;
          _recordingService.deleteRecording();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('送信エラー: $e'), duration: const Duration(seconds: 2)),
        );
      }
    }
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.useDarkTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.4) : Colors.grey[50],
        border: Border(top: BorderSide(color: isDark ? Colors.white24 : Colors.grey[300]!)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAudioButton(icon: Icons.volume_up, label: '英語', onPressed: _playEnglish, isActive: _isPlaying),
              _buildAudioButton(icon: Icons.slow_motion_video, label: 'ゆっくり', onPressed: _playEnglishSlow, isActive: _isPlaying),
              if (!widget.hideJapaneseButton)
                _buildAudioButton(icon: Icons.translate, label: '日本語', onPressed: _playJapanese, isActive: _isPlaying),
              _buildRecordButton(),
              _buildAudioButton(
                icon: Icons.play_circle_outline,
                label: '聴き直す',
                onPressed: _hasRecording ? _playRecording : null,
                isActive: _isPlaying,
                isEnabled: _hasRecording,
              ),
            ],
          ),
          if (_hasRecording && (_lastSubmissionId != null || Supabase.instance.client.auth.currentUser != null)) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _submitToTeacher,
                icon: _isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send, size: 18),
                label: Text(_isSubmitting ? '送信中...' : '先生に送る'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton.icon(
          onPressed: _isUploading ? null : _checkConsentAndRecord,
          icon: _isUploading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : _isRecording
                  ? RecordingWaveform(isActive: true, size: 20, color: Colors.red)
                  : Icon(Icons.mic, size: 18, color: _isRecording ? Colors.red : null),
          label: Text(
            _isUploading ? '保存中' : _isRecording ? '停止' : '録音',
            style: TextStyle(
              fontSize: 11,
              color: _isRecording ? Colors.red : (widget.useDarkTheme ? Colors.white70 : null),
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            minimumSize: const Size(0, 40),
            foregroundColor: widget.useDarkTheme ? Colors.white70 : null,
            side: BorderSide(color: widget.useDarkTheme ? Colors.white38 : Colors.grey[400]!),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isActive = false,
    bool isEnabled = true,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton.icon(
          onPressed: isEnabled ? onPressed : null,
          icon: isActive
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(icon, size: 18),
          label: Text(
            label,
            style: TextStyle(fontSize: 11, color: widget.useDarkTheme ? Colors.white70 : null),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            minimumSize: const Size(0, 40),
            foregroundColor: widget.useDarkTheme ? Colors.white70 : null,
            side: BorderSide(color: widget.useDarkTheme ? Colors.white38 : Colors.grey[400]!),
          ),
        ),
      ),
    );
  }
}
