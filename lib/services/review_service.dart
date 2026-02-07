import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_progress.dart';

/// 復習最適化サービス
/// 忘却曲線とヒント使用率を考慮した復習優先度計算
class ReviewService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 復習優先度を計算
  /// 戻り値: 優先度スコア（高いほど優先）
  int _calculatePriority(UserProgress progress, DateTime now) {
    int priority = 0;

    // 復習期限が過ぎている場合
    if (progress.nextReviewAt != null && now.isAfter(progress.nextReviewAt!)) {
      priority += 3;
    }

    // ヒント使用回数が多い場合
    if (progress.hintUsageCount >= 2) {
      priority += 2;
    }

    // ヒントを使って覚えた場合
    if (progress.usedHintToMaster) {
      priority += 1;
    }

    // 平均思考時間が長い場合（閾値: 10秒）
    if (progress.averageThinkingTimeSeconds > 10) {
      priority += 1;
    }

    return priority;
  }

  /// 今日の復習リストを取得
  Future<List<UserProgress>> getTodayReviewList(String userId) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // next_review_atが今日以前のものを取得
      final response = await _supabase
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .lte('next_review_at', todayEnd.toIso8601String())
          .order('next_review_at', ascending: true);

      final progressList = (response as List)
          .map((json) => UserProgress.fromJson(json))
          .toList();

      // 優先度でソート
      progressList.sort((a, b) {
        final priorityA = _calculatePriority(a, now);
        final priorityB = _calculatePriority(b, now);
        if (priorityA != priorityB) {
          return priorityB.compareTo(priorityA); // 降順
        }
        // 優先度が同じ場合はnext_review_atでソート
        if (a.nextReviewAt != null && b.nextReviewAt != null) {
          return a.nextReviewAt!.compareTo(b.nextReviewAt!);
        }
        return 0;
      });

      return progressList;
    } catch (e) {
      print('Error getting review list: $e');
      rethrow;
    }
  }

  /// 復習間隔を計算（簡易SR: Spaced Repetition）
  /// 正解 & ヒントなし → +3日
  /// 正解 & ヒントあり → +1日
  /// 不正解 → +6時間
  DateTime calculateNextReview({
    required bool isCorrect,
    required bool usedHint,
    DateTime? currentNextReview,
  }) {
    final now = DateTime.now();

    if (!isCorrect) {
      // 不正解: 6時間後
      return now.add(const Duration(hours: 6));
    }

    if (usedHint) {
      // 正解 & ヒントあり: 1日後
      return now.add(const Duration(days: 1));
    }

    // 正解 & ヒントなし: 3日後
    return now.add(const Duration(days: 3));
  }

  /// 復習完了時にnext_review_atを更新
  Future<void> updateReviewSchedule({
    required String userId,
    required String sentenceId,
    required bool isCorrect,
    required bool usedHint,
  }) async {
    try {
      // 現在の値を取得
      final response = await _supabase
          .from('user_progress')
          .select('review_count')
          .eq('user_id', userId)
          .eq('sentence_id', sentenceId)
          .maybeSingle();

      final currentReviewCount = (response?['review_count'] as int?) ?? 0;
      final nextReviewAt = calculateNextReview(
        isCorrect: isCorrect,
        usedHint: usedHint,
      );

      await _supabase
          .from('user_progress')
          .update({
            'last_review_at': DateTime.now().toIso8601String(),
            'next_review_at': nextReviewAt.toIso8601String(),
            'review_count': currentReviewCount + 1,
          })
          .eq('user_id', userId)
          .eq('sentence_id', sentenceId);
    } catch (e) {
      print('Error updating review schedule: $e');
      rethrow;
    }
  }
}
