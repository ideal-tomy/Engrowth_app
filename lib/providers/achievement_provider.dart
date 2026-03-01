import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';

/// バッジ/称号サービスプロバイダ
final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService();
});

/// 全バッジプロバイダ（テーブル未設定時は空リストでフォールバック）
final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  try {
    final service = ref.read(achievementServiceProvider);
    return await service.getAchievements();
  } catch (_) {
    return [];
  }
});

/// ユーザーの獲得バッジプロバイダ（テーブル未設定時は空でフォールバック）
final userAchievementsProvider = FutureProvider<List<UserAchievement>>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return [];
  try {
    final service = ref.read(achievementServiceProvider);
    return await service.getUserAchievements(userId);
  } catch (_) {
    return [];
  }
});

/// ユーザーが獲得済みのバッジIDセットプロバイダ
final unlockedAchievementIdsProvider = FutureProvider<Set<String>>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return {};

  final service = ref.read(achievementServiceProvider);
  return await service.getUnlockedAchievementIds(userId);
});
