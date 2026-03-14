import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/engrowth_theme.dart';
import '../screens/dashboard_screen.dart';
import '../screens/library_hub_screen.dart';
import '../screens/word_list_screen.dart';
import '../screens/sentence_list_screen.dart';
import '../screens/study_screen.dart';
import '../screens/pattern_sprint_list_screen.dart';
import '../screens/pattern_sprint_session_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/hint_settings_screen.dart';
import '../screens/playback_speed_settings_screen.dart';
import '../screens/account_screen.dart';
import '../screens/scenario_list_screen.dart';
import '../screens/scenario_study_screen.dart';
import '../screens/conversation_list_screen.dart';
import '../screens/conversation_study_screen.dart';
import '../screens/scenario_learning_screen.dart';
import '../screens/conversation_training_choice_screen.dart';
import '../screens/story_study_screen.dart';
import '../screens/story_training_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/consultant_dashboard_screen.dart';
import '../screens/recording_history_screen.dart';
import '../screens/scenario_progress_board_screen.dart';
import '../screens/story_progress_board_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/consultant_contact_screen.dart';
import '../screens/review_list_screen.dart';
import '../screens/onboarding_flow_screen.dart';
import '../screens/tutorial_conversation_screen.dart';
import '../screens/unified_result_screen.dart';
import '../screens/help_screen.dart';
import '../screens/concept_screen.dart';
import '../screens/guided_flow_demo_screen.dart';
import '../providers/ui_experiments_provider.dart';
import '../widgets/marquee/bottom_recommendation_rail.dart';

/// standardPush: 学習系詳細（fade + slightSlide）
/// 220ms / reverse 180ms
Page<void> _standardPushPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: EngrowthRouteTokens.standardPushDuration,
    reverseTransitionDuration: EngrowthRouteTokens.standardPushReverseDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // フェードアウトを早く: opacity を前半で完了 → 前ページの残り時間短縮
      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Interval(
          0,
          EngrowthRouteTokens.standardPushFadeIntervalEnd,
          curve: EngrowthRouteTokens.standardPushFadeIntervalCurve,
        ),
      );
      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, EngrowthRouteTokens.standardPushSlideOffset),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: EngrowthRouteTokens.standardPushCurve,
          )),
          child: child,
        ),
      );
    },
  );
}

/// slowPush: ガイドフロー体感デモ用（本番と同速でデモ画面へ遷移）
Page<void> _slowPushPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  final duration = EngrowthRouteTokens.standardPushDuration;
  final reverseDuration = EngrowthRouteTokens.standardPushReverseDuration;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: reverseDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Interval(
          0,
          EngrowthRouteTokens.standardPushFadeIntervalEnd,
          curve: EngrowthRouteTokens.standardPushFadeIntervalCurve,
        ),
      );
      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, EngrowthRouteTokens.standardPushSlideOffset),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: EngrowthRouteTokens.standardPushCurve,
          )),
          child: child,
        ),
      );
    },
  );
}

/// modalPush: 設定/補助導線（fade + upFromBottom）
Page<void> _modalPushPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: EngrowthRouteTokens.modalPushDuration,
    reverseTransitionDuration: EngrowthRouteTokens.modalPushReverseDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Interval(
          0,
          EngrowthRouteTokens.modalPushFadeIntervalEnd,
          curve: EngrowthRouteTokens.modalPushFadeIntervalCurve,
        ),
      );
      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, EngrowthRouteTokens.modalPushSlideOffset),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: EngrowthRouteTokens.modalPushCurve,
          )),
          child: child,
        ),
      );
    },
  );
}

/// resultPush: リザルト画面（fade + scale）
Page<void> _resultPushPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: EngrowthRouteTokens.resultPushDuration,
    reverseTransitionDuration: EngrowthRouteTokens.resultPushReverseDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Interval(
          0,
          EngrowthRouteTokens.resultPushFadeIntervalEnd,
          curve: EngrowthRouteTokens.resultPushFadeIntervalCurve,
        ),
      );
      return FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: EngrowthRouteTokens.resultPushScaleBegin,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: EngrowthRouteTokens.resultPushCurve,
          )),
          child: child,
        ),
      );
    },
  );
}

/// tutorialCrossfade: チュートリアル導線専用（5倍水準のゆっくりクロスフェード）
Page<void> _tutorialCrossfadePage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: EngrowthRouteTokens.tutorialCrossfadeDuration,
    reverseTransitionDuration: EngrowthRouteTokens.tutorialCrossfadeReverseDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: EngrowthRouteTokens.standardPushCurve,
      );
      return FadeTransition(
        opacity: fadeAnimation,
        child: child,
      );
    },
  );
}

/// 導線ポリシー:
/// - タブルート直下（/home, /library, /progress, /words）: 戻る矢印なし
/// - push で開く詳細/設定画面: 戻る矢印あり（GoRouterの自動 leading に任せる）
/// - タブ切り替え: context.go('/tabPath')
/// - 詳細・設定・学習画面へ: context.push('/path')
/// - モーダル（全画面シート）: close アイコンで終了
final appRouter = GoRouter(
  initialLocation: '/home',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    if (state.matchedLocation == '/consultant' && session == null) {
      return '/home';
    }
    if (state.matchedLocation == '/admin' && session == null) {
      return '/home';
    }
    return null;
  },
  routes: [
    // メイン4タブ: Home / Library / Stats / Search
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              builder: (context, state) => const LibraryHubScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/progress',
              builder: (context, state) => const ProgressScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/words',
              builder: (context, state) {
                final focusSearch =
                    state.uri.queryParameters['focus'] == 'search';
                return WordListScreen(initialFocusSearch: focusSearch);
              },
            ),
          ],
        ),
      ],
    ),
    // その他のルート（モーダル/プッシュ）
    GoRoute(
      path: '/guided-flow-demo',
      pageBuilder: (context, state) => _slowPushPage(
        context: context,
        state: state,
        child: const GuidedFlowDemoScreen(),
      ),
    ),
    GoRoute(
      path: '/hint-settings',
      pageBuilder: (context, state) => _modalPushPage(
        context: context,
        state: state,
        child: const ScaffoldWithPersistentNavBar(child: HintSettingsScreen()),
      ),
    ),
    GoRoute(
      path: '/playback-speed-settings',
      pageBuilder: (context, state) => _modalPushPage(
        context: context,
        state: state,
        child: const ScaffoldWithPersistentNavBar(child: PlaybackSpeedSettingsScreen()),
      ),
    ),
    GoRoute(
      path: '/pattern-sprint',
      pageBuilder: (context, state) {
        final fromOnboarding =
            state.uri.queryParameters['from_onboarding'] == 'true';
        final pageBuilder = fromOnboarding ? _tutorialCrossfadePage : _standardPushPage;
        final screen = PatternSprintListScreen(fromOnboarding: fromOnboarding);
        return pageBuilder(
          context: context,
          state: state,
          child: fromOnboarding ? screen : ScaffoldWithPersistentNavBar(child: screen),
        );
      },
      routes: [
        GoRoute(
          path: 'session',
          pageBuilder: (context, state) {
            final prefix = state.uri.queryParameters['prefix'] ?? '';
            final duration = int.tryParse(state.uri.queryParameters['duration'] ?? '45') ?? 45;
            final fromOnboarding =
                state.uri.queryParameters['from_onboarding'] == 'true';
            final pageBuilder = fromOnboarding ? _tutorialCrossfadePage : _standardPushPage;
            return pageBuilder(
              context: context,
              state: state,
          child: PatternSprintSessionScreen(
                  prefix: Uri.decodeComponent(prefix),
                  durationSec: duration.clamp(30, 60),
                  fromOnboarding: fromOnboarding,
                ),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/study',
      pageBuilder: (context, state) {
        final sentenceId = state.uri.queryParameters['sentenceId'];
        final sessionMode = state.uri.queryParameters['sessionMode'] ??
            state.uri.queryParameters['mode'];
        final entrySource = state.uri.queryParameters['entrySource'];
        return _standardPushPage(
          context: context,
          state: state,
          child: StudyScreen(
              initialSentenceId: sentenceId,
              initialSessionModeParam: sessionMode,
              initialEntrySource: entrySource,
            ),
        );
      },
    ),
    GoRoute(
      path: '/sentences',
      pageBuilder: (context, state) => _standardPushPage(
        context: context,
        state: state,
        child: ScaffoldWithPersistentNavBar(
          child: SentenceListScreen(
            initialWord: state.uri.queryParameters['word'],
          ),
        ),
      ),
    ),
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) => _standardPushPage(
        context: context,
        state: state,
        child: const ScaffoldWithPersistentNavBar(child: WordListScreen(initialFocusSearch: true)),
      ),
    ),
    GoRoute(
      path: '/account',
      pageBuilder: (context, state) => _modalPushPage(
        context: context,
        state: state,
        child: ScaffoldWithPersistentNavBar(
          child: AccountScreen(
            initialProvider: state.uri.queryParameters['provider'],
          ),
        ),
      ),
    ),
    GoRoute(
      path: '/scenarios',
      pageBuilder: (context, state) => _standardPushPage(
        context: context,
        state: state,
        child: const ScaffoldWithPersistentNavBar(child: ScenarioListScreen()),
      ),
    ),
    GoRoute(
      path: '/conversation-training',
      pageBuilder: (context, state) => _standardPushPage(
        context: context,
        state: state,
        child: const ScaffoldWithPersistentNavBar(child: ConversationTrainingChoiceScreen()),
      ),
    ),
    GoRoute(
      path: '/scenario-learning',
      pageBuilder: (context, state) {
        final fromOnboarding =
            state.uri.queryParameters['from_onboarding'] == 'true';
        final pageBuilder = fromOnboarding ? _tutorialCrossfadePage : _standardPushPage;
        final screen = ScenarioLearningScreen(fromOnboarding: fromOnboarding);
        return pageBuilder(
          context: context,
          state: state,
          child: fromOnboarding ? screen : ScaffoldWithPersistentNavBar(child: screen),
        );
      },
    ),
    GoRoute(
      path: '/story-training',
      pageBuilder: (context, state) {
        final fromOnboarding =
            state.uri.queryParameters['from_onboarding'] == 'true';
        return _standardPushPage(
          context: context,
          state: state,
          child: fromOnboarding
              ? StoryTrainingScreen(fromOnboarding: fromOnboarding)
              : ScaffoldWithPersistentNavBar(
                  child: StoryTrainingScreen(fromOnboarding: fromOnboarding),
                ),
        );
      },
    ),
    GoRoute(
      path: '/scenario/:id',
      pageBuilder: (context, state) => _standardPushPage(
        context: context,
        state: state,
        child: ScenarioStudyScreen(scenarioId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/conversations',
      pageBuilder: (context, state) => _standardPushPage(
        context: context,
        state: state,
        child: ScaffoldWithPersistentNavBar(
          child: ConversationListScreen(
            situationType: state.uri.queryParameters['type'],
          ),
        ),
      ),
    ),
    GoRoute(
      path: '/favorites',
      pageBuilder: (context, state) => _standardPushPage(
        context: context,
        state: state,
        child: const ScaffoldWithPersistentNavBar(child: FavoritesScreen()),
      ),
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) => _standardPushPage(
        context: context,
        state: state,
        child: const ScaffoldWithPersistentNavBar(child: NotificationsScreen()),
      ),
    ),
    GoRoute(
      path: '/consultant-contact',
      pageBuilder: (context, state) => _standardPushPage(
        context: context,
        state: state,
        child: ScaffoldWithPersistentNavBar(
          child: ConsultantContactScreen(
            initialReportType: state.uri.queryParameters['reportType'],
            relatedSubmissionId: state.uri.queryParameters['submissionId'],
          ),
        ),
      ),
    ),
    GoRoute(
      path: '/review',
      pageBuilder: (context, state) => _standardPushPage(
        context: context,
        state: state,
        child: const ScaffoldWithPersistentNavBar(child: ReviewListScreen()),
      ),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => _tutorialCrossfadePage(
        context: context,
        state: state,
        child: const OnboardingFlowScreen(),
      ),
    ),
    GoRoute(
      path: '/result',
      pageBuilder: (context, state) {
        final flow = state.uri.queryParameters['flow'] ?? 'study';
        final title = state.uri.queryParameters['title'] ?? 'セッション完了！';
        final subtitle = state.uri.queryParameters['subtitle'];
        final count = int.tryParse(state.uri.queryParameters['count'] ?? '');
        final countSuffix = state.uri.queryParameters['countSuffix'] ?? '問';
        final sessionMode = state.uri.queryParameters['sessionMode'];
        final primaryRoute = sessionMode != null
            ? '/study?sessionMode=$sessionMode'
            : state.uri.queryParameters['primaryRoute'];
        final primaryCtaLabel =
            state.uri.queryParameters['primaryCtaLabel'] ?? 'もう1セット続ける';
        return _resultPushPage(
          context: context,
          state: state,
          child: UnifiedResultScreen(
              flow: flow,
              title: title,
              subtitle: subtitle,
              count: count,
              countSuffix: countSuffix,
              primaryRoute: primaryRoute,
              primaryCtaLabel: primaryCtaLabel,
            ),
        );
      },
    ),
    GoRoute(
      path: '/tutorial-conversation',
      pageBuilder: (context, state) {
        final entrySource = state.uri.queryParameters['entry_source'] ?? 'direct';
        final useTutorialTransition = entrySource == 'onboarding';
        final pageBuilder = useTutorialTransition ? _tutorialCrossfadePage : _standardPushPage;
        return pageBuilder(
          context: context,
          state: state,
          child: TutorialConversationScreen(entrySource: entrySource),
        );
      },
    ),
    GoRoute(
      path: '/help',
      pageBuilder: (context, state) => _standardPushPage(
        context: context,
        state: state,
        child: const ScaffoldWithPersistentNavBar(child: HelpScreen()),
      ),
    ),
    GoRoute(
      path: '/concept',
      pageBuilder: (context, state) => _standardPushPage(
        context: context,
        state: state,
        child: const ScaffoldWithPersistentNavBar(child: ConceptScreen()),
      ),
    ),
    GoRoute(
      path: '/recordings',
      pageBuilder: (context, state) => _standardPushPage(
        context: context,
        state: state,
        child: ScaffoldWithPersistentNavBar(
          child: RecordingHistoryScreen(
            initialTab: state.uri.queryParameters['tab'],
          ),
        ),
      ),
    ),
    GoRoute(
      path: '/admin',
      pageBuilder: (context, state) => _standardPushPage(
        context: context,
        state: state,
        child: const ScaffoldWithPersistentNavBar(child: AdminDashboardScreen()),
      ),
    ),
    GoRoute(
      path: '/consultant',
      pageBuilder: (context, state) => _standardPushPage(
        context: context,
        state: state,
        child: const ScaffoldWithPersistentNavBar(child: ConsultantDashboardScreen()),
      ),
    ),
    GoRoute(
      path: '/conversation/:id',
      pageBuilder: (context, state) {
        final fromOnboarding =
            state.uri.queryParameters['from_onboarding'] == 'true';
        return _standardPushPage(
          context: context,
          state: state,
          child: ConversationStudyScreen(
              conversationId: state.pathParameters['id']!,
              initialMode: state.uri.queryParameters['mode'] ?? 'listen',
              fromOnboarding: fromOnboarding,
            ),
        );
      },
    ),
    GoRoute(
      path: '/story/:id',
      pageBuilder: (context, state) {
        final fromOnboarding =
            state.uri.queryParameters['from_onboarding'] == 'true';
        return _standardPushPage(
          context: context,
          state: state,
          child: StoryStudyScreen(
              storyId: state.pathParameters['id']!,
              fromOnboarding: fromOnboarding,
              autoStartPlayback: fromOnboarding,
            ),
        );
      },
    ),
    GoRoute(
      path: '/progress/scenario-board',
      pageBuilder: (context, state) {
        final extra = state.extra;
        return _standardPushPage(
          context: context,
          state: state,
          child: ScaffoldWithPersistentNavBar(
            child: ScenarioProgressBoardScreen(
              scrollToNext: extra is Map && (extra as Map<String, dynamic>)['scrollToNext'] == true,
            ),
          ),
        );
      },
    ),
    GoRoute(
      path: '/progress/story-board',
      pageBuilder: (context, state) {
        final extra = state.extra;
        return _standardPushPage(
          context: context,
          state: state,
          child: ScaffoldWithPersistentNavBar(
            child: StoryProgressBoardScreen(
              scrollToNext: extra is Map && (extra as Map<String, dynamic>)['scrollToNext'] == true,
            ),
          ),
        );
      },
    ),
    GoRoute(
      path: '/',
      redirect: (context, state) => '/home',
    ),
  ],
);

/// 現在パスからフッターの選択インデックスを算出（タブ以外は 0）
int _pathToNavIndex(String path) {
  if (path.startsWith('/home') || path == '/') return 0;
  if (path.startsWith('/library')) return 1;
  if (path.startsWith('/progress')) return 2;
  if (path.startsWith('/words')) return 3;
  return 0;
}

String _navIndexToPath(int index) {
  switch (index) {
    case 0: return '/home';
    case 1: return '/library';
    case 2: return '/progress';
    case 3: return '/words';
    default: return '/home';
  }
}

/// プッシュされた画面用：常にフッターナビを表示し、タップで該当タブへ遷移
class ScaffoldWithPersistentNavBar extends ConsumerWidget {
  final Widget child;

  const ScaffoldWithPersistentNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enableMarquee = ref.watch(enableMarqueeRailProvider);
    final path = GoRouterState.of(context).uri.path;
    final selectedIndex = _pathToNavIndex(path);

    final navBar = ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: NavigationBar(
          height: enableMarquee ? 56 : 68,
          backgroundColor: colorScheme.surface.withOpacity(isDark ? 0.92 : 0.95),
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            context.go(_navIndexToPath(index));
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Library',
            ),
            NavigationDestination(
              icon: Icon(Icons.trending_up_outlined),
              selectedIcon: Icon(Icons.trending_up),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: enableMarquee
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BottomRecommendationRail(),
                navBar,
              ],
            )
          : navBar,
    );
  }
}

/// StatefulShellRoute用のScaffold
/// NavigationBarを統一的に表示し、各タブの状態を保持
/// Marquee有効時はフッター上におすすめレールを1段追加
class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enableMarquee = ref.watch(enableMarqueeRailProvider);

    final navBar = ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: NavigationBar(
          height: enableMarquee ? 56 : 68,
          backgroundColor: colorScheme.surface.withOpacity(isDark ? 0.92 : 0.95),
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Library',
            ),
            NavigationDestination(
              icon: Icon(Icons.trending_up_outlined),
              selectedIcon: Icon(Icons.trending_up),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: AnimatedSwitcher(
        duration: EngrowthElementTokens.switchDuration,
        switchInCurve: EngrowthElementTokens.switchCurveIn,
        switchOutCurve: EngrowthElementTokens.switchCurveOut,
        child: KeyedSubtree(
          key: ValueKey<int>(navigationShell.currentIndex),
          child: navigationShell,
        ),
      ),
      bottomNavigationBar: enableMarquee
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BottomRecommendationRail(),
                navBar,
              ],
            )
          : navBar,
    );
  }
}
