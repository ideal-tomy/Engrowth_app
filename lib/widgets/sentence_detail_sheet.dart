import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/sentence.dart';
import '../services/tts_service.dart';
import '../theme/engrowth_theme.dart';
import 'optimized_image.dart';

/// 例文詳細ハーフシート（タップで表示）
/// 英語・日本語・カテゴリ・画像サムネイル・音声を表示
class SentenceDetailSheet extends StatefulWidget {
  final Sentence sentence;

  const SentenceDetailSheet({super.key, required this.sentence});

  static Future<void> show(BuildContext context, Sentence sentence) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SentenceDetailSheet(sentence: sentence),
    );
  }

  @override
  State<SentenceDetailSheet> createState() => _SentenceDetailSheetState();
}

class _SentenceDetailSheetState extends State<SentenceDetailSheet> {
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
                    // 画像サムネイル
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildThumbnail(),
                    ),
                    const SizedBox(height: 16),
                    // カテゴリ
                    if (widget.sentence.categoryTag != null &&
                        widget.sentence.categoryTag!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.sentence.categoryTag!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // 英語
                    Text(
                      widget.sentence.englishText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 日本語
                    Text(
                      widget.sentence.japaneseText,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
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
                          icon: _isPlaying
                              ? Icons.stop_circle
                              : Icons.slow_motion_video,
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
                              context.push(
                                  '/study?sentenceId=${widget.sentence.id}');
                            },
                            icon: const Icon(Icons.school, size: 20),
                            label: const Text('この例文で練習'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green[700],
                              side: BorderSide(color: Colors.green[700]!),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // 同カテゴリを連続再生：プレースホルダー
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '同カテゴリ連続再生は準備中です',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.playlist_play, size: 20),
                            label: const Text('同カテゴリを連続再生'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: EngrowthColors.primary,
                              side: const BorderSide(color: EngrowthColors.primary),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildThumbnail() {
    final url = widget.sentence.getImageUrl();
    if (url != null && url.isNotEmpty) {
      return OptimizedImage(
        imageUrl: url,
        width: double.infinity,
        height: 160,
        fit: BoxFit.cover,
        groupName: widget.sentence.group,
      );
    }
    return Container(
      width: double.infinity,
      height: 160,
      color: Colors.grey.shade200,
      child: Icon(
        Icons.chat_bubble_outline,
        size: 48,
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
