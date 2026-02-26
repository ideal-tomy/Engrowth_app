import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/story_theme_categories.dart';
import '../models/story_sequence.dart';
import '../providers/analytics_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/section_nudge_provider.dart';
import '../providers/story_provider.dart';
import '../screens/story_study_screen.dart';
import '../theme/engrowth_theme.dart';
import '../widgets/optimized_image.dart';
import '../widgets/debug_completion_fab.dart';
import '../widgets/scroll_target_wrapper.dart';
import '../widgets/scenario_background.dart';

/// 3分英会話の進捗ボード（Speak風：セクション＋ずらしカードリスト）
class StoryProgressBoardScreen extends ConsumerWidget {
  const StoryProgressBoardScreen({super.key, this.scrollToNext = false});

  final bool scrollToNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(storySequencesByThemeProvider);
    final targetIdAsync = ref.watch(firstIncompleteStoryIdProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('3分英会話 進捗'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      floatingActionButton: const DebugCompletionFab(track: 'story'),
      body: dataAsync.when(
        data: (byTheme) {
          if (byTheme.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_stories, size: 64, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    '3分英会話は準備中です',
                    style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.outline),
                  ),
                ],
              ),
            );
          }
          final sortedThemes = byTheme.keys.toList()
            ..sort((a, b) => orderForTheme(a).compareTo(orderForTheme(b)));
          final isAnonymous = ref.watch(isAnonymousProvider);
          final targetId = targetIdAsync.valueOrNull;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              Text(
                '一歩ずつ進もう',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 20),
              ...sortedThemes.asMap().entries.expand((sectionEntry) {
                final partIndex = sectionEntry.key + 1;
                final theme = sectionEntry.value;
                final stories = byTheme[theme] ?? [];
                if (stories.isEmpty) return <Widget>[];
                final partTitle = displayNameForTheme(theme);
                return [
                  _SectionBanner(
                    partNumber: partIndex,
                    title: partTitle,
                    icon: _iconForTheme(theme),
                  ),
                  const SizedBox(height: 12),
                  _SectionNudge(theme: theme, stories: stories),
                  ..._storiesWithGlobalIndex(stories, sectionEntry.key, sortedThemes, byTheme).map((e) {
                    final globalIndex = e.$1;
                    final story = e.$2;
                    final isScrollTarget = scrollToNext && targetId == story.id;
                    return _StoryLessonCard(
                      story: story,
                      globalIndex: globalIndex,
                      isScrollTarget: isScrollTarget,
                      scrollToNext: scrollToNext,
                      targetId: targetId,
                    );
                  }),
                  const SizedBox(height: 24),
                ];
              }),
              if (isAnonymous) ...[
                const SizedBox(height: 8),
                const _AnonymousSaveNudgeStory(),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('読み込みエラー: $e', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconForTheme(String theme) {
    for (final c in kStoryThemeCategories) {
      if (c.theme == theme) {
        switch (c.iconName) {
          case 'local_cafe':
            return Icons.local_cafe;
          case 'flight':
            return Icons.flight;
          case 'hotel':
            return Icons.hotel;
          case 'waving_hand':
            return Icons.waving_hand;
          case 'directions':
            return Icons.directions;
          case 'shopping_bag':
            return Icons.shopping_bag;
          case 'directions_bus':
            return Icons.directions_bus;
          case 'email':
            return Icons.email;
          case 'account_balance':
            return Icons.account_balance;
          case 'badge':
            return Icons.badge;
          case 'slide_presentation':
            return Icons.slideshow;
          case 'category':
            return Icons.category;
          case 'local_post_office':
            return Icons.local_post_office;
          case 'local_hospital':
            return Icons.local_hospital;
          case 'school':
            return Icons.school;
          default:
            return Icons.auto_stories;
        }
      }
    }
    return Icons.auto_stories;
  }
}

Iterable<(int, StorySequence)> _storiesWithGlobalIndex(
  List<StorySequence> stories,
  int sectionIndex,
  List<String> sortedThemes,
  Map<String, List<StorySequence>> byTheme,
) sync* {
  var globalIndex = 0;
  for (var s = 0; s < sectionIndex; s++) {
    globalIndex += (byTheme[sortedThemes[s]] ?? []).length;
  }
  for (final story in stories) {
    yield (globalIndex++, story);
  }
}

/// Speak風：セクションヘッダー（大タイトル）
class _SectionBanner extends StatelessWidget {
  final int partNumber;
  final String title;
  final IconData icon;

  const _SectionBanner({
    required this.partNumber,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text(
            '第$partNumber部',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// リストカードを左右交互に配置（1つ目＝左寄せ72%、2つ目＝右寄せ72%、3つ目＝左…）
double _offsetForIndex(int globalIndex, double width) {
  final cardWidth = width * 0.72;
  if (globalIndex.isOdd) {
    return width - cardWidth; // 2,4,6…番目：右端に揃える
  }
  return 0; // 1,3,5…番目：左端に揃える
}

/// Speak風：横長レッスンカード（CircleAvatar + タイトル）
class _StoryLessonCard extends ConsumerWidget {
  final StorySequence story;
  final int globalIndex;
  final bool isScrollTarget;
  final bool scrollToNext;
  final String? targetId;

  const _StoryLessonCard({
    required this.story,
    required this.globalIndex,
    required this.isScrollTarget,
    required this.scrollToNext,
    this.targetId,
  });

  Future<void> _openTrainingSheet(BuildContext context, WidgetRef ref) async {
    final media = MediaQuery.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (sheetCtx) => SizedBox(
        height: media.size.height * 0.94,
        child: StoryStudyScreen(
          storyId: story.id,
          asSheet: true,
          autoStartPlayback: true,
          onClose: () => Navigator.of(sheetCtx).pop(),
        ),
      ),
    );
    ref.invalidate(storyProgressProvider(story.id));
    ref.invalidate(firstIncompleteStoryIdProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(storyProgressProvider(story.id));
    return progressAsync.when(
      data: (progress) => _buildCard(context, ref,
          isCompleted: progress?.completedAt != null,
          hasResume: progress != null &&
              progress.lastConversationId != null &&
              progress.completedAt == null),
      loading: () => _buildCard(context, ref, isCompleted: false, hasResume: false),
      error: (_, __) => _buildCard(context, ref, isCompleted: false, hasResume: false),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref,
      {required bool isCompleted, required bool hasResume}) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width - 32;
    final cardWidth = width * 0.72;
    final offset = _offsetForIndex(globalIndex, width);

    final cardBg = theme.brightness == Brightness.light
        ? EngrowthColors.cardSurfaceLight
        : theme.colorScheme.surface;
    final card = Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(24),
      elevation: theme.brightness == Brightness.light ? 2 : 0,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.08),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(analyticsServiceProvider).logProgressNodeTapped(
                nodeId: story.id,
                track: 'story',
              );
          _openTrainingSheet(context, ref);
        },
        borderRadius: BorderRadius.circular(24),
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        highlightColor: theme.colorScheme.primary.withOpacity(0.05),
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: theme.brightness == Brightness.dark
                ? Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3))
                : null,
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: story.thumbnailUrl != null
                        ? ClipOval(
                            child: OptimizedImage(
                              imageUrl: story.thumbnailUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            kScenarioBgAsset,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            errorBuilder: (_, __, ___) =>
                                Icon(Icons.auto_stories, color: theme.colorScheme.outline),
                          ),
                  ),
                  if (isCompleted)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check, color: theme.colorScheme.onPrimary, size: 14),
                      ),
                    )
                  else if (hasResume)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.play_arrow, color: theme.colorScheme.onPrimary, size: 14),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  story.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.outline, size: 20),
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(left: offset, right: width - cardWidth - offset, bottom: 12),
      child: ScrollTargetWrapper(
        isTarget: isScrollTarget,
        unlockSnackBarMessage: isScrollTarget ? '次のストーリーが解放されました' : null,
        child: card,
      ),
    );
  }
}

/// 継続のナッジ：「あと1つでこの章がクリアです！」
class _SectionNudge extends ConsumerWidget {
  final String theme;
  final List<StorySequence> stories;

  const _SectionNudge({required this.theme, required this.stories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (stories.length <= 1) return const SizedBox.shrink();
    int completed = 0;
    for (final s in stories) {
      if (ref.watch(storyProgressProvider(s.id)).valueOrNull?.completedAt != null) completed++;
    }
    final oneLeft = completed == stories.length - 1;
    final cooldown = ref.watch(sectionNudgeCooldownProvider);
    final wasOneLeft = ref.watch(sectionNudgeWasOneLeftProvider);

    if (!oneLeft) {
      if (wasOneLeft[theme] == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(sectionNudgeCooldownProvider.notifier).update(
                (m) => {...m, theme: DateTime.now()},
              );
          ref.read(sectionNudgeWasOneLeftProvider.notifier).update(
                (m) => {...m, theme: false},
              );
        });
      }
      return const SizedBox.shrink();
    }

    if (wasOneLeft[theme] != true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(sectionNudgeWasOneLeftProvider.notifier).update(
              (m) => {...m, theme: true},
            );
      });
    }
    final last = cooldown[theme];
    if (last != null && DateTime.now().difference(last) < nudgeCooldown) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: EngrowthColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: EngrowthColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events_outlined, size: 18, color: EngrowthColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'あと1つでこの章がクリアです！',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnonymousSaveNudgeStory extends ConsumerStatefulWidget {
  const _AnonymousSaveNudgeStory();

  @override
  ConsumerState<_AnonymousSaveNudgeStory> createState() =>
      _AnonymousSaveNudgeStoryState();
}

class _AnonymousSaveNudgeStoryState extends ConsumerState<_AnonymousSaveNudgeStory> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).logAnonSaveNudgeShown(source: 'story_board');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(analyticsServiceProvider).logAnonSaveNudgeCta(source: 'story_board');
          context.push('/account');
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(Icons.cloud_outlined, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '進捗を端末替えても引き継ぐにはアカウント作成がおすすめです',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
