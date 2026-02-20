import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/word.dart';
import '../services/tts_service.dart';
import '../theme/engrowth_theme.dart';

class WordCard extends StatefulWidget {
  final Word word;
  final VoidCallback? onTap;

  const WordCard({
    super.key,
    required this.word,
    this.onTap,
  });

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  final TtsService _ttsService = TtsService();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

  Future<void> _playNormal() async {
    if (_isPlaying) {
      await _ttsService.stop();
      setState(() => _isPlaying = false);
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _isPlaying = true);
    await _ttsService.speakEnglish(widget.word.word);
    if (mounted) setState(() => _isPlaying = false);
  }

  Future<void> _playSlow() async {
    if (_isPlaying) {
      await _ttsService.stop();
      setState(() => _isPlaying = false);
      return;
    }
    HapticFeedback.lightImpact();
    setState(() => _isPlaying = true);
    await _ttsService.speakEnglishSlow(widget.word.word);
    if (mounted) setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.word.word,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 音声ボタン（通常/ゆっくり）- モバイル向け十分なタップ領域
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _VoiceButton(
                        icon: _isPlaying ? Icons.stop_circle : Icons.volume_up,
                        label: '通常',
                        onPressed: _playNormal,
                      ),
                      const SizedBox(width: 8),
                      _VoiceButton(
                        icon: _isPlaying ? Icons.stop_circle : Icons.slow_motion_video,
                        label: 'ゆっくり',
                        onPressed: _playSlow,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.word.meaning,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              if (widget.word.wordGroup != null) ...[
                const SizedBox(height: 8),
                Text(
                  'グループ: ${widget.word.wordGroup}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// モバイル向け十分なタップ領域（48x48以上）を持つ音声ボタン
class _VoiceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _VoiceButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EngrowthColors.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: EngrowthColors.primary),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: EngrowthColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
