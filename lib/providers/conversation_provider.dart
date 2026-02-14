import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/scenario_categories.dart';
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

/// シナリオ学習ページ用: 全会話を取得（theme フィルタなし）
final allConversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final service = ref.read(conversationServiceProvider);
  return await service.getConversations();
});

/// シナリオ学習ページ用: カテゴリ別に会話をグルーピング
/// 戻り値: カテゴリID -> 会話リスト のマップ
final conversationsByCategoryProvider = FutureProvider<Map<String, List<Conversation>>>((ref) async {
  final conversations = await ref.watch(allConversationsProvider.future);
  final map = <String, List<Conversation>>{};
  for (final category in kScenarioCategories) {
    final list = conversations
        .where((c) => category.matchesTheme(c.theme))
        .toList();
    map[category.id] = list;
  }
  return map;
});

/// シナリオ学習ページ用: カテゴリ別・サブセクション別に会話をグルーピング
/// theme ごとに最大10件ずつに分割し、横スクロール行を分けて表示
const int _kMaxCardsPerRow = 10;

class ConversationSubSection {
  final String subTitle;
  final List<Conversation> conversations;

  const ConversationSubSection({
    required this.subTitle,
    required this.conversations,
  });
}

final conversationsByCategoryWithSubsectionsProvider =
    FutureProvider<Map<String, List<ConversationSubSection>>>((ref) async {
  final conversations = await ref.watch(allConversationsProvider.future);
  final map = <String, List<ConversationSubSection>>{};

  for (final category in kScenarioCategories) {
    final list = conversations
        .where((c) => category.matchesTheme(c.theme))
        .toList();

    if (list.isEmpty) {
      map[category.id] = [];
      continue;
    }

    // theme でグループ化
    final byTheme = <String, List<Conversation>>{};
    for (final c in list) {
      final theme = c.theme ?? 'その他';
      byTheme.putIfAbsent(theme, () => []).add(c);
    }

    // 各 theme を10件ずつチャンクしてサブセクション化
    final subsections = <ConversationSubSection>[];
    for (final entry in byTheme.entries) {
      final themeName = entry.key;
      final convs = entry.value;
      for (var i = 0; i < convs.length; i += _kMaxCardsPerRow) {
        final chunk = convs.skip(i).take(_kMaxCardsPerRow).toList();
        final subTitle = i == 0 ? themeName : '$themeName（続き）';
        subsections.add(ConversationSubSection(
          subTitle: subTitle,
          conversations: chunk,
        ));
      }
    }
    // サブセクションを theme 名でソート（続きは元の theme の次に）
    subsections.sort((a, b) => a.subTitle.compareTo(b.subTitle));
    map[category.id] = subsections;
  }
  return map;
});
