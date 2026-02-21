import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_progress.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

final userProgressProvider = FutureProvider<List<UserProgress>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return await SupabaseService.getUserProgress(userId);
});

final masteredCountProvider = FutureProvider<int>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return 0;
  return await SupabaseService.getMasteredCount(userId);
});

/// 既習可視化用: 習得済み sentence IDs の Set
final masteredSentenceIdsProvider = FutureProvider<Set<String>>((ref) async {
  final progressList = await ref.watch(userProgressProvider.future);
  return progressList
      .where((p) => p.isMastered)
      .map((p) => p.sentenceId)
      .toSet();
});

final progressNotifierProvider = StateNotifierProvider<ProgressNotifier, AsyncValue<void>>((ref) {
  return ProgressNotifier(ref);
});

class ProgressNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  
  ProgressNotifier(this.ref) : super(const AsyncValue.data(null));
  
  Future<void> updateProgress({
    required String sentenceId,
    required bool isMastered,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        throw Exception('ユーザーがログインしていません');
      }
      
      await SupabaseService.updateProgress(
        userId: userId,
        sentenceId: sentenceId,
        isMastered: isMastered,
      );
      
      // プロバイダーを再読み込み
      ref.invalidate(userProgressProvider);
      ref.invalidate(masteredCountProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
