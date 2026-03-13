import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/scenario_categories.dart';
import '../models/learning_handoff_result.dart';
import '../providers/analytics_provider.dart';
import '../providers/coach_provider.dart';
import '../providers/conversation_provider.dart';
import '../providers/next_action_provider.dart';
import '../providers/onboarding_provider.dart';
import '../services/tts_warmup_service.dart';
import '../theme/engrowth_theme.dart';
import '../widgets/tutorial/tutorial_sequencer.dart';
import '../widgets/common/engrowth_popup.dart';

enum _Phase {
  greetingBridge,
  greetingExp,
  quick30Bridge,
  quick30Exp,
  patternBridge,
  patternExp,
  focus3Bridge,
  dailyBridge1,
  dailyBridge2,
  recordingIntro,
  result,
}

/// 初回体験フロー
/// 「はじめる」押下後、音声再生以外はタップ不要で録音体験まで自動進行
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
  static const int _totalSteps = 2;
  static const String _variant = 'v3_auto_flow';

  // ウェルカムCTA用の単発パルス演出
  Timer? _welcomePulseTimer;
  bool _welcomePulseActive = false;

  late final TutorialSequencer _welcomeSequencer;

  /// 自動進行フロー完了後、結果画面を表示するか
  bool _showResultStep = false;

  /// 自動進行フロー実行中か（スキップ判定用）
  bool _autoFlowRunning = false;

  /// 「仮の録音体験をする」ボタンが押されたか（fallback 判定用）
  bool _mockRecordingButtonTapped = false;

  /// 現在のフェーズ（0=挨拶前, 1=挨拶後, 2=30秒前, ... 9=録音前）
  int _currentPhaseIndex = 0;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _runWelcomeSequence();
    });
  }

  @override
  void dispose() {
    _welcomePulseTimer?.cancel();
    _welcomeSequencer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _runWelcomeSequence() async {
    if (!mounted || _currentPage != 0) return;

    await _welcomeSequencer.runStep(
      TutorialSequenceStep(
        enterDuration: const Duration(milliseconds: 800),
        onEnter: () async {},
        stayDuration: const Duration(milliseconds: 1800),
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
        pauseDuration: const Duration(milliseconds: 800),
        exitDuration: Duration.zero,
      ),
    );
  }

  void _startAutoFlow() {
    if (_currentPage >= _totalSteps - 1) return;
    HapticFeedback.selectionClick();
    ref.read(analyticsServiceProvider).logOnboardingStepCompleted(
          step: 'auto_flow',
          index: 1,
          variant: _variant,
        );
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentPage = 1;
      _autoFlowRunning = true;
      _showResultStep = false;
    });
    _runAutoFlowSequence();
  }

  void _preloadScenarioLearning() {
    ref.read(conversationsByCategoryWithSubsectionsProvider.future).then((byCategory) {
      final ids = <String>[];
      for (final category in kScenarioCategories) {
        for (final sub in (byCategory[category.id] ?? [])) {
          for (final c in sub.conversations.take(3)) {
            ids.add(c.id);
            if (ids.length >= 5) break;
          }
          if (ids.length >= 5) break;
        }
        if (ids.length >= 5) break;
      }
      if (ids.isNotEmpty) {
        TtsWarmupService().warmupForConversationIds(ref, ids);
      }
    }).catchError((_) {});
  }

  Future<void> _showBridgeAndWait(String title, {String? subtitle}) async {
    if (!mounted) return;
    await EngrowthPopup.show<void>(
      context,
      variant: EngrowthPopupVariant.bridge,
      title: title,
      subtitle: subtitle,
      // 最後のボタン表示後2秒待ってから消す（contentDelay + stagger + 2秒）
      autoCloseAfter: const Duration(seconds: 5),
      secondaryLabel: '次へ',
      onSecondary: () {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      },
      analyticsVariant: 'onboarding_bridge',
      analyticsSourceScreen: 'onboarding_auto_flow',
    );
  }

  Future<void> _runAutoFlowSequence() async {
    if (!mounted) return;

    const phases = [
      _Phase.greetingBridge,
      _Phase.greetingExp,
      _Phase.quick30Bridge,
      _Phase.quick30Exp,
      _Phase.patternBridge,
      _Phase.patternExp,
      _Phase.focus3Bridge,
      _Phase.dailyBridge1,
      _Phase.dailyBridge2,
      _Phase.recordingIntro,
      _Phase.result,
    ];

    for (var i = 0; i < phases.length; i++) {
      if (!mounted || !_autoFlowRunning) return;
      _currentPhaseIndex = i;
      await _runPhase(phases[i]);
    }
  }

  Future<void> _runPhase(_Phase phase) async {
    switch (phase) {
      case _Phase.greetingBridge:
        await _showBridgeAndWait(
          'まず挨拶を体験しましょう',
          subtitle: 'AIが話しかけます。返事してみてください。',
        );
        break;
      case _Phase.greetingExp:
        ref.read(analyticsServiceProvider).logOnboardingStepCompleted(
              step: 'greeting_experience',
              index: 1,
              variant: _variant,
            );
        await _tryStepAndAdvance(
          '/tutorial-conversation?entry_source=onboarding',
        );
        await Future.delayed(const Duration(milliseconds: 1200));
        break;
      case _Phase.quick30Bridge:
        _preloadScenarioLearning();
        await _showBridgeAndWait(
          '次は30秒会話を聴いてみましょう',
          subtitle: '隙間30秒で聞く練習です。',
        );
        break;
      case _Phase.quick30Exp:
        ref.read(analyticsServiceProvider).logOnboardingStepCompleted(
              step: 'quick30',
              index: 1,
              variant: _variant,
            );
        await _tryStepAndAdvance('/scenario-learning?from_onboarding=true');
        await Future.delayed(const Duration(milliseconds: 1200));
        break;
      case _Phase.patternBridge:
        await _showBridgeAndWait(
          'パターンスクリプトを体験しましょう',
          subtitle: '聞く→録音→聴き直して提出。',
        );
        break;
      case _Phase.patternExp:
        ref.read(analyticsServiceProvider).logOnboardingStepCompleted(
              step: 'pattern_sprint',
              index: 1,
              variant: _variant,
            );
        // 一覧画面をスキップし、セッション画面へ直接遷移（一覧経由だと自動遷移が不安定）
        await _tryStepAndAdvance(
          '/pattern-sprint/session'
          '?prefix=${Uri.encodeComponent('Can I have')}'
          '&duration=30'
          '&from_onboarding=true',
        );
        await Future.delayed(const Duration(milliseconds: 1200));
        break;
      case _Phase.focus3Bridge:
        await _showBridgeAndWait(
          '3分英会話（上級モード）',
          subtitle: '音で覚えてから取り組むと、英会話の地力アップに効果的です。',
        );
        await Future.delayed(const Duration(milliseconds: 800));
        break;
      case _Phase.dailyBridge1:
        await _showBridgeAndWait(
          '今日あった出来事を、英語で録音していきます。',
        );
        break;
      case _Phase.dailyBridge2:
        await _showBridgeAndWait(
          'コンサルタントへの提出が、日々の基本的なミッションになります。',
        );
        break;
      case _Phase.recordingIntro:
        await _showMockRecordingIntroPopup();
        // ボタン押下時は onPrimary 内で結果表示するため、ここでは何もしない
        if (_mockRecordingButtonTapped) return;
        break;
      case _Phase.result:
        setState(() {
          _showResultStep = true;
          _autoFlowRunning = false;
        });
        break;
    }
  }

  Future<void> _tryStepAndAdvance(String route) async {
    final fromStep = 'auto_flow';
    final result = await context.push<LearningHandoffResult>(route);
    if (!mounted) return;
    ref.read(analyticsServiceProvider).logTutorialAutoAdvanced(
          learningMode: result?.learningMode ?? 'skipped_or_incomplete',
          fromStep: fromStep,
          toStep: 'auto_flow',
        );
  }

  Future<void> _showMockRecordingIntroPopup() async {
    if (!mounted) return;
    _mockRecordingButtonTapped = false;
    await EngrowthPopup.show<void>(
      context,
      title: '録音の準備をしましょう',
      body: const Text(
        '今日あった出来事を1つ決めて、30秒ほどで伝えてみましょう。\n\n'
        '準備ができたら「仮の録音体験をする」を押してください。',
        textAlign: TextAlign.center,
      ),
      primaryLabel: '仮の録音体験をする',
      onPrimary: () async {
        _mockRecordingButtonTapped = true;
        if (!mounted || !_autoFlowRunning) return;
        ref
            .read(analyticsServiceProvider)
            .logOnboardingMockSubmitStarted(variant: _variant);
        await _showRecordingCountdownPopup();
        if (!mounted || !_autoFlowRunning) return;
        ref.read(analyticsServiceProvider).logOnboardingMockSubmitCompleted(
              variant: _variant,
              skippedEarly: false,
            );
        if (!mounted || !_autoFlowRunning) return;
        setState(() {
          _showResultStep = true;
          _autoFlowRunning = false;
        });
      },
      analyticsVariant: 'onboarding_daily_ready',
      analyticsSourceScreen: 'onboarding_auto_flow',
    );
    if (!mounted || !_autoFlowRunning) return;
    // ボタン押下時は onPrimary 内で結果表示まで進む。外タップ等で閉じた場合はここで結果へ
    if (!_mockRecordingButtonTapped && !_showResultStep) {
      setState(() {
        _showResultStep = true;
        _autoFlowRunning = false;
      });
    }
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
      analyticsSourceScreen: 'onboarding_auto_flow',
    );
  }

  Future<void> _completeOnboarding({String? nextRoute}) async {
    HapticFeedback.mediumImpact();
    ref.read(analyticsServiceProvider).logOnboardingCompleted(
          variant: _variant,
          nextRecommendedAction:
              nextRoute != null ? 'next_learning' : 'resume_card',
        );
    ref.read(onboardingHandoffPendingProvider.notifier).state = true;
    await ref.read(onboardingCompleteNotifierProvider).markCompleted();
    if (!mounted) return;
    ref.invalidate(onboardingCompletedProvider);
    context.go(nextRoute ?? '/home');
  }

  void _skipToNextStep(int currentPhase) {
    HapticFeedback.selectionClick();
    // 現行フローでは「次のチュートリアル項目」= 結果画面と解釈し、残りフェーズをスキップして結果へ進める。
    setState(() {
      _autoFlowRunning = false;
      _showResultStep = true;
    });
    ref.read(analyticsServiceProvider).logOnboardingSkipped(
          atStep: 'phase_$currentPhase',
          variant: _variant,
        );
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
                  const SizedBox(width: 48),
                  if (!_autoFlowRunning)
                    Text(
                      '${_currentPage + 1} / $_totalSteps',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  TextButton(
                    onPressed: () {
                      if (_currentPage == 0) {
                        _startAutoFlow();
                      } else {
                        _skipToNextStep(_currentPhaseIndex);
                      }
                    },
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
                },
                children: [
                  _buildWelcomeStep(),
                  _buildAutoFlowStage(colorScheme),
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
                onPressed: _startAutoFlow,
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

  Widget _buildAutoFlowStage(ColorScheme colorScheme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _showResultStep
          ? KeyedSubtree(
              key: const ValueKey('result'),
              child: _OnboardingResultStep(
                onComplete: _completeOnboarding,
                colorScheme: colorScheme,
              ),
            )
          : KeyedSubtree(
              key: const ValueKey('empty'),
              child: Container(
                color: colorScheme.surface,
                child: const Center(
                  child: SizedBox.shrink(),
                ),
              ),
            ),
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
        final v1 =
            (3 * ((_sequenceAnim.value - 0.2) / 0.2).clamp(0.0, 1.0)).round();
        final v2 =
            (5 * ((_sequenceAnim.value - 0.4) / 0.2).clamp(0.0, 1.0)).round();
        final v3 =
            (2 * ((_sequenceAnim.value - 0.6) / 0.2).clamp(0.0, 1.0)).round();

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
                        color: widget.colorScheme.onSurfaceVariant
                            .withOpacity(0.9),
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
                        ref
                            .read(analyticsServiceProvider)
                            .logResultNextLearningTap(
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
