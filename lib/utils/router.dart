import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
import '../providers/ui_experiments_provider.dart';
import '../widgets/marquee/bottom_recommendation_rail.dart';

/// 高級感のある画面遷移（fade + slightSlideUp）
/// Push時 200ms、低振幅のスライドで自然な遷移を実現
Page<void> _luxuryTransitionPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  Duration duration = const Duration(milliseconds: 220),
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        ),
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
      path: '/hint-settings',
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: const HintSettingsScreen(),
      ),
    ),
    GoRoute(
      path: '/playback-speed-settings',
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: const PlaybackSpeedSettingsScreen(),
      ),
    ),
    GoRoute(
      path: '/pattern-sprint',
      pageBuilder: (context, state) {
        final fromOnboarding =
            state.uri.queryParameters['from_onboarding'] == 'true';
        return _luxuryTransitionPage(
          context: context,
          state: state,
          child: PatternSprintListScreen(fromOnboarding: fromOnboarding),
        );
      },
      routes: [
        GoRoute(
          path: 'session',
          pageBuilder: (context, state) {
            final prefix = state.uri.queryParameters['prefix'] ?? '';
            final duration = int.tryParse(state.uri.queryParameters['duration'] ?? '45') ?? 45;
            return _luxuryTransitionPage(
              context: context,
              state: state,
              child: PatternSprintSessionScreen(
                prefix: Uri.decodeComponent(prefix),
                durationSec: duration.clamp(30, 60),
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
        return _luxuryTransitionPage(
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
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: SentenceListScreen(
          initialWord: state.uri.queryParameters['word'],
        ),
      ),
    ),
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: const WordListScreen(initialFocusSearch: true),
      ),
    ),
    GoRoute(
      path: '/account',
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: AccountScreen(
          initialProvider: state.uri.queryParameters['provider'],
        ),
      ),
    ),
    GoRoute(
      path: '/scenarios',
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: const ScenarioListScreen(),
      ),
    ),
    GoRoute(
      path: '/conversation-training',
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: const ConversationTrainingChoiceScreen(),
      ),
    ),
    GoRoute(
      path: '/scenario-learning',
      pageBuilder: (context, state) {
        final fromOnboarding =
            state.uri.queryParameters['from_onboarding'] == 'true';
        return _luxuryTransitionPage(
          context: context,
          state: state,
          child: ScenarioLearningScreen(fromOnboarding: fromOnboarding),
        );
      },
    ),
    GoRoute(
      path: '/story-training',
      pageBuilder: (context, state) {
        final fromOnboarding =
            state.uri.queryParameters['from_onboarding'] == 'true';
        return _luxuryTransitionPage(
          context: context,
          state: state,
          child: StoryTrainingScreen(fromOnboarding: fromOnboarding),
        );
      },
    ),
    GoRoute(
      path: '/scenario/:id',
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: ScenarioStudyScreen(scenarioId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/conversations',
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: ConversationListScreen(
          situationType: state.uri.queryParameters['type'],
        ),
      ),
    ),
    GoRoute(
      path: '/favorites',
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: const FavoritesScreen(),
      ),
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: const NotificationsScreen(),
      ),
    ),
    GoRoute(
      path: '/consultant-contact',
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: ConsultantContactScreen(
          initialReportType: state.uri.queryParameters['reportType'],
          relatedSubmissionId: state.uri.queryParameters['submissionId'],
        ),
      ),
    ),
    GoRoute(
      path: '/review',
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: const ReviewListScreen(),
      ),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => _luxuryTransitionPage(
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
        return _luxuryTransitionPage(
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
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: TutorialConversationScreen(
          entrySource: state.uri.queryParameters['entry_source'] ?? 'direct',
        ),
      ),
    ),
    GoRoute(
      path: '/help',
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: const HelpScreen(),
      ),
    ),
    GoRoute(
      path: '/concept',
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: const ConceptScreen(),
      ),
    ),
    GoRoute(
      path: '/recordings',
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: RecordingHistoryScreen(
          initialTab: state.uri.queryParameters['tab'],
        ),
      ),
    ),
    GoRoute(
      path: '/admin',
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: const AdminDashboardScreen(),
      ),
    ),
    GoRoute(
      path: '/consultant',
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: const ConsultantDashboardScreen(),
      ),
    ),
    GoRoute(
      path: '/conversation/:id',
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: ConversationStudyScreen(
          conversationId: state.pathParameters['id']!,
          initialMode: state.uri.queryParameters['mode'] ?? 'listen',
        ),
      ),
    ),
    GoRoute(
      path: '/story/:id',
      pageBuilder: (context, state) => _luxuryTransitionPage(
        context: context,
        state: state,
        child: StoryStudyScreen(storyId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/progress/scenario-board',
      pageBuilder: (context, state) {
        final extra = state.extra;
        return _luxuryTransitionPage(
          context: context,
          state: state,
          child: ScenarioProgressBoardScreen(
            scrollToNext: extra is Map && (extra as Map<String, dynamic>)['scrollToNext'] == true,
          ),
        );
      },
    ),
    GoRoute(
      path: '/progress/story-board',
      pageBuilder: (context, state) {
        final extra = state.extra;
        return _luxuryTransitionPage(
          context: context,
          state: state,
          child: StoryProgressBoardScreen(
            scrollToNext: extra is Map && (extra as Map<String, dynamic>)['scrollToNext'] == true,
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
      body: navigationShell,
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
