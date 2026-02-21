import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/story_sequence.dart';
import '../models/conversation.dart';

/// 3分ストーリー用サービス
class StoryService {
  final _client = Supabase.instance.client;

  /// ストーリーシーケンス一覧を取得
  Future<List<StorySequence>> getStorySequences() async {
    try {
      final res = await _client
          .from('story_sequences')
          .select()
          .order('display_order', ascending: true);

      return (res as List)
          .map((e) => StorySequence.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// ストーリー内の会話を順序付きで取得
  Future<List<Conversation>> getStoryConversations(String storySequenceId) async {
    try {
      final res = await _client
          .from('conversations')
          .select()
          .eq('story_sequence_id', storySequenceId)
          .order('story_order', ascending: true);

      return (res as List)
          .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// ユーザーのストーリー進捗を取得
  Future<StoryProgress?> getStoryProgress(String userId, String storySequenceId) async {
    try {
      final res = await _client
          .from('story_progress')
          .select()
          .eq('user_id', userId)
          .eq('story_sequence_id', storySequenceId)
          .maybeSingle();

      if (res == null) return null;
      return StoryProgress.fromJson(res as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// ストーリー進捗を保存（再開用）
  Future<void> saveStoryProgress({
    required String userId,
    required String storySequenceId,
    String? lastConversationId,
    int lastUtteranceIndex = 0,
    bool completed = false,
  }) async {
    await _client.from('story_progress').upsert({
      'user_id': userId,
      'story_sequence_id': storySequenceId,
      'last_conversation_id': lastConversationId,
      'last_utterance_index': lastUtteranceIndex,
      'completed_at': completed ? DateTime.now().toIso8601String() : null,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,story_sequence_id');
  }

  /// 会話の中断位置を保存
  Future<void> saveConversationResume({
    required String userId,
    required String conversationId,
    required int utteranceIndex,
  }) async {
    await _client.from('conversation_resume').upsert({
      'user_id': userId,
      'conversation_id': conversationId,
      'utterance_index': utteranceIndex,
      'last_resume_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,conversation_id');
  }

  /// 会話の再開位置を取得
  Future<ConversationResume?> getConversationResume(
    String userId,
    String conversationId,
  ) async {
    try {
      final res = await _client
          .from('conversation_resume')
          .select()
          .eq('user_id', userId)
          .eq('conversation_id', conversationId)
          .maybeSingle();

      if (res == null) return null;
      return ConversationResume.fromJson(res as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

class StoryProgress {
  final String id;
  final String userId;
  final String storySequenceId;
  final String? lastConversationId;
  final int lastUtteranceIndex;
  final DateTime? completedAt;

  StoryProgress({
    required this.id,
    required this.userId,
    required this.storySequenceId,
    this.lastConversationId,
    this.lastUtteranceIndex = 0,
    this.completedAt,
  });

  factory StoryProgress.fromJson(Map<String, dynamic> json) {
    return StoryProgress(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      storySequenceId: json['story_sequence_id'] as String,
      lastConversationId: json['last_conversation_id'] as String?,
      lastUtteranceIndex: json['last_utterance_index'] as int? ?? 0,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }
}

class ConversationResume {
  final String id;
  final String userId;
  final String conversationId;
  final int utteranceIndex;
  final DateTime lastResumeAt;

  ConversationResume({
    required this.id,
    required this.userId,
    required this.conversationId,
    required this.utteranceIndex,
    required this.lastResumeAt,
  });

  factory ConversationResume.fromJson(Map<String, dynamic> json) {
    return ConversationResume(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      conversationId: json['conversation_id'] as String,
      utteranceIndex: json['utterance_index'] as int? ?? 0,
      lastResumeAt: DateTime.parse(json['last_resume_at'] as String),
    );
  }
}
