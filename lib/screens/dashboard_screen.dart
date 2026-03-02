import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/engrowth_theme.dart';
import '../providers/user_stats_provider.dart';
import '../providers/sentence_provider.dart';
import '../providers/conversation_practice_provider.dart';
import '../providers/user_plan_provider.dart';
import '../providers/last_study_resume_provider.dart';
import '../providers/analytics_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/role_provider.dart';
import '../providers/onboarding_provider.dart';
import '../providers/ui_experiments_provider.dart';
import '../widgets/scenario_background.dart';
import '../widgets/dashboard_sections/anonymous_data_save_banner.dart';
import '../widgets/dashboard_sections/anonymous_lp_banner.dart';
import '../widgets/dashboard_sections/coach_banner.dart';
import '../widgets/dashboard_sections/consultant_notification_banner.dart';
import '../widgets/dashboard_sections/daily_report_card.dart';
import '../widgets/dashboard_sections/onboarding_banner.dart';
import '../widgets/marquee/header_marquee_rail.dart';
import '../widgets/dashboard_sections/todays_mission_card.dart';

/// Dashboard（Home タブ）
/// ヘッダー／再開カード／4x2アイコングリッドをコンパクトに表示
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStage = ref.watch(authStageProvider);
    final userPlan = ref.watch(userPlanProvider);

    final enableMarquee = ref.watch(enableMarqueeRailProvider);

    return Scaffold(
      drawer: const _SettingsDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _DashboardHeader(),
            if (enableMarquee) ...[
              const HeaderMarqueeRail(),
              const SizedBox(height: 4),
            ],
            Expanded(
              child: SingleChildScrollView(
                primary: true,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    const OnboardingBanner(),
                    const SizedBox(height: 6),
                    if (authStage == AuthStage.anonymous) ...[
                      const AnonymousDataSaveBanner(),
                      const SizedBox(height: 6),
                    ],
                    if (userPlan == UserPlan.coaching) ...[
                      const CoachBanner(),
                      const SizedBox(height: 6),
                      const TodaysMissionCard(),
                      const SizedBox(height: 6),
                    ],
                    const DailyReportCard(),
                    const SizedBox(height: 6),
                    const _ConversationPracticeGoalCard(),
                    const SizedBox(height: 6),
                    const _OnboardingHandoffBanner(),
                    SizedBox(
                      height: 100,
                      child: const _ResumeLearningCard(),
                    ),
                    const SizedBox(height: 4),
                    const _RecommendedCard(),
                    const SizedBox(height: 4),
                    const _MainTilesGrid(),
                    const SizedBox(height: 14),
                    if (authStage == AuthStage.anonymous) ...[
                      const AnonymousLpBanner(),
                      const SizedBox(height: 6),
                    ],
                    if (authStage == AuthStage.signedIn ||
                        authStage == AuthStage.coaching) ...[
                      const ConsultantNotificationBanner(),
                      const SizedBox(height: 6),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Scaffold.of(context).openDrawer();
                  },
                  tooltip: '設定',
                  color: colorScheme.onSurface,
                ),
                const Spacer(),
                Text(
                  'Engrowth',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        color: colorScheme.onSurface,
                      ),
                ),
                const Spacer(),
                statsAsync.when(
                  data: (stats) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '\u{1F525}',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${stats.streakCount}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox(width: 40, height: 24),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('\u{1F525}', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 4),
                        Text(
                          '0',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant,
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
    );
  }
}

class _ConversationPracticeGoalCard extends ConsumerWidget {
  const _ConversationPracticeGoalCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turnsAsync = ref.watch(todayConversationTurnsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final achieved = turnsAsync.valueOrNull != null &&
        turnsAsync.valueOrNull! >= dailyConversationGoalTurns;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          if (achieved) {
            context.push('/progress');
          } else {
            context.push('/conversations');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.smart_toy,
                size: 28,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '今日の会話目標',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    turnsAsync.when(
                      data: (turns) {
                        final remaining = (dailyConversationGoalTurns - turns).clamp(0, dailyConversationGoalTurns);
                        final isAchieved = turns >= dailyConversationGoalTurns;
                        final text = isAchieved
                            ? '目標達成！タップで進捗を確認'
                            : 'あと$remainingターンで目標達成（$turns / $dailyConversationGoalTurns）';
                        final sub = isAchieved
                            ? null
                            : 'タップして会話学習を始める';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              text,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                            if (sub != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                sub,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.primary.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                      loading: () => Text(
                        'AIと会話して英語を練習',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      error: (_, __) => Text(
                        'AIと会話して英語を練習',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendedCard extends ConsumerWidget {
  const _RecommendedCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendedAsync = ref.watch(recommendedSentenceProvider);
    return recommendedAsync.when(
      data: (sentence) {
        if (sentence == null) return const SizedBox.shrink();
        final preview = sentence.englishText.length > 30
            ? '${sentence.englishText.substring(0, 30)}...'
            : sentence.englishText;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              context.push('/study?sentenceId=${sentence.id}');
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                boxShadow: Theme.of(context).brightness == Brightness.dark
                    ? null
                    : EngrowthShadows.softCard,
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '次に学習: $preview',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      context.push('/study?sentenceId=${sentence.id}');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '学習を始める',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _OnboardingHandoffBanner extends ConsumerStatefulWidget {
  const _OnboardingHandoffBanner();

  @override
  ConsumerState<_OnboardingHandoffBanner> createState() =>
      _OnboardingHandoffBannerState();
}

class _OnboardingHandoffBannerState extends ConsumerState<_OnboardingHandoffBanner> {
  bool _hasLoggedShown = false;

  @override
  Widget build(BuildContext context) {
    final handoffPending = ref.watch(onboardingHandoffPendingProvider);
    if (!handoffPending) return const SizedBox.shrink();

    if (!_hasLoggedShown) {
      _hasLoggedShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(analyticsServiceProvider).logOnboardingHomeHandoffShown();
      });
    }

    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.primary.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.touch_app, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '次は下の「続きから再開」をタップして学習を始めよう',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumeLearningCard extends ConsumerWidget {
  const _ResumeLearningCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumeState = ref.watch(lastStudyResumeProvider);
    final recommendedAsync = ref.watch(recommendedSentenceProvider);
    final hasResume = resumeState.sentenceId != null;
    final handoffPending = ref.watch(onboardingHandoffPendingProvider);

    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            if (handoffPending) {
              ref.read(analyticsServiceProvider).logOnboardingHomeHandoffTapped(
                    target: 'resume_card',
                  );
              ref.read(onboardingHandoffPendingProvider.notifier).state = false;
            }
            ref.read(analyticsServiceProvider).logResumeCardTap(
                  source: hasResume ? 'resume' : 'recommended',
                );
            if (hasResume) {
              context.push('/study?sentenceId=${resumeState.sentenceId}');
            } else {
              final sentence = recommendedAsync.valueOrNull;
              if (sentence != null) {
                context.push('/study?sentenceId=${sentence.id}');
              } else {
                context.push('/study');
              }
            }
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: Theme.of(context).brightness == Brightness.dark
                  ? null
                  : EngrowthShadows.softCard,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    kScenarioBgAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Theme.of(context).colorScheme.surface),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasResume ? '続きから再開' : '前回の学習を再開',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasResume
                                ? '1タップで続きから'
                                : recommendedAsync.valueOrNull != null
                                    ? '1タップで学習開始'
                                    : 'ここに成長が記録されます。タップして始めよう',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
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
      );
  }
}

class _MainTilesGrid extends ConsumerWidget {
  const _MainTilesGrid();

  static const _baseItems = [
    _GridItem('会話トレーニング', Icons.record_voice_over, '/conversation-training'),
    _GridItem('単語検索', Icons.search, '/words'),
    _GridItem('パターンスプリント', Icons.speed, '/pattern-sprint'),
    _GridItem('センテンス一覧', Icons.format_list_bulleted, '/sentences'),
    _GridItem('学習進捗', Icons.bar_chart, '/progress'),
    _GridItem('お気に入り', Icons.favorite_border, '/favorites'),
    _GridItem('本日の復習', Icons.history, '/review'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStage = ref.watch(authStageProvider);
    final showRecordings =
        authStage == AuthStage.signedIn || authStage == AuthStage.coaching;
    final items = [
      ..._baseItems,
      if (showRecordings) const _GridItem('録音履歴', Icons.mic, '/recordings'),
      const _GridItem('設定', Icons.settings, 'drawer'),
    ];
    final width = MediaQuery.of(context).size.width - 24;
    final tileWidth = (width - 12) / 4;
    final tileHeight = tileWidth / 0.9;

    return SizedBox(
      height: tileHeight * 2 + 12,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 0.9,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _MainTile(
            title: item.title,
            icon: item.icon,
            onTap: () {
              HapticFeedback.selectionClick();
              if (item.route == 'drawer') {
                Scaffold.of(context).openDrawer();
              } else if (item.route == '/progress' || item.route == '/words') {
                context.go(item.route);
              } else if (item.route == '/sentences') {
                context.push(item.route);
              } else if (item.route == '/favorites') {
                context.push('/favorites');
              } else if (item.route == '/recordings') {
                context.push('/recordings');
              } else {
                context.push(item.route);
              }
            },
          );
        },
      ),
    );
  }
}

class _GridItem {
  final String title;
  final IconData icon;
  final String route;

  const _GridItem(this.title, this.icon, this.route);
}

class _MainTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MainTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            boxShadow: Theme.of(context).brightness == Brightness.dark
                ? null
                : EngrowthShadows.softCard,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsDrawer extends ConsumerWidget {
  const _SettingsDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devViewAsSignedIn = ref.watch(devViewAsSignedInProvider);
    final authStage = ref.watch(authStageProvider);
    final isConsultant = ref.watch(isConsultantProvider).valueOrNull ?? false;
    final isAdmin = ref.watch(isAdminProvider);

    final isSignedIn =
        authStage == AuthStage.signedIn || authStage == AuthStage.coaching;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                '設定',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (kDebugMode) ...[
              SwitchListTile(
                secondary: const Icon(Icons.bug_report_outlined),
                title: const Text('開発: ログイン済み画面'),
                subtitle: const Text('匿名のままログイン後UIを表示'),
                value: devViewAsSignedIn,
                onChanged: (_) {
                  ref.read(devViewAsSignedInProvider.notifier).toggle();
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.person_search_outlined),
                title: const Text('開発: コンサルタント'),
                subtitle: const Text('講師用メニューを表示'),
                value: ref.watch(devViewAsConsultantProvider),
                onChanged: (_) {
                  ref.read(devViewAsConsultantProvider.notifier).toggle();
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.admin_panel_settings_outlined),
                title: const Text('開発: 管理者'),
                subtitle: const Text('管理者メニューを表示'),
                value: ref.watch(devViewAsAdminProvider),
                onChanged: (_) {
                  ref.read(devViewAsAdminProvider.notifier).toggle();
                },
              ),
              ListTile(
                leading: const Icon(Icons.school_outlined),
                title: const Text('開発: 初回体験をリセット'),
                subtitle: const Text('初回体験フローを再表示'),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(onboardingCompleteNotifierProvider).reset();
                  ref.invalidate(onboardingCompletedProvider);
                  if (context.mounted) context.push('/onboarding');
                },
              ),
              const Divider(),
            ],
            if (!isSignedIn)
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('データ保存について'),
                onTap: () {
                  Navigator.pop(context);
                  _showDataSaveInfo(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(isSignedIn ? 'アカウント' : 'アカウント作成'),
              onTap: () {
                Navigator.pop(context);
                context.push('/account');
              },
            ),
            if (isSignedIn)
              ListTile(
                leading: const Icon(Icons.mic),
                title: const Text('録音履歴'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/recordings');
                },
              ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('2秒ヒントの秒数設定'),
              onTap: () {
                Navigator.pop(context);
                context.push('/hint-settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('音声再生速度'),
              onTap: () {
                Navigator.pop(context);
                context.push('/playback-speed-settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('使い方'),
              onTap: () {
                Navigator.pop(context);
                context.push('/help');
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_stories_outlined),
              title: const Text('Engrowthが選ばれる理由'),
              onTap: () {
                Navigator.pop(context);
                context.push('/concept');
              },
            ),
            if (isSignedIn)
              ListTile(
                leading: const Icon(Icons.contact_support_outlined),
                title: const Text('担当コンサルタントへ連絡'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: メッセージ画面
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('この機能は準備中です')),
                  );
                },
              ),
            if (isConsultant) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.record_voice_over),
                title: const Text('講師用ダッシュボード'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/consultant');
                },
              ),
            ],
            if (isAdmin) ...[
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('管理者ダッシュボード'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/admin');
                },
              ),
            ],
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
              title: Text(
                'ログアウト',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _handleLogout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDataSaveInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('データ保存について'),
        content: const Text(
          '学習記録を永続的に保存するにはアカウントの作成が必要です。\n\n'
          'アカウント作成後は、録音履歴・学習進捗・復習データを複数端末で同期して利用できます。',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('閉じる'),
          ),
          FilledButton(
            onPressed: () {
              context.push('/account');
              Navigator.of(ctx).pop();
            },
            child: const Text('アカウント作成'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        // 必要であればログイン画面へ
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ログアウトに失敗しました: $e')),
        );
      }
    }
  }
}
