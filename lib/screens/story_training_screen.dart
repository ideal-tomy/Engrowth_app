import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/story_theme_categories.dart';
import '../models/story_sequence.dart';
import '../providers/story_provider.dart';
import '../theme/engrowth_theme.dart';
import '../widgets/optimized_image.dart';
import '../widgets/scenario_background.dart';

/// 3分英会話トレーニング専用ページ
/// カテゴリ（テーマ）別にストーリーカードを横スクロール表示
class StoryTrainingScreen extends ConsumerWidget {
  const StoryTrainingScreen({super.key});

  static String _iconNameForTheme(String theme) {
    for (final c in kStoryThemeCategories) {
      if (c.theme == theme) return c.iconName;
    }
    return 'auto_stories';
  }

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
      case 'directions':
        return Icons.directions;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'account_balance':
        return Icons.account_balance;
      case 'local_post_office':
        return Icons.local_post_office;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'waving_hand':
        return Icons.waving_hand;
      case 'badge':
        return Icons.badge;
      case 'email':
        return Icons.email;
      case 'school':
        return Icons.school;
      case 'category':
        return Icons.category;
      case 'slide_presentation':
        return Icons.slideshow;
      default:
        return Icons.auto_stories;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(storySequencesByThemeProvider);

    return Scaffold(
      backgroundColor: EngrowthColors.background,
      appBar: AppBar(
        title: const Text('3分会話トレーニング'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/account'),
            tooltip: 'アカウント',
          ),
        ],
      ),
      body: dataAsync.when(
        data: (byTheme) {
          if (byTheme.isEmpty) {
            return _buildEmptyState(context);
          }
          // 表示順にソート
          final sortedThemes = byTheme.keys.toList()
            ..sort((a, b) => orderForTheme(a).compareTo(orderForTheme(b)));

          return ListView(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            children: sortedThemes.map((theme) {
              final stories = byTheme[theme] ?? [];
              if (stories.isEmpty) return const SizedBox.shrink();
              return _StoryThemeSection(
                theme: theme,
                displayName: displayNameForTheme(theme),
                icon: _iconForCategory(_iconNameForTheme(theme)),
                stories: stories,
              );
            }).toList(),
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
                style: const TextStyle(
                    fontSize: 14, color: EngrowthColors.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories, size: 64, color: EngrowthColors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              '3分英会話は準備中です',
              style: TextStyle(
                fontSize: 16,
                color: EngrowthColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryThemeSection extends ConsumerWidget {
  final String theme;
  final String displayName;
  final IconData icon;
  final List<StorySequence> stories;

  const _StoryThemeSection({
    required this.theme,
    required this.displayName,
    required this.icon,
    required this.stories,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 24, color: EngrowthColors.primary),
              const SizedBox(width: 8),
              Text(
                '$displayName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: EngrowthColors.onBackground,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '（${stories.length}本）',
                style: TextStyle(
                  fontSize: 14,
                  color: EngrowthColors.onSurfaceVariant,
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
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _StorySequenceCard(story: story),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

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
              return _buildCard(context, '準備中', hasResume: false);
            }
            return _buildCard(context, story.title, hasResume: hasResume);
          },
          loading: () => _buildCard(context, story.title, hasResume: false),
          error: (_, __) => _buildCard(context, story.title, hasResume: false),
        );
      },
      loading: () => _buildCard(context, story.title, hasResume: false),
      error: (_, __) => _buildCard(context, story.title, hasResume: false),
    );
  }

  Widget _buildCard(BuildContext context, String title, {required bool hasResume}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/story/${story.id}');
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
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
