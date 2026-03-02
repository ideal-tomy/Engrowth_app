import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/analytics_provider.dart';
import '../providers/onboarding_provider.dart';
import '../theme/engrowth_theme.dart';

/// 初回体験フロー
/// 30秒会話・パターンスクリプト・3分会話・録音提出の順で操作を案内
class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalSteps = 7;

  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).logOnboardingStarted(step: 'welcome');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentPage >= _totalSteps - 1) return;
    HapticFeedback.selectionClick();
    ref.read(analyticsServiceProvider).logOnboardingStepCompleted(
          step: _stepId(_currentPage + 1),
          index: _currentPage + 1,
        );
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage++);
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

  Future<void> _tryStepAndAdvance(String route) async {
    HapticFeedback.selectionClick();
    await context.push(route);
    if (!mounted) return;
    _goToNext();
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    ref.read(analyticsServiceProvider).logOnboardingCompleted();
    await ref.read(onboardingCompleteNotifierProvider).markCompleted();
    if (!mounted) return;
    ref.invalidate(onboardingCompletedProvider);
    context.go('/home');
  }

  Future<void> _skipOnboarding() async {
    HapticFeedback.selectionClick();
    ref.read(analyticsServiceProvider).logOnboardingSkipped(atStep: _stepId(_currentPage));
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
                onPageChanged: (i) => setState(() => _currentPage = i),
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
            'このアプリは「聞いて→まねして→使う」で\n会話感覚を育てます。\n\n毎日、今日の出来事を英語で話して\nコンサルタントに報告する日課が中心です。',
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
            'AIが英語で話しかけます。\nマイクで返事をすると、返答が返ってきます。\n聞いて→話して→返答を体験しましょう。',
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
              onPressed: () => _tryStepAndAdvance('/tutorial-conversation'),
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
          TextButton(
            onPressed: _goToNext,
            child: const Text('あとで体験する'),
          ),
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
            '隙間時間に、短い会話を聞く練習です。\nまずは聞くだけでOK。',
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
              onPressed: () => _tryStepAndAdvance('/scenario-learning'),
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
          TextButton(
            onPressed: _goToNext,
            child: const Text('あとで体験する'),
          ),
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
            'お手本を聞いたら、録音ボタンで\n自分の声を録音します。\n聴き直して「先生に送る」で提出できます。',
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
              onPressed: () => _tryStepAndAdvance('/pattern-sprint'),
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
          TextButton(
            onPressed: _goToNext,
            child: const Text('あとで体験する'),
          ),
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
            '3分会話',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            '約3分の会話を聞いて、役になりきって練習。\n「次へ」で進みます。',
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
              onPressed: () => _tryStepAndAdvance('/story-training'),
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
          TextButton(
            onPressed: _goToNext,
            child: const Text('あとで体験する'),
          ),
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
          Icon(Icons.send, size: 64, color: colorScheme.primary),
          const SizedBox(height: 20),
          Text(
            '録音を先生に送る',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            '録音履歴から「先生に送る」をタップすると\n担当コンサルタントに共有されます。\nフィードバックが届きます。',
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
              onPressed: () => _tryStepAndAdvance('/recordings'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('録音履歴を見る'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _goToNext,
            child: const Text('あとで確認する'),
          ),
        ],
      ),
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

/// 結果表示ステップ（アニメーション付き）
class _OnboardingResultStep extends StatefulWidget {
  final VoidCallback onComplete;
  final ColorScheme colorScheme;

  const _OnboardingResultStep({
    required this.onComplete,
    required this.colorScheme,
  });

  @override
  State<_OnboardingResultStep> createState() => _OnboardingResultStepState();
}

class _OnboardingResultStepState extends State<_OnboardingResultStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animProgress;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 72,
            color: EngrowthColors.success,
          ),
          const SizedBox(height: 20),
          Text(
            '体験完了！',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _animProgress,
            builder: (context, child) {
              final p = _animProgress.value;
              return Column(
                children: [
                  _ResultRow(
                    label: '学習時間',
                    value: (3 * p).round(),
                    suffix: '分',
                    colorScheme: widget.colorScheme,
                  ),
                  const SizedBox(height: 12),
                  _ResultRow(
                    label: '話した文章',
                    value: (5 * p).round(),
                    suffix: '文',
                    colorScheme: widget.colorScheme,
                  ),
                  const SizedBox(height: 12),
                  _ResultRow(
                    label: '新しい単語',
                    value: (2 * p).round(),
                    suffix: '語',
                    colorScheme: widget.colorScheme,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'アカウントを作成すると、録音の保存・進捗・連続日数が記録されます。',
            style: TextStyle(
              fontSize: 13,
              color: widget.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.onComplete,
              style: FilledButton.styleFrom(
                backgroundColor: EngrowthColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('ホームへ'),
            ),
          ),
        ],
      ),
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
