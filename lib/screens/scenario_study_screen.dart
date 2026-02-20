import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/scenario_background.dart';
import '../widgets/study_card.dart';
import '../providers/scenario_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/user_stats_provider.dart';
import '../services/scenario_service.dart';
import '../services/learning_service.dart';
import '../services/learning_completion_orchestrator.dart';
import '../models/hint_phase.dart';

/// シナリオ学習画面
class ScenarioStudyScreen extends ConsumerStatefulWidget {
  final String scenarioId;

  const ScenarioStudyScreen({
    super.key,
    required this.scenarioId,
  });

  @override
  ConsumerState<ScenarioStudyScreen> createState() => _ScenarioStudyScreenState();
}

class _ScenarioStudyScreenState extends ConsumerState<ScenarioStudyScreen> {
  int _currentIndex = 0;
  String? _sessionId;
  DateTime? _sessionStartTime;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  void _initializeSession() {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'anonymous';
    _sessionId = LearningService.startSession(
      userId: userId,
      sentenceIds: [], // 後で更新
    );
    _sessionStartTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final sentencesAsync = ref.watch(scenarioSentencesProvider(widget.scenarioId));
    final progressNotifier = ref.read(progressNotifierProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('シナリオ学習'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _showExitConfirmation(context);
          },
          tooltip: '終了',
        ),
        actions: [
          sentencesAsync.when(
            data: (sentences) => Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text('${_currentIndex + 1} / ${sentences.length}'),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: ScenarioBackground(
        overlayOpacity: 0.35,
        child: sentencesAsync.when(
          data: (sentences) {
            if (sentences.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_stories, size: 64, color: Colors.white70),
                    const SizedBox(height: 16),
                    Text(
                      'シナリオに例文が登録されていません',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              );
          }

          if (_currentIndex >= sentences.length) {
            _markScenarioCompleted(sentences.length - 1);
            return SafeArea(
              child: Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  const Text(
                    'シナリオ完了！',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'お疲れ様でした！',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, foregroundColor: Colors.white),
                    child: const Text('戻る'),
                  ),
                ],
              ),
            ),
            );
          }

          final currentSentence = sentences[_currentIndex];

          return SafeArea(
            child: StudyCard(
            sentence: currentSentence,
            onMastered: () async {
              _logLearning(
                sentenceId: currentSentence.id,
                hintPhase: HintPhase.none,
                thinkingTimeSeconds: 0,
                usedHint: false,
                mastered: true,
                answerShown: false,
              );
              await progressNotifier.updateProgress(
                sentenceId: currentSentence.id,
                isMastered: true,
              );

              // 最後の文の場合、シナリオ完了を先にDB反映
              final isLastSentence = _currentIndex == sentences.length - 1;
              if (isLastSentence) {
                await _markScenarioCompleted(sentences.length - 1);
              }

              await LearningCompletionOrchestrator.onLearningCompleted(ref, context);

              if (mounted) _nextSentence(sentences.length);
            },
            onNext: () {
              _logLearning(
                sentenceId: currentSentence.id,
                hintPhase: HintPhase.none,
                thinkingTimeSeconds: 0,
                usedHint: false,
                mastered: false,
                answerShown: false,
              );
              _nextSentence(sentences.length);
            },
          ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('エラー: $error', style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        ),
      ),
    );
  }

  void _nextSentence(int total) {
    if (_currentIndex < total - 1) {
      setState(() {
        _currentIndex++;
      });
      _updateProgress();
    } else {
      setState(() {
        _currentIndex = total;
      });
    }
  }

  Future<void> _updateProgress() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final service = ScenarioService();
      await service.updateProgress(
        userId: userId,
        scenarioId: widget.scenarioId,
        stepIndex: _currentIndex,
        completed: false,
      );
    } catch (e) {
      print('Error updating scenario progress: $e');
    }
  }

  Future<void> _markScenarioCompleted([int? stepIndex]) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final service = ScenarioService();
      await service.updateProgress(
        userId: userId,
        scenarioId: widget.scenarioId,
        stepIndex: stepIndex ?? _currentIndex,
        completed: true,
      );
    } catch (e) {
      print('Error marking scenario completed: $e');
    }
  }

  Future<void> _logLearning({
    required String sentenceId,
    required HintPhase hintPhase,
    required int thinkingTimeSeconds,
    required bool usedHint,
    required bool mastered,
    required bool answerShown,
  }) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      if (_sessionId == null || _sessionStartTime == null) {
        _initializeSession();
      }

      await LearningService.logLearning(
        userId: userId,
        sentenceId: sentenceId,
        sessionId: _sessionId!,
        sessionStartTime: _sessionStartTime!,
        hintPhase: hintPhase,
        thinkingTimeSeconds: thinkingTimeSeconds,
        usedHint: usedHint,
        mastered: mastered,
        answerShown: answerShown,
      );
    } catch (e) {
      print('Error logging learning: $e');
    }
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('学習を終了しますか？'),
        content: const Text('途中で終了しても、進捗は保存されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('終了'),
          ),
        ],
      ),
    );
  }
}
