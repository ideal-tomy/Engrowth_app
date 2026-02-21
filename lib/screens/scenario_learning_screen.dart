import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/scenario_categories.dart';
import '../models/conversation.dart';
import '../models/story_sequence.dart';
import '../providers/conversation_provider.dart';
import '../providers/story_provider.dart';
import '../theme/engrowth_theme.dart';
import '../widgets/optimized_image.dart';
import '../widgets/scenario_background.dart';

/// シナリオ学習ページ（Netflix型: セクション + 横スクロール行）
class ScenarioLearningScreen extends ConsumerWidget {
  const ScenarioLearningScreen({super.key});

  static IconData _iconForCategory(String iconName) {
    switch (iconName) {
      case 'local_cafe':
        return Icons.local_cafe;
      case 'hotel':
        return Icons.hotel;
      case 'flight':
        return Icons.flight;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_pharmacy':
        return Icons.local_pharmacy;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'card_travel':
        return Icons.card_travel;
      case 'waving_hand':
        return Icons.waving_hand;
      case 'account_balance':
        return Icons.account_balance;
      case 'directions':
        return Icons.directions;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(conversationsByCategoryWithSubsectionsProvider);

    return Scaffold(
      backgroundColor: EngrowthColors.background,
      appBar: AppBar(
        title: const Text('シナリオ学習'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/account'),
            tooltip: 'アカウント',
          ),
        ],
      ),
      body: dataAsync.when(
        data: (byCategory) {
          final items = <Widget>[];
          // 3分ストーリーセクション（最上段・再開ファースト）
          items.add(const _StorySectionHeader());
          items.add(const SizedBox(height: 16));
          for (final category in kScenarioCategories) {
            final subsections = byCategory[category.id] ?? [];
            for (final sub in subsections) {
              items.add(_ScenarioSection(
                category: category,
                icon: _iconForCategory(category.iconName),
                subTitle: sub.subTitle,
                conversations: sub.conversations,
              ));
            }
            // カテゴリに会話がない場合も空状態を1つ表示
            if (subsections.isEmpty) {
              items.add(_ScenarioSection(
                category: category,
                icon: _iconForCategory(category.iconName),
                subTitle: null,
                conversations: [],
              ));
            }
          }
          return ListView(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            children: items,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: EngrowthColors.error),
              const SizedBox(height: 16),
              Text(
                'エラー: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: EngrowthColors.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 3分ストーリーセクション（再開ファースト）
class _StorySectionHeader extends ConsumerWidget {
  const _StorySectionHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(storySequencesProvider);

    return storiesAsync.when(
      data: (sequences) {
        if (sequences.isEmpty) {
          return _buildPlaceholder(context);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.auto_stories, size: 24, color: EngrowthColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    '3分ストーリー',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: EngrowthColors.onBackground,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: sequences.length,
                itemBuilder: (context, index) {
                  final story = sequences[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _StorySequenceCard(story: story),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: EngrowthColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_stories, size: 32, color: EngrowthColors.onSurfaceVariant),
              const SizedBox(height: 8),
              Text(
                '3分ストーリー（準備中）',
                style: TextStyle(
                  fontSize: 14,
                  color: EngrowthColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ストーリーシーケンスカード（再開・続きからを最優先表示）
class _StorySequenceCard extends ConsumerWidget {
  final StorySequence story;

  const _StorySequenceCard({required this.story});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(storyProgressProvider(story.id));
    final conversationsAsync = ref.watch(storyConversationsProvider(story.id));

    return progressAsync.when(
      data: (progress) {
        final hasResume = progress != null &&
            progress.lastConversationId != null &&
            progress.completedAt == null;
        return conversationsAsync.when(
          data: (conversations) {
            if (conversations.isEmpty) {
              return _buildCard(context, '準備中', hasResume: false, conversationId: null, storyId: story.id);
            }
            final firstId = conversations.first.id;
            final resumeId = hasResume ? progress!.lastConversationId! : firstId;
            return _buildCard(
              context,
              story.title,
              hasResume: hasResume,
              conversationId: resumeId,
              storyId: story.id,
            );
          },
          loading: () => _buildCard(context, story.title, hasResume: false, conversationId: null, storyId: story.id),
          error: (_, __) => _buildCard(context, story.title, hasResume: false, conversationId: null, storyId: story.id),
        );
      },
      loading: () => _buildCard(context, story.title, hasResume: false, conversationId: null, storyId: story.id),
      error: (_, __) => _buildCard(context, story.title, hasResume: false, conversationId: null, storyId: story.id),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title, {
    required bool hasResume,
    required String? conversationId,
    required String storyId,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/story/$storyId');
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: EngrowthColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: story.thumbnailUrl != null
                        ? OptimizedImage(
                            imageUrl: story.thumbnailUrl!,
                            width: double.infinity,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            kScenarioBgAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.grey[300]),
                          ),
                  ),
                ),
                if (hasResume)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: EngrowthColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '続きから',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: EngrowthColors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '約${story.totalDurationMinutes}分',
                      style: TextStyle(
                        fontSize: 12,
                        color: EngrowthColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// セクション: タイトル + 横スクロールの会話カード行（最大10件）
class _ScenarioSection extends StatelessWidget {
  final ScenarioCategory category;
  final IconData icon;
  final String? subTitle;
  final List<Conversation> conversations;

  const _ScenarioSection({
    required this.category,
    required this.icon,
    this.subTitle,
    required this.conversations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 24, color: EngrowthColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subTitle != null
                      ? '${category.displayName} - $subTitle'
                      : category.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: EngrowthColors.onBackground,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: conversations.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _ScenarioConversationCard(
                        conversation: conversation,
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: EngrowthColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hourglass_empty,
                size: 40,
                color: EngrowthColors.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                '準備中',
                style: TextStyle(
                  fontSize: 14,
                  color: EngrowthColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 横スクロール用の会話カード（サムネイル + タイトル、タップで会話学習へ）
class _ScenarioConversationCard extends StatefulWidget {
  final Conversation conversation;

  const _ScenarioConversationCard({
    required this.conversation,
  });

  @override
  State<_ScenarioConversationCard> createState() => _ScenarioConversationCardState();
}

class _ScenarioConversationCardState extends State<_ScenarioConversationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.selectionClick();
        context.push('/conversation/${widget.conversation.id}?mode=listen');
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) => Transform.scale(
            scale: _scale.value,
            child: child,
          ),
          child: Container(
            width: 160,
            decoration: BoxDecoration(
              color: EngrowthColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: widget.conversation.thumbnailUrl != null
                      ? OptimizedImage(
                          imageUrl: widget.conversation.thumbnailUrl!,
                          width: double.infinity,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          kScenarioBgAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.grey[300]),
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.conversation.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: EngrowthColors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
