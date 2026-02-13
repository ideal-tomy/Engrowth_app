import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/conversation.dart';
import '../providers/conversation_provider.dart';
import '../theme/engrowth_theme.dart';
import '../widgets/optimized_image.dart';
import '../widgets/scenario_background.dart';

/// 会話一覧画面
class ConversationListScreen extends ConsumerStatefulWidget {
  final String? situationType;  // 'student' or 'business'

  const ConversationListScreen({
    super.key,
    this.situationType,
  });

  @override
  ConsumerState<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends ConsumerState<ConversationListScreen> {
  String? _selectedTheme;

  @override
  Widget build(BuildContext context) {
    final filter = ConversationFilter(
      situationType: widget.situationType,
      theme: _selectedTheme,
    );
    final conversationsAsync = ref.watch(conversationsProvider(filter.filterKey));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.situationType == 'student' 
            ? '学生コース' 
            : widget.situationType == 'business' 
                ? 'ビジネスコース' 
                : '会話学習'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/account'),
            tooltip: 'アカウント',
          ),
        ],
      ),
      body: Column(
        children: [
          // テーマフィルター
          if (widget.situationType != null)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('すべて'),
                    selected: _selectedTheme == null,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedTheme = null);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  // テーマリスト（学生コース）
                  if (widget.situationType == 'student') ...[
                    _buildThemeChip('挨拶'),
                    _buildThemeChip('自己紹介'),
                    _buildThemeChip('道案内'),
                    _buildThemeChip('空港'),
                    _buildThemeChip('ホテル'),
                    _buildThemeChip('レストラン'),
                    _buildThemeChip('ショッピング'),
                    _buildThemeChip('交通機関'),
                    _buildThemeChip('銀行'),
                    _buildThemeChip('郵便局'),
                    _buildThemeChip('病院'),
                  ],
                  // テーマリスト（ビジネスコース）
                  if (widget.situationType == 'business') ...[
                    _buildThemeChip('挨拶'),
                    _buildThemeChip('自己紹介'),
                    _buildThemeChip('道案内'),
                    _buildThemeChip('空港'),
                    _buildThemeChip('ホテル'),
                    _buildThemeChip('レストラン'),
                    _buildThemeChip('ショッピング'),
                    _buildThemeChip('交通機関'),
                    _buildThemeChip('ビジネスメール'),
                    _buildThemeChip('プレゼンテーション'),
                  ],
                ],
              ),
            ),
          // 会話リスト
          Expanded(
            child: conversationsAsync.when(
              data: (conversations) {
                if (conversations.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          '会話がまだ登録されていません',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return ConversationCard(conversation: conversation);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('エラー: $error'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeChip(String theme) {
    final isSelected = _selectedTheme == theme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(theme),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedTheme = selected ? theme : null);
        },
      ),
    );
  }
}

/// 会話カード（シチュエーション選択用）
/// 画像 + 会話内容を聴く / A役 / B役 の3モード選択
class ConversationCard extends StatelessWidget {
  final Conversation conversation;

  const ConversationCard({
    super.key,
    required this.conversation,
  });

  void _navigateToConversation(BuildContext context, String mode) {
    context.push('/conversation/${conversation.id}?mode=$mode');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // サムネイル（仮設定: thumbnailUrlがなければtemp_bgを使用）
          SizedBox(
            height: 140,
            width: double.infinity,
            child: conversation.thumbnailUrl != null
                ? OptimizedImage(
                    imageUrl: conversation.thumbnailUrl!,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    kScenarioBgAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (conversation.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    conversation.description!,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
                if (conversation.theme != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: EngrowthColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      conversation.theme!,
                      style: TextStyle(
                        fontSize: 12,
                        color: EngrowthColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // モード選択ボタン
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToConversation(context, 'listen'),
                        icon: const Icon(Icons.headphones, size: 18),
                        label: const Text('聴く', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          foregroundColor: EngrowthColors.primary,
                          side: const BorderSide(color: EngrowthColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToConversation(context, 'roleA'),
                        icon: const Icon(Icons.person, size: 18),
                        label: const Text('A役', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          foregroundColor: EngrowthColors.roleA,
                          side: const BorderSide(color: EngrowthColors.roleA),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToConversation(context, 'roleB'),
                        icon: const Icon(Icons.person_outline, size: 18),
                        label: const Text('B役', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          foregroundColor: EngrowthColors.roleB,
                          side: const BorderSide(color: EngrowthColors.roleB),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
