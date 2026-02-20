import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/word.dart';
import '../services/tts_service.dart';
import '../theme/engrowth_theme.dart';

/// 単語詳細ハーフシート（タップで表示）
/// 意味・品詞・通常・ゆっくり再生を表示
class WordDetailSheet extends StatefulWidget {
  final Word word;

  const WordDetailSheet({super.key, required this.word});

  static Future<void> show(BuildContext context, Word word) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.black54,
      builder: (context) => WordDetailSheet(word: word),
    );
  }

  @override
  State<WordDetailSheet> createState() => _WordDetailSheetState();
}

class _WordDetailSheetState extends State<WordDetailSheet> {
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
    await _ttsService.speakEnglish(widget.word.word);
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
    await _ttsService.speakEnglishSlow(widget.word.word);
    if (mounted) setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    Text(
                      widget.word.word,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.word.meaning,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                    if (widget.word.wordGroup != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'グループ: ${widget.word.wordGroup}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      '音声',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _VoiceChip(
                          icon: _isPlaying ? Icons.stop_circle : Icons.volume_up,
                          label: '通常',
                          onPressed: _playNormal,
                        ),
                        const SizedBox(width: 12),
                        _VoiceChip(
                          icon: _isPlaying ? Icons.stop_circle : Icons.slow_motion_video,
                          label: 'ゆっくり',
                          onPressed: _playSlow,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.push('/sentences?word=${Uri.encodeComponent(widget.word.word)}');
                            },
                            icon: const Icon(Icons.article_outlined, size: 20),
                            label: const Text('この単語を含む例文へ'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: EngrowthColors.primary,
                              side: const BorderSide(color: EngrowthColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.push('/sentences');
                            },
                            icon: const Icon(Icons.article_outlined, size: 20),
                            label: const Text('例文で検索'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: EngrowthColors.primary,
                              side: const BorderSide(color: EngrowthColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: EngrowthColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
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
