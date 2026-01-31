import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sentence.dart';
import '../models/hint_phase.dart';
import '../services/thinking_timer.dart';
import 'hint_display.dart';
import 'optimized_image.dart';
import '../providers/hint_settings_provider.dart';

class StudyCard extends ConsumerStatefulWidget {
  final Sentence sentence;
  final VoidCallback? onMastered;
  final VoidCallback? onNext;
  final Function(HintPhase, int)? onHintUsed; // ヒント使用時のコールバック

  const StudyCard({
    super.key,
    required this.sentence,
    this.onMastered,
    this.onNext,
    this.onHintUsed,
  });

  @override
  ConsumerState<StudyCard> createState() => _StudyCardState();
}

class _StudyCardState extends ConsumerState<StudyCard> with TickerProviderStateMixin {
  bool _showJapanese = false;
  bool _showAnswer = false; // 解答（英語例文全体）を表示するか
  HintPhase _currentHintPhase = HintPhase.none;
  ThinkingTimer? _thinkingTimer;
  bool _isShowingVisualFeedback = false;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  Timer? _answerTimer;
  Timer? _autoNextTimer;
  int _autoNextSecondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initializeTimer();
  }

  void _initializeTimer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(hintSettingsProvider);
      _thinkingTimer = ThinkingTimer(
        onHintPhaseChange: _onHintPhaseChanged,
        settings: settings,
      );
      _thinkingTimer?.start();
    });
  }

  void _onHintPhaseChanged(HintPhase phase) {
    if (mounted) {
      setState(() {
        _currentHintPhase = phase;
      });
      
      // フェードインアニメーション
      _fadeController.forward(from: 0);

      // バイブレーション
      final settings = ref.read(hintSettingsProvider);
      if (settings.hapticFeedbackEnabled) {
        HapticFeedback.lightImpact();
      }

      // 視覚的フィードバック（画面の微かな光る効果）
      if (settings.visualFeedbackEnabled) {
        _showVisualFeedback();
      }

      // 重要単語の段階まで到達後、一定時間入力がなければ解答を表示
      if (phase == HintPhase.keywords && !_showAnswer) {
        _answerTimer?.cancel();
        _answerTimer = Timer(const Duration(seconds: 3), () {
          if (!mounted || _showAnswer) return;
          _showAnswerAuto();
        });
      }

      // コールバック呼び出し
      if (widget.onHintUsed != null) {
        widget.onHintUsed!(phase, _thinkingTimer?.thinkingTimeSeconds ?? 0);
      }
    }
  }

  void _showVisualFeedback() {
    setState(() {
      _isShowingVisualFeedback = true;
    });
    _pulseController.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isShowingVisualFeedback = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _thinkingTimer?.dispose();
    _answerTimer?.cancel();
    _autoNextTimer?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onAnswerShown() {
    _thinkingTimer?.stop();
    _answerTimer?.cancel();
    setState(() {
      _showAnswer = true;
      _showJapanese = true;
    });
    _fadeController.forward(from: 0);
    _startAutoNextCountdown();
  }

  void _showAnswerAuto() {
    _thinkingTimer?.stop();
    setState(() {
      _showAnswer = true;
    });
    _fadeController.forward(from: 0);
    _startAutoNextCountdown();
  }

  void _startAutoNextCountdown() {
    _autoNextTimer?.cancel();
    setState(() {
      _autoNextSecondsRemaining = 3;
    });
    _autoNextTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_autoNextSecondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _autoNextSecondsRemaining = 0;
        });
        _triggerAutoNext();
        return;
      }
      setState(() {
        _autoNextSecondsRemaining -= 1;
      });
    });
  }

  void _triggerAutoNext() {
    _autoNextTimer?.cancel();
    if (!mounted) return;
    _onNext();
  }

  void _onMastered() {
    _thinkingTimer?.stop();
    _answerTimer?.cancel();
    _autoNextTimer?.cancel();
    if (widget.onMastered != null) {
      widget.onMastered!();
    }
  }

  void _onNext() {
    _thinkingTimer?.reset();
    _fadeController.reset();
    _answerTimer?.cancel();
    _autoNextTimer?.cancel();
    setState(() {
      _showJapanese = false;
      _showAnswer = false;
      _currentHintPhase = HintPhase.none;
      _autoNextSecondsRemaining = 0;
    });
    _thinkingTimer?.start();
    if (widget.onNext != null) {
      widget.onNext!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetWords = widget.sentence.targetWords?.split(',').map((w) => w.trim()).toList();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // スマホ向けに画像の高さを調整（画面の40%程度）
    final imageHeight = (screenHeight * 0.4).clamp(200.0, 350.0);

    return Stack(
      children: [
        Column(
          children: [
            // メインコンテンツ（スクロール可能）
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  margin: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 画像エリア（オーバーレイ付き）
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: OptimizedImage(
                              imageUrl: widget.sentence.getImageUrl(),
                              width: double.infinity,
                              height: imageHeight,
                              fit: BoxFit.cover,
                              groupName: widget.sentence.group,
                            ),
                          ),
                          // カテゴリタグと難易度バッジ
                          Positioned(
                            top: 12,
                            left: 12,
                            right: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (widget.sentence.categoryTag != null && widget.sentence.categoryTag!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '#${widget.sentence.categoryTag}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      5,
                                      (index) => Icon(
                                        index < widget.sentence.difficulty
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 12,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // ヒントまたは解答を画像の中心にオーバーレイ表示
                          if (_currentHintPhase != HintPhase.none || _showAnswer)
                            Positioned.fill(
                              child: Center(
                                child: FadeTransition(
                                  opacity: _fadeController,
                                  child: _showAnswer
                                      ? Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              widget.sentence.englishText,
                                              style: TextStyle(
                                                fontSize: screenWidth < 360 ? 20 : 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                height: 1.4,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black.withOpacity(0.85),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            if (_showJapanese) ...[
                                              const SizedBox(height: 12),
                                              Text(
                                                widget.sentence.japaneseText,
                                                style: TextStyle(
                                                  fontSize: screenWidth < 360 ? 16 : 18,
                                                  color: Colors.white.withOpacity(0.9),
                                                  height: 1.5,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black.withOpacity(0.85),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                            if (_autoNextSecondsRemaining > 0) ...[
                                              const SizedBox(height: 12),
                                              Text(
                                                '次の例文へ ${_autoNextSecondsRemaining}s',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white.withOpacity(0.9),
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black.withOpacity(0.85),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        )
                                      : HintDisplay(
                                          fullText: widget.sentence.englishText,
                                          phase: _currentHintPhase,
                                          opacity: 1.0, // オーバーレイでは常に不透明
                                          targetWords: targetWords,
                                          overlayStyle: true,
                                        ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      // シーン設定
                      if (widget.sentence.sceneSetting != null && widget.sentence.sceneSetting!.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          color: Colors.grey[100],
                          child: Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.sentence.sceneSetting!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  
                      // 操作ボタンエリア（画像の下）
                      if (!_showAnswer)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: TextButton.icon(
                            onPressed: _onAnswerShown,
                            icon: const Icon(Icons.translate),
                            label: const Text('答えを見る'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ),
                      
                      // 下部の余白（ボタンエリアのスペース確保）
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
        
          // ボタンエリア（画面下部に固定）
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _onNext,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '次へ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _onMastered,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '覚えた！',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
        // 視覚的フィードバック（画面の光る効果）
        if (_isShowingVisualFeedback)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                color: Colors.blue.withOpacity(0.05 * (1 - _pulseController.value)),
              );
            },
          ),
      ],
    );
  }
}
