import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/next_action_suggestion.dart';
import '../services/favorite_service.dart';
import '../services/voice_submission_service.dart';
import 'review_provider.dart';
import 'user_stats_provider.dart';

/// 復習・お気に入り・録音・日次目標を集約した次アクション提案
final nextActionSuggestionsProvider = FutureProvider<List<NextActionSuggestion>>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return [];

  final List<NextActionSuggestion> suggestions = [];
  final favService = FavoriteService();
  final submissionService = VoiceSubmissionService();

  // 1. 復習が溜まっている
  final reviewList = await ref.read(todayReviewListProvider.future);
  if (reviewList.isNotEmpty) {
    suggestions.add(NextActionSuggestion(
      type: NextActionType.review,
      title: '本日の復習',
      subtitle: '${reviewList.length}件の例文が復習期限です',
      icon: Icons.refresh,
      accentColor: Colors.orange,
      route: '/review',
      count: reviewList.length,
    ));
  }

  // 2. お気に入りがある
  final favorites = await favService.getFavorites(userId: userId);
  if (favorites.isNotEmpty) {
    suggestions.add(NextActionSuggestion(
      type: NextActionType.favorites,
      title: 'お気に入りで学習',
      subtitle: '${favorites.length}件のお気に入りがあります',
      icon: Icons.favorite,
      accentColor: Colors.pink,
      route: '/favorites',
      count: favorites.length,
    ));
  }

  // 3. 録音が未提出（practice）
  final submissions = await submissionService.getUserSubmissions(userId: userId);
  final practiceCount = submissions.where((s) => s.submissionType == 'practice').length;
  if (practiceCount > 0) {
    suggestions.add(NextActionSuggestion(
      type: NextActionType.recordings,
      title: '録音を提出する',
      subtitle: '$practiceCount件の録音が未提出です',
      icon: Icons.mic,
      accentColor: Colors.teal,
      route: '/recordings',
      count: practiceCount,
    ));
  }

  // 4. 今日の目標未達
  final stats = await ref.read(userStatsProvider.future);
  if (!stats.isMissionCompleted && stats.dailyGoalCount > 0) {
    final remaining = stats.dailyGoalCount - stats.dailyDoneCount;
    suggestions.add(NextActionSuggestion(
      type: NextActionType.dailyGoal,
      title: '今日の目標を達成',
      subtitle: 'あと$remaining問で今日の目標達成',
      icon: Icons.flag,
      accentColor: Colors.green,
      route: '/study',
      count: remaining,
    ));
  }

  return suggestions;
});
