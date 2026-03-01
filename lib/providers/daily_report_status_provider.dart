import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/voice_submission.dart';
import '../services/voice_submission_service.dart';
import 'auth_provider.dart';

/// 今日の日課提出ステータス
enum DailyReportStatus {
  notStarted,   // 未開始
  recorded,     // 録音済（practice あり、提出なし）
  submitted,    // 提出済（review pending）
  reviewed,     // フィードバック済
}

/// 今日の日課提出状態
class DailyReportState {
  final DailyReportStatus status;
  final int practiceCount;
  final int submittedCount;
  final VoiceSubmission? latestPractice;
  final VoiceSubmission? latestSubmitted;

  const DailyReportState({
    required this.status,
    this.practiceCount = 0,
    this.submittedCount = 0,
    this.latestPractice,
    this.latestSubmitted,
  });
}

/// 今日の日課提出ステータスを取得
final dailyReportStatusProvider =
    FutureProvider<DailyReportState>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return const DailyReportState(status: DailyReportStatus.notStarted);
  }

  final service = VoiceSubmissionService();
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = todayStart.add(const Duration(days: 1));

  final submissions = await service.getUserSubmissions(
    userId: userId,
    fromDate: todayStart,
    toDate: todayEnd,
  );

  final practice = submissions.where((s) => s.submissionType == 'practice').toList();
  final submitted = submissions.where((s) => s.submissionType == 'submitted').toList();

  final hasReviewed = submitted.any((s) => s.reviewStatus == 'reviewed');
  final hasPending = submitted.any((s) => s.reviewStatus == 'pending');

  DailyReportStatus status;
  if (hasReviewed) {
    status = DailyReportStatus.reviewed;
  } else if (hasPending) {
    status = DailyReportStatus.submitted;
  } else if (practice.isNotEmpty) {
    status = DailyReportStatus.recorded;
  } else {
    status = DailyReportStatus.notStarted;
  }

  return DailyReportState(
    status: status,
    practiceCount: practice.length,
    submittedCount: submitted.length,
    latestPractice: practice.isNotEmpty ? practice.first : null,
    latestSubmitted: submitted.isNotEmpty ? submitted.first : null,
  );
});
