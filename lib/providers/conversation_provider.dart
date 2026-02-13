import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/conversation.dart';
import '../services/conversation_service.dart';

/// 会話サービスプロバイダ
final conversationServiceProvider = Provider<ConversationService>((ref) {
  return ConversationService();
});

/// 会話一覧プロバイダ（シチュエーションタイプ別）
/// 注: family のキーに (String?, String?) を使用してキャッシュが正しく効くようにする
final conversationsProvider = FutureProvider.family<List<Conversation>, ({String? situationType, String? theme})>((ref, filter) async {
  final service = ref.read(conversationServiceProvider);
  return await service.getConversations(
    situationType: filter.situationType,
    theme: filter.theme,
  );
});

/// 会話フィルター
class ConversationFilter {
  final String? situationType;
  final String? theme;

  ConversationFilter({
    this.situationType,
    this.theme,
  });

  /// Providerのfamilyキー用（Record型で同値比較が正しく行われる）
  ({String? situationType, String? theme}) get filterKey => (
    situationType: situationType,
    theme: theme,
  );

  ConversationFilter copyWith({
    String? situationType,
    String? theme,
  }) {
    return ConversationFilter(
      situationType: situationType ?? this.situationType,
      theme: theme ?? this.theme,
    );
  }
}

/// 会話詳細プロバイダ（発話リスト含む）
final conversationWithUtterancesProvider = FutureProvider.family<ConversationWithUtterances, String>((ref, conversationId) async {
  final service = ref.read(conversationServiceProvider);
  return await service.getConversationWithUtterances(conversationId);
});
