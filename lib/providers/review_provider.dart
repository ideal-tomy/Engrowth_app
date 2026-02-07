import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_progress.dart';
import '../services/review_service.dart';

/// 復習サービスプロバイダ
final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService();
});

/// 今日の復習リストプロバイダ
final todayReviewListProvider = FutureProvider<List<UserProgress>>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) {
    return [];
  }

  final service = ref.read(reviewServiceProvider);
  return await service.getTodayReviewList(userId);
});

/// 復習リストの件数プロバイダ
final reviewCountProvider = Provider<int>((ref) {
  final reviewListAsync = ref.watch(todayReviewListProvider);
  return reviewListAsync.when(
    data: (list) => list.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
