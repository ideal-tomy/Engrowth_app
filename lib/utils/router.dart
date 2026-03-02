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
import '../screens/review_list_screen.dart';
import '../screens/onboarding_flow_screen.dart';
import '../screens/tutorial_conversation_screen.dart';
import '../screens/help_screen.dart';
import '../screens/concept_screen.dart';
import '../providers/ui_experiments_provider.dart';
import '../widgets/marquee/bottom_recommendation_rail.dart';

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
      builder: (context, state) => const HintSettingsScreen(),
    ),
    GoRoute(
      path: '/playback-speed-settings',
      builder: (context, state) => const PlaybackSpeedSettingsScreen(),
    ),
    GoRoute(
      path: '/pattern-sprint',
      builder: (context, state) => const PatternSprintListScreen(),
      routes: [
        GoRoute(
          path: 'session',
          builder: (context, state) {
            final prefix = state.uri.queryParameters['prefix'] ?? '';
            final duration = int.tryParse(state.uri.queryParameters['duration'] ?? '45') ?? 45;
            return PatternSprintSessionScreen(
              prefix: Uri.decodeComponent(prefix),
              durationSec: duration.clamp(30, 60),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/study',
      builder: (context, state) {
        final sentenceId = state.uri.queryParameters['sentenceId'];
        final sessionMode = state.uri.queryParameters['sessionMode'] ??
            state.uri.queryParameters['mode'];
        return StudyScreen(
          initialSentenceId: sentenceId,
          initialSessionModeParam: sessionMode,
        );
      },
    ),
    GoRoute(
      path: '/sentences',
      builder: (context, state) {
        final word = state.uri.queryParameters['word'];
        return SentenceListScreen(initialWord: word);
      },
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) =>
          const WordListScreen(initialFocusSearch: true),
    ),
    GoRoute(
      path: '/account',
      builder: (context, state) {
        final provider = state.uri.queryParameters['provider'];
        return AccountScreen(initialProvider: provider);
      },
    ),
    GoRoute(
      path: '/scenarios',
      builder: (context, state) => const ScenarioListScreen(),
    ),
    GoRoute(
      path: '/conversation-training',
      builder: (context, state) => const ConversationTrainingChoiceScreen(),
    ),
    GoRoute(
      path: '/scenario-learning',
      builder: (context, state) => const ScenarioLearningScreen(),
    ),
    GoRoute(
      path: '/story-training',
      builder: (context, state) => const StoryTrainingScreen(),
    ),
    GoRoute(
      path: '/scenario/:id',
      builder: (context, state) {
        final scenarioId = state.pathParameters['id']!;
        return ScenarioStudyScreen(scenarioId: scenarioId);
      },
    ),
    GoRoute(
      path: '/conversations',
      builder: (context, state) {
        final situationType = state.uri.queryParameters['type'];
        return ConversationListScreen(situationType: situationType);
      },
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/review',
      builder: (context, state) => const ReviewListScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingFlowScreen(),
    ),
    GoRoute(
      path: '/tutorial-conversation',
      builder: (context, state) => const TutorialConversationScreen(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpScreen(),
    ),
    GoRoute(
      path: '/concept',
      builder: (context, state) => const ConceptScreen(),
    ),
    GoRoute(
      path: '/recordings',
      builder: (context, state) {
        final tab = state.uri.queryParameters['tab'];
        return RecordingHistoryScreen(initialTab: tab);
      },
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/consultant',
      builder: (context, state) => const ConsultantDashboardScreen(),
    ),
    GoRoute(
      path: '/conversation/:id',
      builder: (context, state) {
        final conversationId = state.pathParameters['id']!;
        final mode = state.uri.queryParameters['mode'] ?? 'listen';  // listen, roleA, roleB
        return ConversationStudyScreen(conversationId: conversationId, initialMode: mode);
      },
    ),
    GoRoute(
      path: '/story/:id',
      builder: (context, state) {
        final storyId = state.pathParameters['id']!;
        return StoryStudyScreen(storyId: storyId);
      },
    ),
    GoRoute(
      path: '/progress/scenario-board',
      builder: (context, state) {
        final extra = state.extra;
        return ScenarioProgressBoardScreen(
          scrollToNext: extra is Map && (extra as Map<String, dynamic>)['scrollToNext'] == true,
        );
      },
    ),
    GoRoute(
      path: '/progress/story-board',
      builder: (context, state) {
        final extra = state.extra;
        return StoryProgressBoardScreen(
          scrollToNext: extra is Map && (extra as Map<String, dynamic>)['scrollToNext'] == true,
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
