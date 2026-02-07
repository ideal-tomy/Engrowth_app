import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/tts_service.dart';
import '../services/recording_service.dart';

/// 音声操作コントロール
/// 学習画面下部に配置される音声操作ボタン
class AudioControls extends StatefulWidget {
  final String englishText;
  final String japaneseText;

  const AudioControls({
    super.key,
    required this.englishText,
    required this.japaneseText,
  });

  @override
  State<AudioControls> createState() => _AudioControlsState();
}

class _AudioControlsState extends State<AudioControls> {
  final TtsService _ttsService = TtsService();
  final RecordingService _recordingService = RecordingService();
  bool _isPlaying = false;
  bool _isRecording = false;
  bool _hasRecording = false;

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    _recordingService.dispose();
    super.dispose();
  }

  Future<void> _playEnglish() async {
    if (_isPlaying) {
      await _ttsService.stop();
      setState(() => _isPlaying = false);
      return;
    }
    setState(() => _isPlaying = true);
    await _ttsService.speakEnglish(widget.englishText);
    setState(() => _isPlaying = false);
  }

  Future<void> _playEnglishSlow() async {
    if (_isPlaying) {
      await _ttsService.stop();
      setState(() => _isPlaying = false);
      return;
    }
    setState(() => _isPlaying = true);
    await _ttsService.speakEnglishSlow(widget.englishText);
    setState(() => _isPlaying = false);
  }

  Future<void> _playJapanese() async {
    if (_isPlaying) {
      await _ttsService.stop();
      setState(() => _isPlaying = false);
      return;
    }
    setState(() => _isPlaying = true);
    await _ttsService.speakJapanese(widget.japaneseText);
    setState(() => _isPlaying = false);
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _recordingService.stopRecording();
      setState(() {
        _isRecording = false;
        _hasRecording = true;
      });
      HapticFeedback.mediumImpact();
    } else {
      try {
        await _recordingService.startRecording();
        setState(() {
          _isRecording = true;
          _hasRecording = false;
        });
        HapticFeedback.lightImpact();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('録音エラー: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _playRecording() async {
    final path = _recordingService.recordingPath;
    if (path == null || !_hasRecording) return;

    try {
      // 録音ファイルの再生は、将来的にaudio_playerパッケージなどで実装可能
      // 今回は簡易的にファイルの存在確認のみ
      final file = File(path);
      if (await file.exists()) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('録音を再生します（実装予定）'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('再生エラー: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 英語再生（通常）
          _buildAudioButton(
            icon: Icons.volume_up,
            label: '英語',
            onPressed: _playEnglish,
            isActive: _isPlaying,
          ),
          // 英語再生（ゆっくり）
          _buildAudioButton(
            icon: Icons.slow_motion_video,
            label: 'ゆっくり',
            onPressed: _playEnglishSlow,
            isActive: _isPlaying,
          ),
          // 日本語再生
          _buildAudioButton(
            icon: Icons.translate,
            label: '日本語',
            onPressed: _playJapanese,
            isActive: _isPlaying,
          ),
          // 録音ボタン
          _buildAudioButton(
            icon: _isRecording ? Icons.stop_circle : Icons.mic,
            label: _isRecording ? '停止' : '録音',
            onPressed: _toggleRecording,
            isActive: _isRecording,
            color: _isRecording ? Colors.red : null,
          ),
          // 録音再生ボタン（録音がある場合のみ有効）
          _buildAudioButton(
            icon: Icons.play_circle_outline,
            label: '再生',
            onPressed: _hasRecording ? _playRecording : null,
            isActive: false,
            isEnabled: _hasRecording,
          ),
        ],
      ),
    );
  }

  Widget _buildAudioButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isActive = false,
    Color? color,
    bool isEnabled = true,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton.icon(
          onPressed: isEnabled ? onPressed : null,
          icon: isActive
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon, size: 18, color: color),
          label: Text(
            label,
            style: TextStyle(fontSize: 11, color: color),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            minimumSize: const Size(0, 40),
          ),
        ),
      ),
    );
  }
}
