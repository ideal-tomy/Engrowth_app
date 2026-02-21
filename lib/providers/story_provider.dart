import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
