import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_stats.dart';
import '../services/user_stats_service.dart';

/// ユーザー統計情報サービスプロバイダ
final userStatsServiceProvider = Provider<UserStatsService>((ref) {
  return UserStatsService();
});

/// ユーザー統計情報プロバイダ
final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) {
    throw Exception('ユーザーがログインしていません');
  }

  final service = ref.read(userStatsServiceProvider);
  return await service.getOrCreateUserStats(userId);
});

/// ユーザー統計情報更新用Notifier
final userStatsNotifierProvider = StateNotifierProvider<UserStatsNotifier, AsyncValue<UserStats>>((ref) {
  final service = ref.read(userStatsServiceProvider);
  return UserStatsNotifier(ref, service);
});

class UserStatsNotifier extends StateNotifier<AsyncValue<UserStats>> {
  final Ref _ref;
  final UserStatsService _service;

  UserStatsNotifier(this._ref, this._service) : super(const AsyncValue.loading()) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        state = const AsyncValue.error('ユーザーがログインしていません', StackTrace.empty);
        return;
      }

      final stats = await _service.getOrCreateUserStats(userId);
      state = AsyncValue.data(stats);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// ストリークを更新
  Future<void> updateStreak() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final updatedStats = await _service.updateStreak(userId);
      state = AsyncValue.data(updatedStats);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// 日次ミッションの進捗を更新
  Future<void> incrementDailyDone({int count = 1}) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      // リセットが必要かチェック
      await _service.resetDailyMissionIfNeeded(userId);
      
      final updatedStats = await _service.incrementDailyDone(userId, count: count);
      state = AsyncValue.data(updatedStats);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// 日次目標を更新
  Future<void> updateDailyGoal(int goalCount) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final updatedStats = await _service.updateDailyGoal(userId, goalCount);
      state = AsyncValue.data(updatedStats);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// 統計情報をリフレッシュ
  Future<void> refresh() async {
    await _loadStats();
  }
}
