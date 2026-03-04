import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coach_mission.dart';
import '../models/next_action_suggestion.dart';
import '../models/startup_shortcut_content.dart';
import '../services/startup_shortcut_service.dart';
import 'coach_provider.dart';
import 'next_action_provider.dart';
import 'user_plan_provider.dart';

final startupShortcutServiceProvider = Provider<StartupShortcutService>((ref) {
  return StartupShortcutService();
});

/// 起動時ショートカットの表示候補（表示可否は別途判定）
/// 優先度: コンサル課題 > アプリ推奨 > デフォルト
final startupShortcutContentProvider =
    FutureProvider<StartupShortcutContent?>((ref) async {
  final userPlan = ref.watch(userPlanProvider);

  // 1. コンサル課題（伴走契約ユーザーのみ）
  if (userPlan == UserPlan.coaching) {
    final mission = await ref.read(todaysCoachMissionProvider.future);
    if (mission != null) {
      return _contentFromMission(mission);
    }
  }

  // 2. アプリ推奨（ログインユーザー）
  final suggestions = await ref.read(nextActionSuggestionsProvider.future);
  if (suggestions.isNotEmpty) {
    final first = suggestions.first;
    return StartupShortcutContent(
      source: 'app',
      message: first.subtitle,
      ctaLabel: first.title,
      route: first.route,
      showConsultantAvatar: false,
    );
  }

  // 3. デフォルト（匿名・提案なし）
  return const StartupShortcutContent(
    source: 'app',
    message: '昨日の続きを30秒だけやりませんか？',
    ctaLabel: '学習を始める',
    route: '/study',
    showConsultantAvatar: false,
  );
});

StartupShortcutContent _contentFromMission(CoachMission mission) {
  final templates = [
    '今日はこの課題に挑戦してみましょう！',
    'まずはここからいきましょう。',
    '提出まで最短ルートはこちらです。',
  ];
  final seed = mission.missionDate.millisecondsSinceEpoch % templates.length;
  final suffix = templates[seed];
  final message = '${mission.missionText}\n$suffix';
  return StartupShortcutContent(
    source: 'consultant',
    message: message,
    ctaLabel: '課題を始める',
    route: mission.actionRoute ?? '/study',
    showConsultantAvatar: true,
  );
}
