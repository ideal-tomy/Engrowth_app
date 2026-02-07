import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../widgets/study_card.dart';
import '../widgets/review_card.dart';
import '../providers/sentence_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/user_stats_provider.dart';
import '../providers/achievement_provider.dart';
import '../services/learning_service.dart';
import '../services/achievement_service.dart';
import '../services/scenario_service.dart';
import '../widgets/achievement_unlock_dialog.dart';
import '../models/hint_phase.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  int _currentIndex = 0;
  String? _sessionId;
  DateTime? _sessionStartTime;
  Map<String, Map<String, dynamic>> _learningLogs = {}; // sentenceId -> log data

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
    final sentencesAsync = ref.watch(studySentencesProvider);
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
              context.push('/scenarios');
            },
            tooltip: 'シナリオ学習',
          ),
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
      body: Column(
        children: [
          // 復習カード（復習が必要な場合のみ表示）
          const ReviewCard(),
          // 学習コンテンツ
          Expanded(
            child: sentencesAsync.when(
              data: (sentences) {
                if (sentences.isEmpty) {
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

                if (_currentIndex >= sentences.length) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 64, color: Colors.green),
                        SizedBox(height: 16),
                        Text(
                          'すべての例文を学習しました！',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }

                final currentSentence = sentences[_currentIndex];

                return StudyCard(
                  sentence: currentSentence,
                  onMastered: () async {
                    // ストリークとミッション進捗を更新
                    ref.read(userStatsNotifierProvider.notifier).updateStreak();
                    ref.read(userStatsNotifierProvider.notifier).incrementDailyDone();
                    
                    final usedHint = _learningLogs[currentSentence.id]?['used_hint'] ?? false;
                    
                    _logLearning(
                      sentenceId: currentSentence.id,
                      hintPhase: _learningLogs[currentSentence.id]?['hint_phase'] ?? HintPhase.none,
                      thinkingTimeSeconds: _learningLogs[currentSentence.id]?['thinking_time'] ?? 0,
                      usedHint: usedHint,
                      mastered: true,
                      answerShown: false,
                    );
                    progressNotifier.updateProgress(
                      sentenceId: currentSentence.id,
                      isMastered: true,
                    );
                    
                    // バッジ解除チェック
                    await _checkAchievements(context, usedHint: usedHint);
                    
                    _showSnackBar(context, '覚えた！');
                    _nextSentence(sentences.length);
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
                    _nextSentence(sentences.length);
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
        // 次の例文のログをクリア
        _learningLogs.clear();
      });
    } else {
      setState(() {
        _currentIndex = total;
      });
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

  Future<void> _checkAchievements(BuildContext context, {required bool usedHint}) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      // 統計情報を取得
      final stats = await ref.read(userStatsProvider.future);
      
      // 進捗情報を取得
      final progressList = await ref.read(userProgressProvider.future);
      final masteredCount = progressList.where((p) => p.isMastered).length;
      
      // シナリオ完了数を取得
      final scenarioService = ScenarioService();
      final scenarios = await scenarioService.getScenarios();
      int completedScenarios = 0;
      for (final scenario in scenarios) {
        final progress = await scenarioService.getUserProgress(userId, scenario.id);
        if (progress?.isCompleted == true) {
          completedScenarios++;
        }
      }
      
      // ヒントなし正解数を取得（簡易版：user_progressから取得）
      final hintFreeCount = progressList
          .where((p) => p.isMastered && !p.usedHintToMaster)
          .length;

      // バッジ解除チェック
      final achievementService = AchievementService();
      final newlyUnlocked = await achievementService.checkAndUnlockAchievements(
        userId: userId,
        streakCount: stats.streakCount,
        sentenceCount: masteredCount,
        scenarioCount: completedScenarios,
        hintFreeCount: hintFreeCount,
      );

      // 新しく解除されたバッジがあれば演出を表示
      if (newlyUnlocked.isNotEmpty && mounted) {
        final achievements = await ref.read(achievementsProvider.future);
        
        for (final achievementId in newlyUnlocked) {
          final achievement = achievements.firstWhere((a) => a.id == achievementId);
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AchievementUnlockDialog(achievement: achievement),
            );
            // 2秒後に自動で閉じる
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            });
          }
        }
      }
    } catch (e) {
      print('Error checking achievements: $e');
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
              context.pop(); // 学習モードを終了
            },
            child: const Text('終了'),
          ),
        ],
      ),
    );
  }
}
