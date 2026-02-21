import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../widgets/study_card.dart';
import '../widgets/review_card.dart';
import '../widgets/session_complete_dialog.dart';
import '../providers/sentence_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/session_mode_provider.dart';
import '../providers/last_study_resume_provider.dart';
import '../services/learning_service.dart';
import '../services/learning_completion_orchestrator.dart';
import '../providers/analytics_provider.dart';
import '../models/hint_phase.dart';
import '../models/learning_session_mode.dart';
import '../models/sentence.dart';
import '../theme/engrowth_theme.dart';

class StudyScreen extends ConsumerStatefulWidget {
  final String? initialSentenceId;
  final String? initialSessionModeParam;

  const StudyScreen({
    super.key,
    this.initialSentenceId,
    this.initialSessionModeParam,
  });

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  int _currentIndex = 0;
  String? _sessionId;
  DateTime? _sessionStartTime;
  Map<String, Map<String, dynamic>> _learningLogs = {};
  bool _sessionCompleteDialogShown = false;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  LearningSessionMode? _resolveSessionMode(WidgetRef ref) {
    final param = widget.initialSessionModeParam;
    if (param == 'quick30') return LearningSessionMode.quick30;
    if (param == 'focus3') return LearningSessionMode.focus3;
    return ref.read(sessionModeProvider);
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
    final sessionMode = _resolveSessionMode(ref);
    final resumeState = ref.watch(lastStudyResumeProvider);
    final effectiveSentenceId = widget.initialSentenceId ?? resumeState.sentenceId;
    final sentencesAsync = ref.watch(studySentencesFromProvider(effectiveSentenceId));
    final progressNotifier = ref.read(progressNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('学習モード'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _showExitConfirmation(context);
          },
          tooltip: '終了',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/home'),
            tooltip: 'Home へ',
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              context.push('/account');
            },
            tooltip: 'アカウント',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/hint-settings');
            },
            tooltip: 'ヒント設定',
          ),
          IconButton(
            icon: const Icon(Icons.auto_stories),
            onPressed: () {
              context.push('/scenario-learning');
            },
            tooltip: 'シナリオ学習',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: '会話学習',
            onSelected: (value) {
              if (value == 'student') {
                context.push('/conversations?type=student');
              } else if (value == 'business') {
                context.push('/conversations?type=business');
              } else {
                context.push('/conversations');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 20),
                    SizedBox(width: 8),
                    Text('すべての会話'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'student',
                child: Row(
                  children: [
                    Icon(Icons.school, size: 20),
                    SizedBox(width: 8),
                    Text('学生コース'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'business',
                child: Row(
                  children: [
                    Icon(Icons.business, size: 20),
                    SizedBox(width: 8),
                    Text('ビジネスコース'),
                  ],
                ),
              ),
            ],
          ),
          sentencesAsync.when(
            data: (sentences) {
              final mode = _resolveSessionMode(ref);
              final maxCount = mode?.maxSentenceCount ?? 999;
              final total = sentences.take(maxCount).length;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text('${_currentIndex + 1} / $total'),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 復習カード（復習が必要な場合のみ表示）
          const ReviewCard(),
          // 学習コンテンツ
          Expanded(
            child: sentencesAsync.when(
              data: (sentences) {
                final mode = _resolveSessionMode(ref);
                final maxCount = mode?.maxSentenceCount ?? 999;
                final limitedSentences = sentences.take(maxCount).toList();
                // studySentencesFromProvider が sentenceId に応じて既に並べ替え済み。常に _currentIndex=0 から開始。
                if (limitedSentences.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          '例文がまだ登録されていません',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (_currentIndex >= limitedSentences.length) {
                  final mode = _resolveSessionMode(ref);
                  if ((mode == LearningSessionMode.quick30 ||
                          mode == LearningSessionMode.focus3) &&
                      !_sessionCompleteDialogShown) {
                    _sessionCompleteDialogShown = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      _showSessionCompleteDialog(mode!, limitedSentences.length);
                    });
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 64, color: EngrowthColors.primary),
                        const SizedBox(height: 16),
                        Text(
                          mode == LearningSessionMode.quick30 ||
                                  mode == LearningSessionMode.focus3
                              ? 'セッション完了！'
                              : 'すべての例文を学習しました！',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (mode == LearningSessionMode.quick30 ||
                            mode == LearningSessionMode.focus3)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              '${limitedSentences.length}問クリア',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                final currentSentence = limitedSentences[_currentIndex];

                return StudyCard(
                  sentence: currentSentence,
                  remainingCount: limitedSentences.length - _currentIndex - 1,
                  totalInSession: limitedSentences.length,
                  onMastered: () async {
                    final usedHint = _learningLogs[currentSentence.id]?['used_hint'] ?? false;

                    _logLearning(
                      sentenceId: currentSentence.id,
                      hintPhase: _learningLogs[currentSentence.id]?['hint_phase'] ?? HintPhase.none,
                      thinkingTimeSeconds: _learningLogs[currentSentence.id]?['thinking_time'] ?? 0,
                      usedHint: usedHint,
                      mastered: true,
                      answerShown: false,
                    );
                    await progressNotifier.updateProgress(
                      sentenceId: currentSentence.id,
                      isMastered: true,
                    );

                    await LearningCompletionOrchestrator.onLearningCompleted(ref, context);

                    if (mounted) _saveResumePoint(limitedSentences);
                    if (mounted) _showSnackBar(context, '覚えた！');
                    if (mounted) _nextSentence(limitedSentences.length);
                  },
                  onNext: () {
                    _logLearning(
                      sentenceId: currentSentence.id,
                      hintPhase: _learningLogs[currentSentence.id]?['hint_phase'] ?? HintPhase.none,
                      thinkingTimeSeconds: _learningLogs[currentSentence.id]?['thinking_time'] ?? 0,
                      usedHint: _learningLogs[currentSentence.id]?['used_hint'] ?? false,
                      mastered: false,
                      answerShown: false,
                    );
                    if (mounted) _saveResumePoint(limitedSentences);
                    _nextSentence(limitedSentences.length);
                  },
                  onHintUsed: (HintPhase phase, int thinkingTimeSeconds) {
                    _learningLogs[currentSentence.id] = {
                      'hint_phase': phase,
                      'thinking_time': thinkingTimeSeconds,
                      'used_hint': true,
                    };
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('エラー: $error'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextSentence(int total) {
    if (_currentIndex < total - 1) {
      setState(() {
        _currentIndex++;
        _learningLogs.clear();
      });
    } else {
      setState(() => _currentIndex = total);
    }
  }

  void _saveResumePoint(List<Sentence> limitedSentences) {
    final nextIndex = _currentIndex + 1;
    if (nextIndex < limitedSentences.length) {
      ref.read(lastStudyResumeProvider.notifier).saveResumePoint(
            limitedSentences[nextIndex].id,
          );
    } else {
      ref.read(lastStudyResumeProvider.notifier).clear();
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
      if (userId == null) {
        // ユーザーがログインしていない場合はログを記録しない
        return;
      }

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
      // エラー時も続行
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showSessionCompleteDialog(LearningSessionMode mode, int count) {
    final analytics = ref.read(analyticsServiceProvider);
    if (mode == LearningSessionMode.quick30) {
      analytics.logQuick30Complete(count: count);
    } else {
      analytics.logFocus3Complete(count: count);
    }
    final label = mode == LearningSessionMode.quick30 ? '30秒クリア！' : '3分クリア！';
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => SessionCompleteDialog(
        sessionLabel: '$label（$count問）',
        onStartAnother: () {
          final param = mode == LearningSessionMode.quick30 ? 'quick30' : 'focus3';
          context.push('/study?sessionMode=$param');
        },
      ),
    );
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
              context.pop(); // 学習モードを終了
            },
            child: const Text('終了'),
          ),
        ],
      ),
    );
  }
}
