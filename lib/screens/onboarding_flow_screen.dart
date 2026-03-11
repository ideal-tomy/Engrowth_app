import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/learning_handoff_result.dart';
import '../providers/analytics_provider.dart';
import '../providers/coach_provider.dart';
import '../providers/next_action_provider.dart';
import '../providers/onboarding_provider.dart';
import '../theme/engrowth_theme.dart';
import '../widgets/tutorial/tutorial_sequencer.dart';
import '../widgets/common/engrowth_popup.dart';

/// 初回体験フロー
/// 挨拶・30秒会話・パターンスクリプト・日次提出疑似体験の順で操作を案内
class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalSteps = 7;
  static const String _variant = 'v2';

  // 日次提出疑似体験用の簡易タイマー状態
  Timer? _mockDailySubmitTimer;
  int _mockDailySubmitRemainingSec = 0;
  bool _mockDailySubmitActive = false;
  int _mockDailyStep = 1; // 1〜4 の段階ポップアップ

  bool _mockDailyIntroStarted = false;

  // ウェルカムCTA用の単発パルス演出
  Timer? _welcomePulseTimer;
  bool _welcomePulseActive = false;

  late final TutorialSequencer _welcomeSequencer;
  Timer? _autoStepTimer;

  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).logOnboardingStarted(
          step: 'welcome',
          variant: _variant,
        );

    _welcomeSequencer = TutorialSequencer(
      vsync: this,
      onProgress: (_) {},
    );

    // Welcome ステップの「登場→滞在→CTAパルス→余韻」をシーケンスとして実行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _runWelcomeSequence();
    });
  }

  @override
  void dispose() {
    _mockDailySubmitTimer?.cancel();
    _welcomePulseTimer?.cancel();
    _autoStepTimer?.cancel();
    _welcomeSequencer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _runWelcomeSequence() async {
    // すでに別ページに移動している場合は何もしない
    if (!mounted || _currentPage != 0) return;

    await _welcomeSequencer.runStep(
      TutorialSequenceStep(
        // 登場: テキストなどは既に表示されているので、軽い待ちのみ
        enterDuration: const Duration(milliseconds: 800),
        onEnter: () async {
          // ここでは特に何もしない（静寂の時間）
        },
        // 滞在: コンテンツを読む時間
        stayDuration: const Duration(milliseconds: 1800),
        // 演出: CTAボタンの単発パルス
        performDuration: EngrowthElementTokens.switchDuration,
        onPerform: () async {
          if (!mounted || _currentPage != 0) return;
          _welcomePulseTimer?.cancel();
          setState(() => _welcomePulseActive = true);
          await Future.delayed(EngrowthElementTokens.switchDuration);
          if (mounted && _currentPage == 0) {
            setState(() => _welcomePulseActive = false);
          }
        },
        // 余白: パルス後の静かな待ち
        pauseDuration: const Duration(milliseconds: 800),
        // 退場: このステップではページ遷移させないためゼロ
        exitDuration: Duration.zero,
      ),
    );
  }

  void _goToNext() {
    if (_currentPage >= _totalSteps - 1) return;
    HapticFeedback.selectionClick();
    ref.read(analyticsServiceProvider).logOnboardingStepCompleted(
          step: _stepId(_currentPage + 1),
          index: _currentPage + 1,
          variant: _variant,
        );
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage++);
  }

  void _startMockDailySubmit() {
    if (_mockDailySubmitActive) return;
    HapticFeedback.selectionClick();
    ref
        .read(analyticsServiceProvider)
        .logOnboardingMockSubmitStarted(variant: _variant);
    _mockDailySubmitTimer?.cancel();
    setState(() {
      _mockDailySubmitActive = true;
      _mockDailySubmitRemainingSec = 30;
      _mockDailyStep = 4;
    });
    _mockDailySubmitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_mockDailySubmitRemainingSec <= 1) {
        timer.cancel();
        setState(() {
          _mockDailySubmitRemainingSec = 0;
          _mockDailySubmitActive = false;
        });
        ref
            .read(analyticsServiceProvider)
            .logOnboardingMockSubmitCompleted(
              variant: _variant,
              skippedEarly: false,
            );
        _goToNext();
      } else {
        setState(() {
          _mockDailySubmitRemainingSec--;
        });
      }
    });
  }

  void _skipMockDailySubmit() {
    HapticFeedback.selectionClick();
    final wasActive = _mockDailySubmitActive;
    _mockDailySubmitTimer?.cancel();
    setState(() {
      _mockDailySubmitActive = false;
      _mockDailySubmitRemainingSec = 0;
      _mockDailyStep = 1;
    });
    ref
        .read(analyticsServiceProvider)
        .logOnboardingMockSubmitCompleted(
          variant: _variant,
          skippedEarly: wasActive,
        );
    _goToNext();
  }

  String _stepId(int index) {
    const ids = [
      'welcome',
      'greeting_experience',
      'quick30',
      'pattern_sprint',
      'focus3',
      'submit',
      'result',
    ];
    return ids[index.clamp(0, ids.length - 1)];
  }

  void _autoAdvanceToNext() {
    if (_currentPage >= _totalSteps - 1) return;
    final nextIndex = _currentPage + 1;
    final nextStepId = _stepId(nextIndex);
    // 手動タップではないのでハプティクスは鳴らさず、ステップ完了だけ記録する
    ref.read(analyticsServiceProvider).logOnboardingStepCompleted(
          step: nextStepId,
          index: nextIndex,
          variant: _variant,
        );
    _pageController.jumpToPage(nextIndex);
    setState(() => _currentPage = nextIndex);
  }

  Future<void> _tryStepAndAdvance(String route) async {
    HapticFeedback.selectionClick();
    final fromStep = _stepId(_currentPage);
    final result = await context.push<LearningHandoffResult>(route);
    if (!mounted) return;
    // 体験が最後まで完了した場合
    if (result != null && result.completed) {
      ref.read(analyticsServiceProvider).logTutorialAutoAdvanced(
            learningMode: result.learningMode ?? 'unknown',
            fromStep: fromStep,
            toStep: _stepId(_currentPage + 1),
          );
      _autoAdvanceToNext();
      return;
    }

    // 途中で閉じた / エラーなどで完了しなかった場合も、
    // オンボーディングの流れとしては次のステップへ進める
    ref.read(analyticsServiceProvider).logTutorialAutoAdvanced(
          learningMode: result?.learningMode ?? 'skipped_or_incomplete',
          fromStep: fromStep,
          toStep: _stepId(_currentPage + 1),
        );
    _autoAdvanceToNext();
  }

  Future<void> _completeOnboarding({String? nextRoute}) async {
    HapticFeedback.mediumImpact();
    ref.read(analyticsServiceProvider).logOnboardingCompleted(
          variant: _variant,
          nextRecommendedAction: nextRoute != null ? 'next_learning' : 'resume_card',
        );
    ref.read(onboardingHandoffPendingProvider.notifier).state = true;
    await ref.read(onboardingCompleteNotifierProvider).markCompleted();
    if (!mounted) return;
    ref.invalidate(onboardingCompletedProvider);
    context.go(nextRoute ?? '/home');
  }

  Future<void> _skipOnboarding() async {
    HapticFeedback.selectionClick();
    ref.read(analyticsServiceProvider).logOnboardingSkipped(
          atStep: _stepId(_currentPage),
          variant: _variant,
        );
    await ref.read(onboardingCompleteNotifierProvider).markCompleted();
    if (!mounted) return;
    ref.invalidate(onboardingCompletedProvider);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        setState(() => _currentPage--);
                      },
                    )
                  else
                    const SizedBox(width: 48),
                  Text(
                    '${_currentPage + 1} / $_totalSteps',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: const Text('スキップ'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) {
                  setState(() => _currentPage = i);
                  _autoStepTimer?.cancel();

                  // 「はじめる」以降は、挨拶体験 / 30秒会話 / パターンスプリプトは
                  // 原則自動で体験をスタートさせる。
                  if (i == 1) {
                    // 挨拶体験: 説明を10秒見せてから自動で挨拶体験画面へ
                    _autoStepTimer = Timer(const Duration(seconds: 10), () {
                      if (!mounted || _currentPage != 1) return;
                      _tryStepAndAdvance(
                        '/tutorial-conversation?entry_source=onboarding',
                      );
                    });
                  } else if (i == 2) {
                    // 30秒会話: 説明を10秒見せてから自動で30秒会話体験へ
                    _autoStepTimer = Timer(const Duration(seconds: 10), () {
                      if (!mounted || _currentPage != 2) return;
                      _tryStepAndAdvance(
                        '/scenario-learning?from_onboarding=true',
                      );
                    });
                  } else if (i == 3) {
                    // パターンスクリプト: 説明を10秒見せてから自動で体験へ
                    _autoStepTimer = Timer(const Duration(seconds: 10), () {
                      if (!mounted || _currentPage != 3) return;
                      _tryStepAndAdvance(
                        '/pattern-sprint?from_onboarding=true',
                      );
                    });
                  } else if (i == 4) {
                    // 3分英会話説明: 5秒間の滞在後に自動で「今日あった出来事」ステップへ
                    _autoStepTimer = Timer(const Duration(seconds: 5), () {
                      if (!mounted || _currentPage != 4) return;
                      _autoAdvanceToNext();
                    });
                  } else if (i == 5) {
                    // 今日あった出来事: ポップアップシーケンスを開始
                    _maybeStartMockDailyIntro();
                  }
                },
                children: [
                  _buildWelcomeStep(),
                  _buildGreetingExperienceStep(),
                  _buildQuick30Step(),
                  _buildPatternSprintStep(),
                  _buildFocus3Step(),
                  _buildSubmitStep(),
                  _buildResultStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.record_voice_over,
            size: 80,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Engrowthへようこそ',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '聞いて→まねして→使う。毎日の英語報告で伴走されます。',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: AnimatedScale(
              scale: _welcomePulseActive ? 1.04 : 1.0,
              duration: EngrowthElementTokens.switchDuration,
              curve: EngrowthElementTokens.switchCurveIn,
              child: FilledButton(
                onPressed: _goToNext,
                style: FilledButton.styleFrom(
                  backgroundColor: EngrowthColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('はじめる'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingExperienceStep() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.waving_hand, size: 64, color: colorScheme.primary),
          const SizedBox(height: 20),
          Text(
            '挨拶体験',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'AIが話しかける→返事する→返答が返る。まず1往復体験。',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _tryStepAndAdvance(
                    '/tutorial-conversation?entry_source=onboarding',
                  ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('体験する'),
            ),
          ),
          const SizedBox(height: 12),
          // 全自動フロー前提のため、「あとで体験する」は削除
        ],
      ),
    );
  }

  Widget _buildQuick30Step() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer, size: 64, color: colorScheme.primary),
          const SizedBox(height: 20),
          Text(
            '30秒会話',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            '隙間30秒で聞く練習。まずは聴くだけでOK。',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _tryStepAndAdvance(
                    '/scenario-learning?from_onboarding=true',
                  ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('体験する'),
            ),
          ),
          const SizedBox(height: 12),
          // 全自動フロー前提のため、「あとで体験する」は削除
        ],
      ),
    );
  }

  Widget _buildPatternSprintStep() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mic, size: 64, color: colorScheme.primary),
          const SizedBox(height: 20),
          Text(
            'パターンスクリプト',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            '聞く→録音→聴き直して「コンサルタントに提出」で提出。',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _tryStepAndAdvance(
                    '/pattern-sprint?from_onboarding=true',
                  ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('体験する'),
            ),
          ),
          const SizedBox(height: 12),
          // 全自動フロー前提のため、「あとで体験する」は削除
        ],
      ),
    );
  }

  Widget _buildFocus3Step() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories, size: 64, color: colorScheme.primary),
          const SizedBox(height: 20),
          Text(
          '3分英会話（上級モード）',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
          '少しスパルタですが、3分の会話を通して聞いて・まねして・話すモードです。'
          ' 音で覚えてから取り組むと、英会話の地力アップにとても効果的です。',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          // 説明のみのステップ。十分な滞在時間を取ったあとは自動で次へ進むため、ここではCTAを置かない。
        ],
      ),
    );
  }

  Widget _buildSubmitStep() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 64, color: colorScheme.primary),
          const SizedBox(height: 20),
          Text(
            '今日あった出来事を英語で言ってみる',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (_mockDailyStep < 4)
            Text(
              '説明を順に表示しています',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            )
          else
            const SizedBox.shrink(),
          const Spacer(),
          if (_mockDailySubmitActive) ...[
            const SizedBox(height: 24),
            Text(
              '${_mockDailySubmitRemainingSec.toString().padLeft(2, '0')} 秒',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 24),
          ] else if (_mockDailyStep >= 4) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _startMockDailySubmit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('録音を体験する'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  void _maybeStartMockDailyIntro() {
    if (_mockDailyIntroStarted) return;
    _mockDailyIntroStarted = true;
    setState(() => _mockDailyStep = 1);
    _runDailyIntroPopups();
  }

  /// 「今日あった出来事」の説明を EngrowthPopup で順に表示
  Future<void> _runDailyIntroPopups() async {
    const texts = [
      '今日あった出来事を、英語で録音していきます。',
      'コンサルタントへの提出が、日々の基本的なミッションになります。',
    ];
    for (var i = 0; i < texts.length; i++) {
      if (!mounted || _currentPage != 5 || _mockDailySubmitActive) break;
      await _showDailyIntroPopup(texts[i]);
      if (!mounted || _currentPage != 5 || _mockDailySubmitActive) break;
      await Future.delayed(const Duration(seconds: 1));
    }
    if (!mounted || _currentPage != 5 || _mockDailySubmitActive) return;
    // 最後のステップ: 録音体験だけはユーザーにボタンを押してもらう
    await _showDailyIntroPopup(
      '今日あった出来事を1つ決めて、30秒ほどで伝えてみましょう。\n\n準備ができたら「録音を体験する」を押してください。',
      withActionButton: true,
    );
    if (!mounted || _currentPage != 5 || _mockDailySubmitActive) return;
    setState(() => _mockDailyStep = 4);
  }

  Future<void> _showDailyIntroPopup(
    String body, {
    bool withActionButton = false,
  }) async {
    if (!mounted) return;

    if (!withActionButton) {
      // 説明ポップアップ: 3秒で自動クローズ
      await EngrowthPopup.show<void>(
        context,
        title: '今日あった出来事',
        body: Text(
          body,
          textAlign: TextAlign.center,
        ),
        autoCloseAfter: const Duration(seconds: 3),
        analyticsVariant: 'onboarding_daily_intro',
        analyticsSourceScreen: 'onboarding_submit',
      );
      return;
    }

    // 録音スタート用ポップアップ
    await EngrowthPopup.show<void>(
      context,
      title: '録音の準備をしましょう',
      body: Text(
        body,
        textAlign: TextAlign.center,
      ),
      primaryLabel: '録音を体験する',
      onPrimary: () {
        Navigator.of(context).pop();
        _startMockDailySubmit();
        _showRecordingCountdownPopup();
      },
      analyticsVariant: 'onboarding_daily_ready',
      analyticsSourceScreen: 'onboarding_submit',
    );
  }

  Future<void> _showRecordingCountdownPopup() async {
    if (!mounted) return;
    const totalSec = 30;
    await EngrowthPopup.show<void>(
      context,
      title: '録音中',
      subtitle: '30秒間、今日あった出来事を英語で話してみましょう。',
      body: const _RecordingCountdownBody(totalSec: totalSec),
      autoCloseAfter: const Duration(seconds: totalSec),
      analyticsVariant: 'onboarding_daily_recording',
      analyticsSourceScreen: 'onboarding_submit',
    );
  }

  Widget _buildResultStep() {
    final colorScheme = Theme.of(context).colorScheme;
    return _OnboardingResultStep(
      onComplete: _completeOnboarding,
      colorScheme: colorScheme,
    );
  }
}

/// 録音中の30秒カウントダウン表示用ボディ（EngrowthPopup 内で使用）
class _RecordingCountdownBody extends StatefulWidget {
  final int totalSec;
  const _RecordingCountdownBody({required this.totalSec});

  @override
  State<_RecordingCountdownBody> createState() =>
      _RecordingCountdownBodyState();
}

class _RecordingCountdownBodyState extends State<_RecordingCountdownBody> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.totalSec;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_remaining > 0) {
          _remaining--;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '録音中...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '残り $_remaining 秒',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// 結果表示ステップ（段階表示・ハプティクス・動的CTA）
class _OnboardingResultStep extends ConsumerStatefulWidget {
  final void Function({String? nextRoute}) onComplete;
  final ColorScheme colorScheme;

  const _OnboardingResultStep({
    required this.onComplete,
    required this.colorScheme,
  });

  @override
  ConsumerState<_OnboardingResultStep> createState() =>
      _OnboardingResultStepState();
}

class _OnboardingResultStepState extends ConsumerState<_OnboardingResultStep>
    with TickerProviderStateMixin {
  late AnimationController _sequenceController;
  late Animation<double> _sequenceAnim;
  late Animation<double> _ctaScaleAnim;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    _sequenceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _sequenceAnim = CurvedAnimation(
      parent: _sequenceController,
      curve: Curves.easeOut,
    );
    _ctaScaleAnim = CurvedAnimation(
      parent: _sequenceController,
      curve: const Interval(
        0.9,
        1.0,
        curve: Curves.easeOutBack,
      ),
    );
    double _lastHapticAt = -1;
    _sequenceController.addListener(() {
      final v = _sequenceAnim.value;
      final thresholds = [0.1, 0.2, 0.4, 0.6, 0.8, 0.9];
      for (var i = 0; i < thresholds.length; i++) {
        if (v >= thresholds[i] && _lastHapticAt < thresholds[i]) {
          _lastHapticAt = thresholds[i];
          HapticFeedback.selectionClick();
          break;
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sequenceController.forward();
    });
  }

  @override
  void dispose() {
    _sequenceController.dispose();
    super.dispose();
  }

  double _opacityFor(double start, double end) {
    final v = _sequenceAnim.value;
    if (v < start) return 0;
    if (v >= end) return 1;
    return (v - start) / (end - start);
  }

  @override
  Widget build(BuildContext context) {
    final missionAsync = ref.watch(todaysCoachMissionProvider);
    final nextActionsAsync = ref.watch(nextActionSuggestionsProvider);
    final mission = missionAsync.valueOrNull;
    final suggestions = nextActionsAsync.valueOrNull ?? [];
    final firstSuggestion = suggestions.isNotEmpty ? suggestions.first : null;

    String primaryLabel = '次の学習へ';
    String? primaryRoute = '/study';
    if (mission != null) {
      primaryLabel = 'コンサルタントの課題へ';
      primaryRoute = mission.actionRoute ?? '/study';
    } else if (firstSuggestion != null) {
      primaryLabel = firstSuggestion.title;
      primaryRoute = firstSuggestion.route;
    }

    return AnimatedBuilder(
      animation: _sequenceAnim,
      builder: (context, _) {
        final op0 = _opacityFor(0.0, 0.1);
        final op1 = _opacityFor(0.1, 0.2);
        final op2 = _opacityFor(0.2, 0.4);
        final op3 = _opacityFor(0.4, 0.6);
        final op4 = _opacityFor(0.6, 0.8);
        final op5 = _opacityFor(0.8, 0.9);
        final op6 = _opacityFor(0.9, 1.0);
        final v1 = (3 * ((_sequenceAnim.value - 0.2) / 0.2).clamp(0.0, 1.0)).round();
        final v2 = (5 * ((_sequenceAnim.value - 0.4) / 0.2).clamp(0.0, 1.0)).round();
        final v3 = (2 * ((_sequenceAnim.value - 0.6) / 0.2).clamp(0.0, 1.0)).round();

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: op0,
                child: Icon(
                  Icons.check_circle,
                  size: 72,
                  color: widget.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Opacity(
                opacity: op1,
                child: Text(
                  '体験完了！',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.colorScheme.onSurface,
                      ),
                ),
              ),
              const SizedBox(height: 24),
              Opacity(
                opacity: op2,
                child: _ResultRow(
                  label: '学習時間',
                  value: v1,
                  suffix: '分',
                  colorScheme: widget.colorScheme,
                ),
              ),
              const SizedBox(height: 12),
              Opacity(
                opacity: op3,
                child: _ResultRow(
                  label: '話した文章',
                  value: v2,
                  suffix: '文',
                  colorScheme: widget.colorScheme,
                ),
              ),
              const SizedBox(height: 12),
              Opacity(
                opacity: op4,
                child: _ResultRow(
                  label: '新しい単語',
                  value: v3,
                  suffix: '語',
                  colorScheme: widget.colorScheme,
                ),
              ),
              const SizedBox(height: 24),
              Opacity(
                opacity: op5,
                child: Column(
                  children: [
                    Text(
                      'ホームで「続きから再開」をタップすると学習を始められます。',
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'アカウント作成で録音・進捗・連続日数が記録されます。',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.colorScheme.onSurfaceVariant.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Opacity(
                opacity: op6,
                child: AnimatedBuilder(
                  animation: _ctaScaleAnim,
                  builder: (context, child) => Transform.scale(
                    scale: 0.94 + 0.06 * _ctaScaleAnim.value,
                    child: child,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        ref.read(analyticsServiceProvider).logResultNextLearningTap(
                              flow: 'onboarding',
                              targetRoute: primaryRoute,
                            );
                        widget.onComplete(nextRoute: primaryRoute);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(primaryLabel),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Opacity(
                opacity: op6,
                child: TextButton(
                  onPressed: () => widget.onComplete(),
                  child: const Text('ホームへ'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final int value;
  final String suffix;
  final ColorScheme colorScheme;

  const _ResultRow({
    required this.label,
    required this.value,
    required this.suffix,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            '$value$suffix',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
