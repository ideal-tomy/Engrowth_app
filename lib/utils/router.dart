import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/word_list_screen.dart';
import '../screens/sentence_list_screen.dart';
import '../screens/study_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/hint_settings_screen.dart';
import '../screens/account_screen.dart';
import '../screens/scenario_list_screen.dart';
import '../screens/scenario_study_screen.dart';
import '../screens/conversation_list_screen.dart';
import '../screens/conversation_study_screen.dart';
import '../screens/scenario_learning_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/study',
  routes: [
    // メイン4タブをStatefulShellRouteで管理（状態保持）
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // 単語タブ
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/words',
              builder: (context, state) => const WordListScreen(),
            ),
          ],
        ),
        // 例文タブ
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sentences',
              builder: (context, state) => const SentenceListScreen(),
            ),
          ],
        ),
        // 学習タブ
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/study',
              builder: (context, state) => const StudyScreen(),
            ),
          ],
        ),
        // 進捗タブ
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/progress',
              builder: (context, state) => const ProgressScreen(),
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
      path: '/conversation/:id',
      builder: (context, state) {
        final conversationId = state.pathParameters['id']!;
        final mode = state.uri.queryParameters['mode'] ?? 'listen';  // listen, roleA, roleB
        return ConversationStudyScreen(conversationId: conversationId, initialMode: mode);
      },
    ),
    // ルートパスは/studyへリダイレクト
    GoRoute(
      path: '/',
      redirect: (context, state) => '/study',
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
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: '単語',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: '例文',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: '学習',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: '進捗',
          ),
        ],
      ),
    );
  }
}
