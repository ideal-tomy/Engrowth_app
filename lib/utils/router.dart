import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/word_list_screen.dart';
import '../screens/sentence_list_screen.dart';
import '../screens/study_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/hint_settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/words',
      builder: (context, state) => const WordListScreen(),
    ),
    GoRoute(
      path: '/sentences',
      builder: (context, state) => const SentenceListScreen(),
    ),
    GoRoute(
      path: '/study',
      builder: (context, state) => const StudyScreen(),
    ),
    GoRoute(
      path: '/progress',
      builder: (context, state) => const ProgressScreen(),
    ),
    GoRoute(
      path: '/hint-settings',
      builder: (context, state) => const HintSettingsScreen(),
    ),
  ],
);
