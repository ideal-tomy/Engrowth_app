import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/dashboard_screen.dart';
import '../screens/library_hub_screen.dart';
import '../screens/word_list_screen.dart';
import '../screens/sentence_list_screen.dart';
import '../screens/study_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/hint_settings_screen.dart';
import '../screens/playback_speed_settings_screen.dart';
import '../screens/account_screen.dart';
import '../screens/scenario_list_screen.dart';
import '../screens/scenario_study_screen.dart';
import '../screens/conversation_list_screen.dart';
import '../screens/conversation_study_screen.dart';
import '../screens/scenario_learning_screen.dart';
import '../screens/consultant_dashboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    if (state.matchedLocation == '/consultant' && session == null) {
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
      path: '/study',
      builder: (context, state) {
        final sentenceId = state.uri.queryParameters['sentenceId'];
        final sessionMode = state.uri.queryParameters['sessionMode'];
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
      builder: (context, state) => const AccountScreen(),
    ),
    GoRoute(
      path: '/scenarios',
      builder: (context, state) => const ScenarioListScreen(),
    ),
    GoRoute(
      path: '/scenario-learning',
      builder: (context, state) => const ScenarioLearningScreen(),
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
      path: '/',
      redirect: (context, state) => '/home',
    ),
  ],
);

/// StatefulShellRoute用のScaffold
/// NavigationBarを統一的に表示し、各タブの状態を保持
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            // 同じブランチ内の最初のルートに移動
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
    );
  }
}
