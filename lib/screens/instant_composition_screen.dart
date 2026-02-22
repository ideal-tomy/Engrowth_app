import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/sentence.dart';
import '../providers/sentence_provider.dart';
import '../services/tts_service.dart';
import '../theme/engrowth_theme.dart';
import '../widgets/optimized_image.dart';
import '../widgets/scenario_background.dart';

/// 瞬間英作文: 画像→2秒発話タイム→3秒で自動答えTTS
class InstantCompositionScreen extends ConsumerStatefulWidget {
  const InstantCompositionScreen({super.key});

  @override
  ConsumerState<InstantCompositionScreen> createState() =>
      _InstantCompositionScreenState();
}

class _InstantCompositionScreenState extends ConsumerState<InstantCompositionScreen>
    with TickerProviderStateMixin {
  final TtsService _ttsService = TtsService();
  int _currentIndex = 0;
  _Phase _phase = _Phase.speaking;
  int _countdownSec = 3;
  Timer? _countdownTimer;
  bool _answerPlayed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCountdown());
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _ttsService.stop();
    _ttsService.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    if (!mounted) return;
    _countdownTimer?.cancel();
    setState(() {
      _phase = _Phase.speaking;
      _countdownSec = 3;
      _answerPlayed = false;
    });
    _pulseController.repeat(reverse: true);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _countdownSec--);
      if (_countdownSec <= 0) {
        _countdownTimer?.cancel();
        _pulseController.stop();
        _pulseController.reset();
        if (!_answerPlayed) _playAnswerAndReveal();
      }
    });
  }

  Future<void> _playAnswerAndReveal() async {
    if (_answerPlayed) return;
    final sentencesAsync = ref.read(instantCompositionSentencesProvider);
    final sentences = sentencesAsync.valueOrNull ?? [];
    if (sentences.isEmpty || _currentIndex >= sentences.length) return;

    setState(() {
      _answerPlayed = true;
      _phase = _Phase.revealed;
    });

    await _ttsService.speakEnglish(sentences[_currentIndex].englishText);
  }

  void _goNext() {
    HapticFeedback.selectionClick();
    final sentencesAsync = ref.read(instantCompositionSentencesProvider);
    final sentences = sentencesAsync.valueOrNull ?? [];
    if (sentences.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % sentences.length;
    });
    _startCountdown();
  }

  void _goPrev() {
    HapticFeedback.selectionClick();
    final sentencesAsync = ref.read(instantCompositionSentencesProvider);
    final sentences = sentencesAsync.valueOrNull ?? [];
    if (sentences.isEmpty) return;
    setState(() {
      _currentIndex = _currentIndex <= 0
          ? sentences.length - 1
          : _currentIndex - 1;
    });
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final sentencesAsync = ref.watch(instantCompositionSentencesProvider);

    return Scaffold(
      backgroundColor: EngrowthColors.background,
      appBar: AppBar(
        title: const Text('瞬間英作文'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            HapticFeedback.selectionClick();
            _showExitDialog(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: sentencesAsync.when(
        data: (sentences) {
          if (sentences.isEmpty) {
            return _buildEmptyState();
          }
          final sentence = sentences[_currentIndex];
          return _buildContent(sentence, sentences.length);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: EngrowthColors.error),
              const SizedBox(height: 16),
              Text('$e', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: EngrowthColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'センテンスがありません',
            style: TextStyle(color: EngrowthColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.push('/sentences'),
            child: const Text('センテンス一覧で登録'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Sentence sentence, int total) {
    final imgUrl = sentence.getImageUrl();
    final showAnswer = _phase == _Phase.revealed;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Column(
                key: ValueKey(_currentIndex),
                children: [
                  // 画像エリア（フルカード）
                  Expanded(
                    flex: 3,
                    child: AnimatedScale(
                      scale: _phase == _Phase.speaking ? 1.0 : 0.98,
                      duration: const Duration(milliseconds: 200),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            imgUrl != null
                                ? OptimizedImage(
                                    imageUrl: imgUrl,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    kScenarioBgAsset,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(color: Colors.grey[300]),
                                  ),
                            // 上から下へのグラデーションオーバーレイ
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.6),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // 日本語ヒント（発話中のみ、下部）
                            if (!showAnswer)
                              Positioned(
                                left: 12,
                                right: 12,
                                bottom: 12,
                                child: Text(
                                  sentence.japaneseText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            // 発話中：パルスマイク
                            if (_phase == _Phase.speaking)
                              Center(
                                child: AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (ctx, child) => Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: EngrowthColors.primary.withOpacity(0.85),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.mic,
                                        size: 48,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            // カウントダウン
                            if (_phase == _Phase.speaking && _countdownSec > 0)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.timer,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '$_countdownSec',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 答え表示エリア
                  if (showAnswer)
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: EngrowthColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                sentence.englishText,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: EngrowthColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                sentence.japaneseText,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: EngrowthColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
        // 下部コントロール
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                IconButton.filled(
                  onPressed: () => _goPrev(),
                  icon: const Icon(Icons.chevron_left),
                  style: IconButton.styleFrom(
                    backgroundColor: EngrowthColors.surface,
                    foregroundColor: EngrowthColors.onSurface,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_phase == _Phase.speaking)
                          TextButton.icon(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              _countdownTimer?.cancel();
                              _pulseController.stop();
                              _playAnswerAndReveal();
                            },
                            icon: const Icon(Icons.volume_up),
                            label: const Text('答えを聞く'),
                            style: TextButton.styleFrom(
                              foregroundColor: EngrowthColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          )
                        else
                          TextButton.icon(
                            onPressed: () async {
                              HapticFeedback.selectionClick();
                              await _ttsService.speakEnglish(sentence.englishText);
                            },
                            icon: const Icon(Icons.replay),
                            label: const Text('もう一度聞く'),
                            style: TextButton.styleFrom(
                              foregroundColor: EngrowthColors.primary,
                            ),
                          ),
                        Text(
                          '${_currentIndex + 1} / $total',
                          style: TextStyle(
                            fontSize: 12,
                            color: EngrowthColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton.filled(
                  onPressed: () => _goNext(),
                  icon: const Icon(Icons.chevron_right),
                  style: IconButton.styleFrom(
                    backgroundColor: EngrowthColors.primary,
                    foregroundColor: EngrowthColors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('終了'),
        content: const Text('瞬間英作文を終了しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('終了'),
          ),
        ],
      ),
    );
  }
}

enum _Phase { speaking, revealed }
