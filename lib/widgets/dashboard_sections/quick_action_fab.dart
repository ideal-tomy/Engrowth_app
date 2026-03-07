import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/sentence.dart';
import '../../providers/sentence_provider.dart';
import '../../providers/conversation_practice_provider.dart'
    show dailyConversationGoalTurns, todayConversationTurnsProvider;
import '../../providers/last_study_resume_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/home_primary_cta_provider.dart';
import '../../providers/resume_card_tap_context_provider.dart';
import '../../theme/engrowth_theme.dart';

/// ホーム右下のFAB展開型クイックアクション
/// 匿名: 挨拶体験 / 学習開始 / アカウント作成
/// ログイン: 続きから再開 / 今日の会話目標 / 次に学習
class QuickActionFab extends ConsumerStatefulWidget {
  const QuickActionFab({super.key});

  @override
  ConsumerState<QuickActionFab> createState() => _QuickActionFabState();
}

class _QuickActionFabState extends ConsumerState<QuickActionFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: EngrowthElementTokens.switchDuration,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      ref.read(analyticsServiceProvider).logHomeQuickFabOpened();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStage = ref.watch(authStageProvider);
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);
    final recommended = ref.watch(recommendedSentenceProvider);
    final isAnonymous = authStage == AuthStage.anonymous;

    final actions = isAnonymous
        ? _buildAnonymousActions(onboardingCompleted)
        : _buildSignedInActions(recommended.valueOrNull);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: 1,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: actions
                  .asMap()
                  .entries
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _QuickActionChip(
                        icon: e.value.icon,
                        label: e.value.label,
                        onTap: () {
                          _controller.reverse();
                          e.value.onTap();
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          onPressed: _toggle,
          heroTag: 'quick_action_fab',
          child: AnimatedRotation(
            turns: _controller.isCompleted ? 0.125 : 0,
            duration: EngrowthElementTokens.switchDuration,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  List<_QuickAction> _buildAnonymousActions(AsyncValue<bool> onboardingCompleted) {
    final completed = onboardingCompleted.valueOrNull ?? false;
    final actions = <_QuickAction>[];

    if (!completed) {
      actions.add(_QuickAction(
        icon: Icons.school_outlined,
        label: '挨拶体験',
        onTap: () => _handleOnboardingTap(),
      ));
    }

    actions.add(_QuickAction(
      icon: Icons.play_arrow,
      label: '学習を始める',
      onTap: () => _handleResumeOrRecommendedTap(),
    ));

    actions.add(_QuickAction(
      icon: Icons.person_add_outlined,
      label: 'アカウント作成',
      onTap: () => _handleAccountTap(),
    ));

    return actions;
  }

  List<_QuickAction> _buildSignedInActions(Sentence? recommended) {
    final actions = <_QuickAction>[
      _QuickAction(
        icon: Icons.replay,
        label: '続きから再開',
        onTap: () => _handleResumeOrRecommendedTap(),
      ),
      _QuickAction(
        icon: Icons.smart_toy_outlined,
        label: '今日の会話目標',
        onTap: () => _handleConversationGoalTap(),
      ),
    ];
    if (recommended != null) {
      actions.add(_QuickAction(
        icon: Icons.lightbulb_outline,
        label: '次に学習',
        onTap: () => _handleRecommendedTap(),
      ));
    }
    return actions;
  }

  void _handleOnboardingTap() {
    ref.read(analyticsServiceProvider).logHomeQuickActionTapped(actionType: 'onboarding');
    ref.read(analyticsServiceProvider).logOnboardingEntryTapped(variant: 'v2');
    context.push('/onboarding');
  }

  void _handleAccountTap() {
    ref.read(analyticsServiceProvider).logHomeQuickActionTapped(actionType: 'account');
    context.push('/account');
  }

  Future<void> _handleResumeOrRecommendedTap() async {
    ref.read(analyticsServiceProvider).logHomeQuickActionTapped(actionType: 'resume');
    ref.read(homePrimaryCtaProvider.notifier).maybeRecordRecognized('resume_card');

    final handoffPending = ref.read(onboardingHandoffPendingProvider);
    if (handoffPending) {
      ref.read(analyticsServiceProvider).logOnboardingHomeHandoffTapped(
            target: 'resume_card',
          );
      ref.read(onboardingHandoffPendingProvider.notifier).state = false;
    }

    var resumeState = ref.read(lastStudyResumeProvider);
    if (!resumeState.isLoaded) {
      await ref.read(lastStudyResumeProvider.notifier).ensureLoaded();
      resumeState = ref.read(lastStudyResumeProvider);
      if (resumeState.sentenceId != null) {
        ref.read(analyticsServiceProvider).logResumeCardTap(source: 'resume');
        ref.read(analyticsServiceProvider).logResumeResolution(resolution: 'resume');
        ref.read(resumeCardTapContextProvider.notifier).record('resume_card');
        if (!context.mounted) return;
        context.push(
          '/study?sentenceId=${resumeState.sentenceId}&entrySource=resume_card',
        );
        return;
      }
    }

    final sentence = ref.read(recommendedSentenceProvider).valueOrNull;
    final effectiveHasResume = resumeState.sentenceId != null;
    final resolution = effectiveHasResume
        ? 'resume'
        : (sentence != null ? 'recommended_fallback' : 'plain_fallback');
    final entrySource = effectiveHasResume
        ? 'resume_card'
        : (sentence != null ? 'recommended_fallback' : 'plain_fallback');

    ref.read(analyticsServiceProvider).logResumeCardTap(
          source: effectiveHasResume ? 'resume' : 'recommended',
        );
    ref.read(analyticsServiceProvider).logResumeResolution(resolution: resolution);
    ref.read(resumeCardTapContextProvider.notifier).record(entrySource);

    final uri = Uri.parse('/study').replace(
      queryParameters: {
        if (effectiveHasResume) 'sentenceId': resumeState.sentenceId!,
        if (!effectiveHasResume && sentence != null) 'sentenceId': sentence.id,
        'entrySource': entrySource,
      },
    );
    if (!context.mounted) return;
    context.push(uri.toString());
  }

  void _handleConversationGoalTap() {
    ref.read(analyticsServiceProvider).logHomeQuickActionTapped(actionType: 'goal');
    final turns = ref.read(todayConversationTurnsProvider).valueOrNull ?? 0;
    final achieved = turns >= dailyConversationGoalTurns;
    if (achieved) {
      context.push('/progress');
    } else {
      context.push('/conversations');
    }
  }

  void _handleRecommendedTap() {
    ref.read(analyticsServiceProvider).logHomeQuickActionTapped(actionType: 'recommended');
    final sentence = ref.read(recommendedSentenceProvider).valueOrNull;
    if (sentence == null) return;
    ref.read(homePrimaryCtaProvider.notifier).maybeRecordRecognized('recommended_card');
    context.push('/study?sentenceId=${sentence.id}');
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
