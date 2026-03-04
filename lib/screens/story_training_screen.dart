import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/story_theme_categories.dart';
import '../models/story_sequence.dart';
import '../providers/analytics_provider.dart';
import '../providers/feedback_provider.dart';
import '../providers/story_provider.dart';
import '../providers/transition_metrics_provider.dart';
import '../models/learning_handoff_result.dart';
import '../theme/engrowth_theme.dart';
import '../widgets/optimized_image.dart';
import '../widgets/scenario_background.dart';
import '../widgets/favorite_toggle_icon.dart';
import '../widgets/tutorial/simulated_finger_overlay.dart';
import '../widgets/tutorial/learning_intro_dialog.dart';
import '../widgets/common/fade_slide_switcher.dart';
import '../widgets/common/stagger_reveal.dart';
import '../widgets/common/content_skeleton.dart';

/// 3分英会話トレーニング専用ページ
/// カテゴリ（テーマ）別にストーリーカードを横スクロール表示
class StoryTrainingScreen extends ConsumerStatefulWidget {
  const StoryTrainingScreen({super.key, this.fromOnboarding = false});

  final bool fromOnboarding;

  @override
  ConsumerState<StoryTrainingScreen> createState() => _StoryTrainingScreenState();
}

class _StoryTrainingScreenState extends ConsumerState<StoryTrainingScreen> {
  final GlobalKey _overlayTargetKey = GlobalKey();

  void _onOverlayComplete(StorySequence firstStory) {
    ref.read(analyticsServiceProvider).logTutorialStepAutoadvanced(
          stepType: 'focus3',
        );
    ref.read(analyticsServiceProvider).logTutorialOneTapStartSuccess(
          learningMode: 'focus3',
          targetId: firstStory.id,
        );
    LearningIntroDialog.show(
      context,
      title: '3分会話',
      body: '約3分の英会話ストーリーを体験します。会話の流れに沿って、聞いたり話したりを繰り返していきます。',
      onStart: () async {
        final uri = widget.fromOnboarding
            ? '/story/${firstStory.id}?from_onboarding=true'
            : '/story/${firstStory.id}';
        final result = await context.push<LearningHandoffResult>(uri);
        if (widget.fromOnboarding &&
            result != null &&
            result.completed &&
            mounted) {
          context.pop(result);
        }
      },
    );
  }

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
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(storySequencesByThemeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        title: const Text('3分会話トレーニング'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/account'),
            tooltip: 'アカウント',
          ),
        ],
      ),
      body: FadeSlideSwitcher(
        childKey: ValueKey(dataAsync.valueOrNull != null ? 'data' : dataAsync.hasError ? 'error' : 'loading'),
        child: dataAsync.when(
          data: (byTheme) {
          if (byTheme.isEmpty) {
            return _buildEmptyState(context);
          }
          final sortedThemes = byTheme.keys.toList()
            ..sort((a, b) => orderForTheme(a).compareTo(orderForTheme(b)));
          StorySequence? firstStory;
          if (widget.fromOnboarding) {
            for (final theme in sortedThemes) {
              final stories = byTheme[theme] ?? [];
              if (stories.isNotEmpty) {
                firstStory = stories.first;
                break;
              }
            }
          }
          final sectionWidgets = sortedThemes.asMap().entries
              .where((entry) => (byTheme[entry.value] ?? []).isNotEmpty)
              .map((entry) {
            final index = entry.key;
            final theme = entry.value;
            final stories = byTheme[theme] ?? [];
                    final isFirstSection = index == 0;
            return _StoryThemeSection(
              theme: theme,
              displayName: displayNameForTheme(theme),
              icon: _iconForCategory(_iconNameForTheme(theme)),
              stories: stories,
              overlayTargetKey: widget.fromOnboarding && isFirstSection
                  ? _overlayTargetKey
                  : null,
            );
          }).toList();
          final content = Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  children: [
                    StaggerReveal(
                      children: sectionWidgets,
                    ),
                  ],
                ),
              ),
              if (widget.fromOnboarding && firstStory != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '約3分・途中停止可',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '最初の挨拶を選択しました',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              ref.read(feedbackServiceProvider).selection(trigger: 'story_onboarding_start_selection');
                              ref.read(analyticsServiceProvider).logTutorialStepAutoadvanced(
                                    stepType: 'focus3',
                                  );
                              ref.read(analyticsServiceProvider).logTutorialOneTapStartSuccess(
                                    learningMode: 'focus3',
                                    targetId: firstStory!.id,
                                  );
                              ref.read(transitionMetricsProvider.notifier).recordTap(
                                    routeType: 'standardPush',
                                    fromRoute: '/story-training',
                                    toRoute: '/story/${firstStory.id}',
                                  );
                              context.push('/story/${firstStory.id}');
                            },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('はじめる'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );

          if (widget.fromOnboarding && firstStory != null) {
            final story = firstStory;
            return Stack(
              children: [
                content,
                Positioned.fill(
                  child: SimulatedFingerOverlay(
                    targetKey: _overlayTargetKey,
                    onComplete: () => _onOverlayComplete(story),
                  ),
                ),
              ],
            );
          }
          return content;
        },
          loading: () => const StoryListSkeleton(),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'エラー: $error',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
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
            Icon(Icons.auto_stories, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              '3分英会話は準備中です',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
  final GlobalKey? overlayTargetKey;

  const _StoryThemeSection({
    required this.theme,
    required this.displayName,
    required this.icon,
    required this.stories,
    this.overlayTargetKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _StoryThemeSectionBody(
      theme: theme,
      displayName: displayName,
      icon: icon,
      stories: stories,
      overlayTargetKey: overlayTargetKey,
    );
  }
}

class _StoryThemeSectionBody extends ConsumerStatefulWidget {
  final String theme;
  final String displayName;
  final IconData icon;
  final List<StorySequence> stories;
  final GlobalKey? overlayTargetKey;

  const _StoryThemeSectionBody({
    required this.theme,
    required this.displayName,
    required this.icon,
    required this.stories,
    this.overlayTargetKey,
  });

  @override
  ConsumerState<_StoryThemeSectionBody> createState() =>
      _StoryThemeSectionBodyState();
}

class _StoryThemeSectionBodyState extends ConsumerState<_StoryThemeSectionBody> {
  late final PageController _pageController;
  double _currentPage = 0;
  int _lastLoggedPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.34);
    _pageController.addListener(() {
      final page = _pageController.page ?? 0;
      if (!mounted) return;
      setState(() {
        _currentPage = page;
      });
      final rounded = page.round();
      if (rounded != _lastLoggedPage) {
        _lastLoggedPage = rounded;
        ref.read(analyticsServiceProvider).logUiSnapUsed(section: widget.theme);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(widget.icon, size: 24, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                widget.displayName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '（${widget.stories.length}本）',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _pageController,
            padEnds: false,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.stories.length,
            itemBuilder: (context, index) {
              final story = widget.stories[index];
              final distance = (_currentPage - index).abs();
              final cardScale = (1 - (distance * 0.06)).clamp(0.92, 1.0);
              final useOverlayKey = index == 0 && widget.overlayTargetKey != null;
              return Padding(
                key: useOverlayKey ? widget.overlayTargetKey : null,
                padding: EdgeInsets.only(
                  left: index == 0 ? 12 : 4,
                  right: index == widget.stories.length - 1 ? 12 : 4,
                ),
                child: Transform.scale(
                  scale: cardScale,
                  child: _StorySequenceCard(
                    story: story,
                    theme: widget.theme,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _StorySequenceCard extends ConsumerStatefulWidget {
  final StorySequence story;
  final String theme;

  const _StorySequenceCard({
    required this.story,
    required this.theme,
  });

  @override
  ConsumerState<_StorySequenceCard> createState() => _StorySequenceCardState();
}

class _StorySequenceCardState extends ConsumerState<_StorySequenceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(storyProgressProvider(widget.story.id));
    final conversationsAsync = ref.watch(storyConversationsProvider(widget.story.id));

    return progressAsync.when(
      data: (progress) {
        final hasResume = progress != null &&
            progress.lastConversationId != null &&
            progress.completedAt == null;
        final isCompleted = progress?.completedAt != null;
        return conversationsAsync.when(
          data: (conversations) {
            if (conversations.isEmpty) {
              return _buildCard(context, '準備中', hasResume: false, isCompleted: false);
            }
            return _buildCard(context, widget.story.title, hasResume: hasResume, isCompleted: isCompleted);
          },
          loading: () => _buildCard(context, widget.story.title, hasResume: false, isCompleted: false),
          error: (_, __) => _buildCard(context, widget.story.title, hasResume: false, isCompleted: false),
        );
      },
      loading: () => _buildCard(context, widget.story.title, hasResume: false, isCompleted: false),
      error: (_, __) => _buildCard(context, widget.story.title, hasResume: false, isCompleted: false),
    );
  }

  Widget _buildCard(BuildContext context, String title, {required bool hasResume, required bool isCompleted}) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutBack,
      scale: _pressed ? 0.97 : 1,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: () {
          ref.read(feedbackServiceProvider).selection(trigger: 'story_card_tap');
          ref.read(transitionMetricsProvider.notifier).recordTap(
                routeType: 'standardPush',
                fromRoute: '/story-training',
                toRoute: '/story/${widget.story.id}',
              );
          context.push('/story/${widget.story.id}');
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            boxShadow: Theme.of(context).brightness == Brightness.dark
                ? null
                : EngrowthShadows.softCard,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 背景画像（Hero: 一覧→詳細の連続感）
                Hero(
                  tag: 'storyHero_${widget.story.id}',
                  child: widget.story.thumbnailUrl != null
                      ? OptimizedImage(
                          imageUrl: widget.story.thumbnailUrl!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: _gradientForTheme(widget.theme),
                          ),
                          child: Image.asset(
                            kScenarioBgAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                          ),
                        ),
                ),
                // 下部グラデーション（テキスト可読性確保）
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.75),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),
                // お気に入り（右上）
                Positioned(
                  top: 8,
                  right: 8,
                  child: FavoriteToggleIcon(
                    targetType: 'story',
                    targetId: widget.story.id,
                    size: 22,
                  ),
                ),
                // 状態ピル（左上）
                if (hasResume)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '続きから',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else if (isCompleted)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '完了',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // タイトル・補足（画像上・下部）
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.graphic_eq,
                            size: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '約${widget.story.totalDurationMinutes}分',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _gradientForTheme(String theme) {
    switch (theme) {
      case 'cafe':
        return const LinearGradient(
          colors: [Color(0xFFEFE8E1), Color(0xFFD8DDE6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'airport':
        return const LinearGradient(
          colors: [Color(0xFFE6ECF5), Color(0xFFDDE2EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'office':
        return const LinearGradient(
          colors: [Color(0xFFECEFF3), Color(0xFFD6DBE3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFF0F1F4), Color(0xFFDDE1E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}
