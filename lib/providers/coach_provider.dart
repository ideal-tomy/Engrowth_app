import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coach_mission.dart';
import '../models/daily_summary.dart';
import '../models/feedback_template.dart';
import '../services/consultant_service.dart';
import 'auth_provider.dart';

final consultantServiceProvider = Provider<ConsultantService>((ref) {
  return ConsultantService();
});

/// 今日のミッション（coach_missions テーブルから取得）
final todaysCoachMissionProvider = FutureProvider<CoachMission?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  final service = ref.read(consultantServiceProvider);
  return service.getTodaysMission(userId);
});

/// 今日の日次総評（daily_summaries テーブルから取得）
final todaysDailySummaryProvider = FutureProvider<DailySummary?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  final service = ref.read(consultantServiceProvider);
  return service.getTodaysSummary(userId);
});

/// コンサルタント用クイック返信テンプレート
final feedbackTemplatesProvider = FutureProvider<List<FeedbackTemplate>>((ref) async {
  final service = ref.read(consultantServiceProvider);
  return service.getFeedbackTemplates();
});
