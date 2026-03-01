import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/favorite_service.dart';
import 'auth_provider.dart';

final favoriteServiceProvider = Provider<FavoriteService>((ref) {
  return FavoriteService();
});

final userFavoritesProvider = FutureProvider<List<UserFavorite>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  final service = ref.watch(favoriteServiceProvider);
  return service.getFavorites(userId: userId);
});

final userFavoritesByTypeProvider =
    FutureProvider.family<List<UserFavorite>, String?>((ref, targetType) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  final service = ref.watch(favoriteServiceProvider);
  return service.getFavorites(userId: userId, targetType: targetType);
});

final isFavoriteProvider =
    FutureProvider.family<bool, ({String type, String id})>((ref, params) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return false;
  final service = ref.watch(favoriteServiceProvider);
  return service.isFavorite(
    userId: userId,
    targetType: params.type,
    targetId: params.id,
  );
});

/// お気に入りトグル用 Notifier
final favoriteToggleProvider =
    StateNotifierProvider<FavoriteToggleNotifier, AsyncValue<void>>((ref) {
  return FavoriteToggleNotifier(ref);
});

class FavoriteToggleNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  FavoriteToggleNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> toggle({
    required String targetType,
    required String targetId,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    state = const AsyncValue.loading();
    try {
      final service = _ref.read(favoriteServiceProvider);
      final isFav = await service.isFavorite(
        userId: userId,
        targetType: targetType,
        targetId: targetId,
      );
      if (isFav) {
        await service.remove(
          userId: userId,
          targetType: targetType,
          targetId: targetId,
        );
      } else {
        await service.add(
          userId: userId,
          targetType: targetType,
          targetId: targetId,
        );
      }
      _ref.invalidate(userFavoritesProvider);
      _ref.invalidate(userFavoritesByTypeProvider);
      _ref.invalidate(isFavoriteProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
