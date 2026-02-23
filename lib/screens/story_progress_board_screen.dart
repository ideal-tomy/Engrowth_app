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
import '../widgets/simple_learning_path_painter.dart';
import '../widgets/debug_completion_fab.dart';
import '../widgets/scroll_target_wrapper.dart';
import '../widgets/scenario_background.dart';

// Bプラン：固定レイアウト定数（パスとノード位置を一致させる）
const _kIntroHeight = 56.0; // padding 16 + テキスト行 + 20
const _kSectionBannerHeight = 82.0;
const _kSectionGap = 12.0;
const _kSectionNudgeHeight = 50.0;
// ノード行50px・高さの差は半分で詰める（学習演出・次の意欲を促す）
const _kNodeRowHeight = 50.0;
const _kNodeCenterOffset = 25.0;
const _kSegmentHeight = 20.0; // 区間をさらに短く
const _kLastInSectionBottom = 6.0;
/// 章をまたいでも道が続くように区切りを詰める
const _kSectionBottomGap = 12.0;

/// 折り返し 4:4 の繰り返し（章タイトルが挟まっても globalIndex で継続）
/// laneパターンを固定して、右側だけ距離が長く見える問題を抑える
const _kLanePattern = [0, 1, 2, 3, 2, 1, 0, 1]; // 4:4 の連続
double _nodeXAt(int globalIndex, double width) {
  const left = 0.2;
  const right = 0.8;
  const laneStep = (right - left) / 3; // 0.2
  final lane = _kLanePattern[globalIndex % _kLanePattern.length];
  return width * (left + laneStep * lane);
}

class _StoryPathLayoutData {
  const _StoryPathLayoutData({
    required this.points,
    required this.rowInfos,
    required this.totalHeight,
  });
  final List<Offset> points;
  final List<({double rowTop, double rowHeight, double nodeX})> rowInfos;
  final double totalHeight;
}

_StoryPathLayoutData? _computeStoryPathLayout({
  required List<String> sortedThemes,
  required Map<String, List<StorySequence>> byTheme,
  required double width,
  required List<int> sectionNudgeHeights,
}) {
  final points = <Offset>[];
  final rowInfos = <({double rowTop, double rowHeight, double nodeX})>[];
  var offset = _kIntroHeight;
  var globalIndex = 0;
  for (var s = 0; s < sortedThemes.length; s++) {
    final theme = sortedThemes[s];
    final stories = byTheme[theme] ?? [];
    if (stories.isEmpty) continue;
    final nudgeH = (sectionNudgeHeights.length > s) ? sectionNudgeHeights[s].toDouble() : 0.0;
    offset += _kSectionBannerHeight + _kSectionGap + nudgeH;
    for (var i = 0; i < stories.length; i++) {
      final isLast = i == stories.length - 1;
      final rowHeight = isLast
          ? _kNodeRowHeight + _kLastInSectionBottom
          : _kNodeRowHeight + _kSegmentHeight;
      final rowTop = offset;
      final nodeCenterY = rowTop + _kNodeCenterOffset;
      final nodeX = _nodeXAt(globalIndex, width);
      points.add(Offset(nodeX, nodeCenterY));
      rowInfos.add((rowTop: rowTop, rowHeight: rowHeight, nodeX: nodeX));
      offset += rowHeight;
      globalIndex++;
    }
    offset += _kSectionBottomGap;
  }
  if (points.isEmpty) return null;
  return _StoryPathLayoutData(
    points: points,
    rowInfos: rowInfos,
    totalHeight: offset,
  );
}

/// 3分英会話のすごろく進捗ボード
/// テーマ別にストーリーをマスとして表示し、タップで学習へ遷移
class StoryProgressBoardScreen extends ConsumerWidget {
  const StoryProgressBoardScreen({super.key, this.scrollToNext = false});

  final bool scrollToNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(storySequencesByThemeProvider);
    final targetIdAsync = ref.watch(firstIncompleteStoryIdProvider);

    return Scaffold(
      backgroundColor: EngrowthColors.backgroundSoft,
      appBar: AppBar(
        title: const Text('3分英会話 進捗'),
        backgroundColor: EngrowthColors.surface,
        foregroundColor: EngrowthColors.onBackground,
      ),
      floatingActionButton: const DebugCompletionFab(track: 'story'),
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
          final targetId = targetIdAsync.valueOrNull;

          // Bプラン：全ストーリーを順に並べ、クリア数を算出
          final orderedStories = <StorySequence>[];
          for (final theme in sortedThemes) {
            final list = byTheme[theme] ?? [];
            orderedStories.addAll(list);
          }
          var clearedCount = 0;
          for (final story in orderedStories) {
            final progress = ref.watch(storyProgressProvider(story.id)).valueOrNull;
            if (progress?.completedAt == null) break;
            clearedCount++;
          }
          if (clearedCount > orderedStories.length) clearedCount = orderedStories.length;

          // セクションごとの「あと1つ」ナッジ有無（パス高さ計算用）
          final sectionNudgeHeights = <int>[];
          for (final theme in sortedThemes) {
            final stories = byTheme[theme] ?? [];
            if (stories.length <= 1) {
              sectionNudgeHeights.add(0);
              continue;
            }
            var completed = 0;
            for (final s in stories) {
              if (ref.watch(storyProgressProvider(s.id)).valueOrNull?.completedAt != null) {
                completed++;
              }
            }
            sectionNudgeHeights.add(
                completed == stories.length - 1 ? _kSectionNudgeHeight.round() : 0);
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final pathData = _computeStoryPathLayout(
                sortedThemes: sortedThemes,
                byTheme: byTheme,
                width: w,
                sectionNudgeHeights: sectionNudgeHeights,
              );
              if (pathData == null) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('一歩ずつ進もう'),
                    if (isAnonymous) const _AnonymousSaveNudgeStory(),
                  ],
                );
              }
              final totalHeight = pathData.totalHeight;
              final pathPoints = pathData.points;
              final rowInfos = pathData.rowInfos;
              final highlightSegmentIndex =
                  (targetId != null && clearedCount > 0 && clearedCount < pathPoints.length)
                      ? clearedCount - 1
                      : null;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SizedBox(
                    height: totalHeight,
                    width: w,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFF7F8FC),
                                  Color(0xFFF0F3FA),
                                  Color(0xFFEBEEF7),
                                ],
                              ),
                            ),
                            child: Opacity(
                              opacity: 0.05,
                              child: Image(
                                image: AssetImage(kScenarioBgAsset),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: SimpleLearningPath(
                            points: pathPoints,
                            clearedCount: clearedCount,
                            highlightSegmentIndex: highlightSegmentIndex,
                            width: w,
                            height: totalHeight,
                            strokeWidth: 12.0,
                          ),
                        ),
                        _StoryPathContentColumn(
                          width: w,
                          sortedThemes: sortedThemes,
                          byTheme: byTheme,
                          rowInfos: rowInfos,
                          sectionNudgeHeights: sectionNudgeHeights,
                          scrollToNext: scrollToNext,
                          targetId: targetId,
                        ),
                      ],
                    ),
                  ),
                  if (isAnonymous) ...[
                    const SizedBox(height: 8),
                    const _AnonymousSaveNudgeStory(),
                  ],
                ],
              );
            },
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

/// Bプラン：パス上に重ねるコンテンツ（バナー＋ノードカード）
class _StoryPathContentColumn extends ConsumerWidget {
  final double width;
  final List<String> sortedThemes;
  final Map<String, List<StorySequence>> byTheme;
  final List<({double rowTop, double rowHeight, double nodeX})> rowInfos;
  final List<int> sectionNudgeHeights;
  final bool scrollToNext;
  final String? targetId;

  const _StoryPathContentColumn({
    required this.width,
    required this.sortedThemes,
    required this.byTheme,
    required this.rowInfos,
    required this.sectionNudgeHeights,
    required this.scrollToNext,
    this.targetId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var globalIndex = 0;
    final columnChildren = <Widget>[
      SizedBox(
        height: _kIntroHeight,
        width: width,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '一歩ずつ進もう',
            style: TextStyle(
              fontSize: 14,
              color: EngrowthColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    ];
    for (var s = 0; s < sortedThemes.length; s++) {
      final theme = sortedThemes[s];
      final stories = byTheme[theme] ?? [];
      if (stories.isEmpty) continue;
      final partIndex = s + 1;
      final partTitle = displayNameForTheme(theme);
      columnChildren.add(SizedBox(
        height: _kSectionBannerHeight,
        child: _SectionBanner(
          partNumber: partIndex,
          title: partTitle,
          icon: StoryProgressBoardScreen._iconForTheme(theme),
        ),
      ));
      columnChildren.add(const SizedBox(height: _kSectionGap));
      final nudgeH = (sectionNudgeHeights.length > s) ? sectionNudgeHeights[s] : 0;
      if (nudgeH > 0) {
        columnChildren.add(SizedBox(
          height: nudgeH.toDouble(),
          child: _SectionNudge(theme: theme, stories: stories),
        ));
      }
      for (var i = 0; i < stories.length; i++) {
        if (globalIndex >= rowInfos.length) break;
        final story = stories[i];
        final info = rowInfos[globalIndex];
        final isScrollTarget = scrollToNext && targetId == story.id;
        final isNextTarget = targetId == story.id;
        final unlockSnackBarMessage =
            isScrollTarget ? '次のストーリーが解放されました' : null;
        final progressAsync = ref.watch(storyProgressProvider(story.id));
        columnChildren.add(progressAsync.when(
          data: (progress) {
            final isCompleted = progress?.completedAt != null;
            final hasResume = progress != null &&
                progress.lastConversationId != null &&
                progress.completedAt == null;
            return _storyRow(
              context,
              ref,
              info: info,
              story: story,
              index: i + 1,
              isScrollTarget: isScrollTarget,
              isNextTarget: isNextTarget,
              unlockSnackBarMessage: unlockSnackBarMessage,
              isCompleted: isCompleted,
              hasResume: hasResume,
            );
          },
          loading: () => _storyRow(
            context,
            ref,
            info: info,
            story: story,
            index: i + 1,
            isScrollTarget: isScrollTarget,
            isNextTarget: isNextTarget,
            unlockSnackBarMessage: unlockSnackBarMessage,
            isCompleted: false,
            hasResume: false,
          ),
          error: (_, __) => _storyRow(
            context,
            ref,
            info: info,
            story: story,
            index: i + 1,
            isScrollTarget: isScrollTarget,
            isNextTarget: isNextTarget,
            unlockSnackBarMessage: unlockSnackBarMessage,
            isCompleted: false,
            hasResume: false,
          ),
        ));
        globalIndex++;
      }
      columnChildren.add(const SizedBox(height: _kSectionBottomGap));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columnChildren,
    );
  }

  Future<void> _openStoryTrainingSheet(
    BuildContext context,
    WidgetRef ref,
    StorySequence story,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (sheetCtx) => FractionallySizedBox(
        heightFactor: 0.94,
        child: StoryStudyScreen(
          storyId: story.id,
          asSheet: true,
          autoStartPlayback: true,
          onClose: () => Navigator.of(sheetCtx).pop(),
        ),
      ),
    );
    // シートを閉じたら進捗を再取得し、マップの赤道アニメへ反映
    ref.invalidate(storyProgressProvider(story.id));
    ref.invalidate(firstIncompleteStoryIdProvider);
  }

  Widget _storyRow(
    BuildContext context,
    WidgetRef ref, {
    required ({double rowTop, double rowHeight, double nodeX}) info,
    required StorySequence story,
    required int index,
    required bool isScrollTarget,
    required bool isNextTarget,
    required String? unlockSnackBarMessage,
    required bool isCompleted,
    required bool hasResume,
  }) {
    const nodeWidth = 100.0;
    final left = (info.nodeX - nodeWidth / 2).clamp(0.0, width - nodeWidth);
    return SizedBox(
      height: info.rowHeight,
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: left,
            top: 0,
            child: ScrollTargetWrapper(
              isTarget: isScrollTarget,
              unlockSnackBarMessage: unlockSnackBarMessage,
              child: SizedBox(
                width: nodeWidth,
                child: _StoryMasuCard(
                  story: story,
                  index: index,
                  isCompleted: isCompleted,
                  isInProgress: hasResume,
                  isNextTarget: isNextTarget,
                  compactMode: true,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(analyticsServiceProvider).logProgressNodeTapped(
                          nodeId: story.id,
                          track: 'story',
                        );
                    _openStoryTrainingSheet(context, ref, story);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 継続のナッジ：「あと1つでこの章がクリアです！」（クールダウン付き）
class _SectionNudge extends ConsumerWidget {
  final String theme;
  final List<StorySequence> stories;

  const _SectionNudge({required this.theme, required this.stories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (stories.length <= 1) return const SizedBox.shrink();
    int completed = 0;
    for (final s in stories) {
      final async = ref.watch(storyProgressProvider(s.id));
      if (async.valueOrNull?.completedAt != null) completed++;
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
                  color: EngrowthColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

class _StoryMasuCard extends StatefulWidget {
  final StorySequence story;
  final int index;
  final bool isCompleted;
  final bool isInProgress;
  final VoidCallback onTap;
  /// マップ用：円のみ表示し、タップでポップアップ（タイトル＋トレーニングスタート）
  final bool compactMode;
  /// 次のコンテンツ（未クリアの先頭）：フラッシュで光らせる
  final bool isNextTarget;

  const _StoryMasuCard({
    required this.story,
    required this.index,
    required this.isCompleted,
    required this.isInProgress,
    required this.onTap,
    this.compactMode = false,
    this.isNextTarget = false,
  });

  @override
  State<_StoryMasuCard> createState() => _StoryMasuCardState();
}

class _StoryMasuCardState extends State<_StoryMasuCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;

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
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _flashAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeInOut),
    );
    if (widget.isNextTarget) {
      _flashController.repeat(reverse: true);
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
    if (widget.isNextTarget && !_flashController.isAnimating) {
      _flashController.repeat(reverse: true);
    }
    if (!widget.isNextTarget && _flashController.isAnimating) {
      _flashController.stop();
      _flashController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  void _showStoryPopup(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: EngrowthColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.story.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: EngrowthColors.onBackground,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.onTap();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: EngrowthColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('トレーニングスタート'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _flashController]),
      builder: (context, child) {
        final inProgressScale = widget.isInProgress
            ? (_pulseController.value * 0.02)
            : 0.0;
        final nextTargetScale = widget.isNextTarget
            ? (0.01 + _flashAnimation.value * 0.04)
            : 0.0;
        final scale = 1.0 + inProgressScale + nextTargetScale;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.compactMode ? () => _showStoryPopup(context) : widget.onTap,
          borderRadius: BorderRadius.circular(40),
          splashColor: EngrowthColors.primary.withOpacity(0.2),
          highlightColor: EngrowthColors.primary.withOpacity(0.08),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Duolingo風：丸ノード＋シーン画像（クリアで赤枠＝道が染まったイメージ）
              Stack(
                alignment: Alignment.bottomRight,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isCompleted
                            ? EngrowthColors.primary
                            : widget.isInProgress
                                ? EngrowthColors.primary.withOpacity(0.6)
                                : widget.isNextTarget
                                    ? EngrowthColors.primary.withOpacity(0.6 + _flashAnimation.value * 0.35)
                                    : EngrowthColors.silverBorder,
                        width: widget.isCompleted || widget.isInProgress ? 3 : (widget.isNextTarget ? 3 : 2),
                      ),
                      boxShadow: [
                        ...EngrowthShadows.softCard,
                        if (widget.isNextTarget)
                          BoxShadow(
                            color: EngrowthColors.primary.withOpacity(0.3 + _flashAnimation.value * 0.45),
                            blurRadius: 10 + _flashAnimation.value * 16,
                            spreadRadius: 1 + _flashAnimation.value * 3,
                          ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: widget.story.thumbnailUrl != null
                        ? OptimizedImage(
                            imageUrl: widget.story.thumbnailUrl!,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            kScenarioBgAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.grey[300]),
                          ),
                  ),
                  if (widget.isCompleted)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: EngrowthColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    )
                  else if (widget.isInProgress)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: EngrowthColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
              if (!widget.compactMode) ...[
                const SizedBox(height: 6),
                SizedBox(
                  width: 88,
                  child: Text(
                    widget.story.title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.isCompleted
                          ? EngrowthColors.onSurface
                          : EngrowthColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
