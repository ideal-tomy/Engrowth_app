import 'package:flutter/material.dart';
import '../models/sentence.dart';
import '../services/tts_service.dart';
import 'optimized_image.dart';

class SentenceCard extends StatefulWidget {
  final Sentence sentence;
  final VoidCallback? onTap;
  /// 学習モードへ遷移するコールバック（例文IDを渡す）
  final void Function(String sentenceId)? onStudyTap;
  /// true の場合 20:80 コンパクト行レイアウト
  final bool compact;
  /// 既習可視化: 習得済みなら true のとき緑チェックバッジ表示
  final bool isMastered;

  const SentenceCard({
    super.key,
    required this.sentence,
    this.onTap,
    this.onStudyTap,
    this.compact = false,
    this.isMastered = false,
  });

  @override
  State<SentenceCard> createState() => _SentenceCardState();
}

class _SentenceCardState extends State<SentenceCard> {
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

  Future<void> _playEnglish() async {
    if (_isPlaying) {
      await _ttsService.stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }
    if (mounted) setState(() => _isPlaying = true);
    await _ttsService.speakEnglish(widget.sentence.englishText);
    if (mounted) setState(() => _isPlaying = false);
  }

  Future<void> _playEnglishSlow() async {
    if (_isPlaying) {
      await _ttsService.stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }
    if (mounted) setState(() => _isPlaying = true);
    await _ttsService.speakEnglishSlow(widget.sentence.englishText);
    if (mounted) setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) return _buildCompactRow();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: OptimizedImage(
                imageUrl: widget.sentence.getImageUrl(),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                groupName: widget.sentence.group,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // カテゴリタグと難易度
                  Row(
                    children: [
                      if (widget.sentence.categoryTag != null && widget.sentence.categoryTag!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.sentence.categoryTag!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (widget.sentence.categoryTag != null && widget.sentence.categoryTag!.isNotEmpty)
                        const SizedBox(width: 8),
                      // 難易度バッジ
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(widget.sentence.difficulty).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: _getDifficultyColor(widget.sentence.difficulty),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '難易度 ${widget.sentence.difficulty}',
                              style: TextStyle(
                                fontSize: 12,
                                color: _getDifficultyColor(widget.sentence.difficulty),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // シーン設定
                  if (widget.sentence.sceneSetting != null && widget.sentence.sceneSetting!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.sentence.sceneSetting!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  if (widget.sentence.sceneSetting != null && widget.sentence.sceneSetting!.isNotEmpty)
                    const SizedBox(height: 12),
                  
                  // 英語例文（音声ボタン付き）
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.sentence.englishText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 音声ボタン（モバイル向け十分なタップ領域）
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _AudioChip(
                            icon: _isPlaying ? Icons.stop_circle : Icons.volume_up,
                            label: '通常',
                            onPressed: _playEnglish,
                          ),
                          const SizedBox(width: 6),
                          _AudioChip(
                            icon: _isPlaying ? Icons.stop_circle : Icons.slow_motion_video,
                            label: 'ゆっくり',
                            onPressed: _playEnglishSlow,
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 日本語例文
                  Text(
                    widget.sentence.japaneseText,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  
                  // 学習するボタン（連続学習導線）
                  if (widget.onStudyTap != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => widget.onStudyTap!(widget.sentence.id),
                        icon: const Icon(Icons.school, size: 18),
                        label: const Text('この例文で練習'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green[700],
                          side: BorderSide(color: Colors.green[700]!),
                        ),
                      ),
                    ),
                  ],
                  if (widget.sentence.targetWords != null && widget.sentence.targetWords!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.sentence.targetWords!.split(',').map((word) {
                        final trimmedWord = word.trim();
                        if (trimmedWord.isEmpty) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.orange.shade200,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            trimmedWord,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactRow() {
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
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: _playEnglish,
                      behavior: HitTestBehavior.opaque,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: _buildThumbnail(),
                        ),
                      ),
                    ),
                    if (widget.isMastered)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Icon(
                          Icons.check_circle,
                          size: 20,
                          color: Colors.green,
                        ),
                      ),
                  ],
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
                        _AudioChip(
                          icon: _isPlaying ? Icons.stop_circle : Icons.volume_up,
                          label: '通常',
                          onPressed: _playEnglish,
                        ),
                        const SizedBox(width: 8),
                        _AudioChip(
                          icon: _isPlaying
                              ? Icons.stop_circle
                              : Icons.slow_motion_video,
                          label: 'ゆっくり',
                          onPressed: _playEnglishSlow,
                        ),
                        const Spacer(),
                        if (widget.onStudyTap != null)
                          IconButton(
                            onPressed: () =>
                                widget.onStudyTap!(widget.sentence.id),
                            icon: const Icon(Icons.school_outlined, size: 22),
                            color: Colors.green[700],
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

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// 音声ボタン用チップ（48x48以上のタップ領域）
class _AudioChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _AudioChip({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: Colors.blue.shade700),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
