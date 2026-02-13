import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation.dart';

/// 会話サービス
class ConversationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// シチュエーションタイプ別の会話一覧を取得
  Future<List<Conversation>> getConversations({
    String? situationType,
    String? theme,
  }) async {
    try {
      var query = _supabase.from('conversations').select();

      if (situationType != null) {
        query = query.eq('situation_type', situationType);
      }

      if (theme != null) {
        query = query.eq('theme', theme);
      }

      final response = await query.order('created_at', ascending: true);

      return (response as List)
          .map((json) => Conversation.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting conversations: $e');
      rethrow;
    }
  }

  /// 会話の詳細を取得（発話リスト含む）
  Future<ConversationWithUtterances> getConversationWithUtterances(String conversationId) async {
    try {
      // 会話情報を取得
      final conversationResponse = await _supabase
          .from('conversations')
          .select()
          .eq('id', conversationId)
          .single();

      final conversation = Conversation.fromJson(conversationResponse);

      // 発話リストを取得
      final utterancesResponse = await _supabase
          .from('conversation_utterances')
          .select()
          .eq('conversation_id', conversationId)
          .order('utterance_order', ascending: true);

      final utterances = (utterancesResponse as List)
          .map((json) => ConversationUtterance.fromJson(json))
          .toList();

      return ConversationWithUtterances(
        conversation: conversation,
        utterances: utterances,
      );
    } catch (e) {
      print('Error getting conversation with utterances: $e');
      rethrow;
    }
  }
}

/// 会話と発話リストの組み合わせ
class ConversationWithUtterances {
  final Conversation conversation;
  final List<ConversationUtterance> utterances;

  ConversationWithUtterances({
    required this.conversation,
    required this.utterances,
  });
}
