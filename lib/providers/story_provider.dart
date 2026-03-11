import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/story_theme_categories.dart';
import '../models/story_sequence.dart';
import '../models/conversation.dart';
import '../services/story_service.dart';
import 'conversation_provider.dart';

export '../services/story_service.dart' show StoryProgress;

final storyServiceProvider = Provider<StoryService>((ref) => StoryService());

/// 3分ストーリー一覧
final storySequencesProvider = FutureProvider<List<StorySequence>>((ref) async {
  final service = ref.read(storyServiceProvider);
  return service.getStorySequences();
});

/// テーマ別にグルーピングした3分ストーリー（専用ページ用）
final storySequencesByThemeProvider =
    FutureProvider<Map<String, List<StorySequence>>>((ref) async {
  final service = ref.read(storyServiceProvider);
  return service.getStorySequencesGroupedByTheme();
});

/// ストーリー内の会話一覧
final storyConversationsProvider =
    FutureProvider.family<List<Conversation>, String>((ref, storyId) async {
  final service = ref.read(storyServiceProvider);
  return service.getStoryConversations(storyId);
});

/// ストーリー全文の発話を順序付きで取得（3分一気に聴く用）
final storyUtterancesOrderedProvider =
    FutureProvider.family<List<ConversationUtterance>, String>((ref, storyId) async {
  final conversations = await ref.watch(storyConversationsProvider(storyId).future);
  final ordered = <ConversationUtterance>[];
  for (final c in conversations) {
    final cwu = await ref.read(conversationWithUtterancesProvider(c.id).future);
    ordered.addAll(cwu.utterances);
  }
  return ordered;
});

/// ユーザーのストーリー進捗
final storyProgressProvider =
    FutureProvider.family<StoryProgress?, String>((ref, storyId) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return null;
  final service = ref.read(storyServiceProvider);
  return service.getStoryProgress(userId, storyId);
});

/// オートスクロール用：最初に未クリアのストーリーID（テーマ順）
final firstIncompleteStoryIdProvider = FutureProvider<String?>((ref) async {
  final byTheme = await ref.watch(storySequencesByThemeProvider.future);
  final sorted =
      byTheme.keys.toList()
        ..sort((a, b) => orderForTheme(a).compareTo(orderForTheme(b)));
  for (final theme in sorted) {
    final stories = byTheme[theme] ?? [];
    for (final story in stories) {
      final progress = await ref.read(storyProgressProvider(story.id).future);
      if (progress?.completedAt == null) return story.id;
    }
  }
  return null;
});

/// 一覧の並び順（display_order）で、指定ストーリーの次のストーリーIDを返す
final nextStoryIdProvider =
    FutureProvider.family<String?, String>((ref, currentStoryId) async {
  final sequences = await ref.watch(storySequencesProvider.future);
  final currentIdx = sequences.indexWhere((s) => s.id == currentStoryId);
  if (currentIdx < 0 || currentIdx >= sequences.length - 1) return null;
  return sequences[currentIdx + 1].id;
});
