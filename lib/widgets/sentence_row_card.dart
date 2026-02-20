import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/sentence.dart';
import '../services/tts_service.dart';
import '../theme/engrowth_theme.dart';
import 'optimized_image.dart';

/// 20:80 レイアウトのセンテンス行
/// 左に小型サムネイル、右に英語/日本語/最小アクション（再生・学習開始）
class SentenceRowCard extends StatefulWidget {
  final Sentence sentence;
  final VoidCallback? onTap;
  final void Function(String sentenceId)? onStudyTap;

  const SentenceRowCard({
    super.key,
    required this.sentence,
    this.onTap,
    this.onStudyTap,
  });

  @override
  State<SentenceRowCard> createState() => _SentenceRowCardState();
}

class _SentenceRowCardState extends State<SentenceRowCard> {
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
      if (mounted) setState(() => _isPlaying = false);
      return;
    }
    HapticFeedback.lightImpact();
    if (mounted) setState(() => _isPlaying = true);
    await _ttsService.speakEnglish(widget.sentence.englishText);
    if (mounted) setState(() => _isPlaying = false);
  }

  Future<void> _playSlow() async {
    if (_isPlaying) {
      await _ttsService.stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }
    HapticFeedback.lightImpact();
    if (mounted) setState(() => _isPlaying = true);
    await _ttsService.speakEnglishSlow(widget.sentence.englishText);
    if (mounted) setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _buildThumbnail(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.sentence.categoryTag != null &&
                        widget.sentence.categoryTag!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          widget.sentence.categoryTag!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Text(
                      widget.sentence.englishText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.sentence.japaneseText,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _VoiceChip(
                          icon: _isPlaying ? Icons.stop_circle : Icons.volume_up,
                          label: '通常',
                          onPressed: _playNormal,
                        ),
                        const SizedBox(width: 8),
                        _VoiceChip(
                          icon: _isPlaying
                              ? Icons.stop_circle
                              : Icons.slow_motion_video,
                          label: 'ゆっくり',
                          onPressed: _playSlow,
                        ),
                        const Spacer(),
                        if (widget.onStudyTap != null)
                          IconButton(
                            onPressed: () =>
                                widget.onStudyTap!(widget.sentence.id),
                            icon: const Icon(Icons.school_outlined, size: 22),
                            color: EngrowthColors.primary,
                            tooltip: 'この例文で練習',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final url = widget.sentence.getImageUrl();
    if (url != null && url.isNotEmpty) {
      return OptimizedImage(
        imageUrl: url,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        groupName: widget.sentence.group,
      );
    }
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.chat_bubble_outline,
        size: 28,
        color: Colors.grey.shade500,
      ),
    );
  }
}

class _VoiceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _VoiceChip({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EngrowthColors.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: EngrowthColors.primary),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
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
