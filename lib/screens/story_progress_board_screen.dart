import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/story_theme_categories.dart';
import '../models/story_sequence.dart';
import '../providers/analytics_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/story_provider.dart';
import '../theme/engrowth_theme.dart';
import '../widgets/optimized_image.dart';
import '../widgets/scenario_background.dart';

/// 3分英会話のすごろく進捗ボード
/// テーマ別にストーリーをマスとして表示し、タップで学習へ遷移
class StoryProgressBoardScreen extends ConsumerWidget {
  const StoryProgressBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(storySequencesByThemeProvider);

    return Scaffold(
      backgroundColor: EngrowthColors.backgroundSoft,
      appBar: AppBar(
        title: const Text('3分英会話 進捗'),
        backgroundColor: EngrowthColors.surface,
        foregroundColor: EngrowthColors.onBackground,
      ),
      body: dataAsync.when(
        data: (byTheme) {
          if (byTheme.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_stories, size: 64, color: EngrowthColors.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    '3分英会話は準備中です',
                    style: TextStyle(fontSize: 16, color: EngrowthColors.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }
          final sortedThemes = byTheme.keys.toList()
            ..sort((a, b) => orderForTheme(a).compareTo(orderForTheme(b)));

          final isAnonymous = ref.watch(isAnonymousProvider);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '一歩ずつ進もう',
                style: TextStyle(
                  fontSize: 14,
                  color: EngrowthColors.onSurfaceVariant,
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
                  ...stories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final story = entry.value;
                    final isLastInSection = index == stories.length - 1;
                    return _StoryMasu(
                      story: story,
                      theme: theme,
                      index: index + 1,
                      showConnectorBelow: !isLastInSection,
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
              Icon(Icons.error_outline, size: 48, color: EngrowthColors.error),
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

/// Speak / Duolingo 風：セクション見出し（第○部 ＋ テーマ名）＋ 点線
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: EngrowthColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: EngrowthColors.primary,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: EngrowthColors.primary),
              const SizedBox(width: 10),
              Text(
                '第${partNumber}部',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: EngrowthColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: EngrowthColors.onBackground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(
              width: 24,
              child: CustomPaint(
                painter: _DottedLinePainter(
                  color: EngrowthColors.silverBorder,
                  dotRadius: 2,
                  spacing: 4,
                ),
                size: const Size(24, 16),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '第${partNumber}部 $title',
              style: TextStyle(
                fontSize: 12,
                color: EngrowthColors.onSurfaceVariant.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  final double dotRadius;
  final double spacing;

  _DottedLinePainter({
    required this.color,
    this.dotRadius = 2,
    this.spacing = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    double y = dotRadius;
    while (y < size.height) {
      canvas.drawCircle(Offset(size.width / 2, y), dotRadius, paint);
      y += dotRadius * 2 + spacing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
            color: EngrowthColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: EngrowthColors.silverBorder),
          ),
          child: Row(
            children: [
              Icon(Icons.cloud_outlined, size: 20, color: EngrowthColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '進捗を端末替えても引き継ぐにはアカウント作成がおすすめです',
                  style: TextStyle(
                    fontSize: 12,
                    color: EngrowthColors.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: EngrowthColors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryMasu extends ConsumerWidget {
  final StorySequence story;
  final String theme;
  final int index;
  final bool showConnectorBelow;

  const _StoryMasu({
    required this.story,
    required this.theme,
    required this.index,
    this.showConnectorBelow = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(storyProgressProvider(story.id));

    return progressAsync.when(
      data: (progress) {
        final isCompleted = progress?.completedAt != null;
        final hasResume = progress != null &&
            progress.lastConversationId != null &&
            progress.completedAt == null;

        return _StoryMasuWithConnector(
          showConnectorBelow: showConnectorBelow,
          child: _StoryMasuCard(
            story: story,
            index: index,
            isCompleted: isCompleted,
            isInProgress: hasResume,
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(analyticsServiceProvider).logProgressNodeTapped(nodeId: story.id, track: 'story');
              context.push('/story/${story.id}');
            },
          ),
        );
      },
      loading: () => _StoryMasuWithConnector(
        showConnectorBelow: showConnectorBelow,
        child: _StoryMasuCard(
          story: story,
          index: index,
          isCompleted: false,
          isInProgress: false,
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('/story/${story.id}');
          },
        ),
      ),
      error: (_, __) => _StoryMasuWithConnector(
        showConnectorBelow: showConnectorBelow,
        child: _StoryMasuCard(
          story: story,
          index: index,
          isCompleted: false,
          isInProgress: false,
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('/story/${story.id}');
          },
        ),
      ),
    );
  }
}

/// マスとマスの間の点線（進捗の道のりを表現）
class _StoryMasuWithConnector extends StatelessWidget {
  final bool showConnectorBelow;
  final Widget child;

  const _StoryMasuWithConnector({
    required this.showConnectorBelow,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!showConnectorBelow) {
      return Padding(padding: const EdgeInsets.only(bottom: 12), child: child);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(padding: const EdgeInsets.only(bottom: 4), child: child),
        SizedBox(
          height: 12,
          child: Center(
            child: CustomPaint(
              painter: _DottedLinePainter(
                color: EngrowthColors.silverBorder,
                dotRadius: 1.5,
                spacing: 3,
              ),
              size: const Size(2, 12),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _StoryMasuCard extends StatefulWidget {
  final StorySequence story;
  final int index;
  final bool isCompleted;
  final bool isInProgress;
  final VoidCallback onTap;

  const _StoryMasuCard({
    required this.story,
    required this.index,
    required this.isCompleted,
    required this.isInProgress,
    required this.onTap,
  });

  @override
  State<_StoryMasuCard> createState() => _StoryMasuCardState();
}

class _StoryMasuCardState extends State<_StoryMasuCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isInProgress) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _StoryMasuCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isInProgress && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
    if (!widget.isInProgress && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = widget.isInProgress
            ? 1.0 + (_pulseController.value * 0.02)
            : 1.0;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: EngrowthColors.primary.withOpacity(0.2),
          highlightColor: EngrowthColors.primary.withOpacity(0.08),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: EngrowthColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.isInProgress
                    ? EngrowthColors.primary.withOpacity(0.5)
                    : EngrowthColors.silverBorder,
                width: widget.isInProgress ? 2 : 1,
              ),
              boxShadow: EngrowthShadows.softCard,
            ),
            child: Row(
              children: [
                // Speak風：左側の円形サムネイル（アバター的）
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: EngrowthColors.silverShadow,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: widget.story.thumbnailUrl != null
                      ? OptimizedImage(
                          imageUrl: widget.story.thumbnailUrl!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          kScenarioBgAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.grey[300]),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.story.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: EngrowthColors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '約${widget.story.totalDurationMinutes}分',
                        style: TextStyle(
                          fontSize: 12,
                          color: EngrowthColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: EngrowthColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '完了',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: EngrowthColors.success,
                      ),
                    ),
                  )
                else if (widget.isInProgress)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: EngrowthColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '続きから',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: EngrowthColors.primary,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: EngrowthColors.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
