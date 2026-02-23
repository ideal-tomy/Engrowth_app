import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/scenario.dart';
import '../providers/analytics_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/scenario_provider.dart';
import '../providers/section_nudge_provider.dart';
import '../theme/engrowth_theme.dart';
import '../utils/learning_path_geometry.dart';
import '../widgets/continuous_path_segment.dart';
import '../widgets/debug_completion_fab.dart';
import '../widgets/optimized_image.dart';
import '../widgets/scroll_target_wrapper.dart';
import '../widgets/scenario_background.dart';

/// シナリオ学習のすごろく進捗ボード
/// 各シナリオをマスとして表示し、タップで学習へ遷移
class ScenarioProgressBoardScreen extends ConsumerWidget {
  const ScenarioProgressBoardScreen({super.key, this.scrollToNext = false});

  final bool scrollToNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsync = ref.watch(scenariosProvider);
    final targetIdAsync = ref.watch(firstIncompleteScenarioIdProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: EngrowthColors.backgroundSoft,
      appBar: AppBar(
        title: const Text('シナリオ進捗'),
        backgroundColor: EngrowthColors.surface,
        foregroundColor: EngrowthColors.onBackground,
      ),
      floatingActionButton: const DebugCompletionFab(track: 'scenario'),
      body: scenariosAsync.when(
        data: (scenarios) {
          if (scenarios.isEmpty) {
            return _ScenarioBoardBody(
              scenarios: _sampleScenariosForEmptyState(),
              userId: userId,
              isSamplePlaceholder: true,
              scrollToNext: scrollToNext,
              targetId: null,
            );
          }
          return _ScenarioBoardBody(
            scenarios: scenarios,
            userId: userId,
            scrollToNext: scrollToNext,
            targetId: targetIdAsync.valueOrNull,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ScenarioBoardBody(
          scenarios: _sampleScenariosForEmptyState(),
          userId: userId,
          isSamplePlaceholder: true,
          scrollToNext: scrollToNext,
          targetId: null,
        ),
      ),
    );
  }
}

/// 継続のナッジ：「あと1つでこの章がクリアです！」（クールダウン付き）
class _ScenarioSectionNudge extends ConsumerWidget {
  final List<Scenario> scenarios;

  const _ScenarioSectionNudge({required this.scenarios});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (scenarios.length <= 1) return const SizedBox.shrink();
    int completed = 0;
    for (final s in scenarios) {
      final progress = ref.watch(userScenarioProgressProvider(s.id)).valueOrNull;
      if (progress?.isCompleted == true) completed++;
    }
    final oneLeft = completed == scenarios.length - 1;
    const sectionKey = 'scenario';
    final cooldown = ref.watch(sectionNudgeCooldownProvider);
    final wasOneLeft = ref.watch(sectionNudgeWasOneLeftProvider);

    if (!oneLeft) {
      if (wasOneLeft[sectionKey] == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(sectionNudgeCooldownProvider.notifier).update(
                (m) => {...m, sectionKey: DateTime.now()},
              );
          ref.read(sectionNudgeWasOneLeftProvider.notifier).update(
                (m) => {...m, sectionKey: false},
              );
        });
      }
      return const SizedBox.shrink();
    }

    if (wasOneLeft[sectionKey] != true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(sectionNudgeWasOneLeftProvider.notifier).update(
              (m) => {...m, sectionKey: true},
            );
      });
    }
    final last = cooldown[sectionKey];
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

/// Duolingo / Speak 風：セクション見出し（第1部 シナリオ学習）＋ 点線
class _ScenarioSectionBanner extends StatelessWidget {
  final bool isSamplePlaceholder;

  const _ScenarioSectionBanner({this.isSamplePlaceholder = false});

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
              Icon(Icons.auto_stories, size: 22, color: EngrowthColors.primary),
              const SizedBox(width: 10),
              Text(
                '第1部',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: EngrowthColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isSamplePlaceholder ? 'シナリオ学習の道のり' : 'シナリオ学習',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: EngrowthColors.onBackground,
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
                painter: _ScenarioDottedLinePainter(
                  color: EngrowthColors.silverBorder,
                  dotRadius: 2,
                  spacing: 4,
                ),
                size: const Size(24, 16),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '一歩ずつ進もう',
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

class _ScenarioDottedLinePainter extends CustomPainter {
  final Color color;
  final double dotRadius;
  final double spacing;

  _ScenarioDottedLinePainter({
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

List<Scenario> _sampleScenariosForEmptyState() {
  final now = DateTime.now();
  return [
    Scenario(
      id: '_sample_1',
      title: '（サンプル）シナリオ1',
      estimatedMinutes: 5,
      createdAt: now,
      updatedAt: now,
    ),
    Scenario(
      id: '_sample_2',
      title: '（サンプル）シナリオ2',
      estimatedMinutes: 10,
      createdAt: now,
      updatedAt: now,
    ),
  ];
}

class _ScenarioBoardBody extends ConsumerStatefulWidget {
  final List<Scenario> scenarios;
  final String? userId;
  final bool isSamplePlaceholder;
  final bool scrollToNext;
  final String? targetId;

  const _ScenarioBoardBody({
    required this.scenarios,
    this.userId,
    this.isSamplePlaceholder = false,
    this.scrollToNext = false,
    this.targetId,
  });

  @override
  ConsumerState<_ScenarioBoardBody> createState() => _ScenarioBoardBodyState();
}

class _ScenarioBoardBodyState extends ConsumerState<_ScenarioBoardBody> {
  @override
  Widget build(BuildContext context) {
    final isAnonymous = ref.watch(isAnonymousProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final centerX = w / 2;
        final amplitude = w * 0.38;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.isSamplePlaceholder) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'シナリオが登録されていません。Supabase の scenarios テーブルにデータを登録すると、ここにすごろくで表示されます。',
                  style: TextStyle(
                    fontSize: 12,
                    color: EngrowthColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            _ScenarioSectionBanner(isSamplePlaceholder: widget.isSamplePlaceholder),
            const SizedBox(height: 16),
            _ScenarioSectionNudge(scenarios: widget.scenarios),
            ...widget.scenarios.asMap().entries.map((entry) {
              final index = entry.key;
              final scenario = entry.value;
              final showConnectorBelow = index < widget.scenarios.length - 1;
              final isScrollTarget = widget.scrollToNext && widget.targetId == scenario.id;
              final nextScenario = index < widget.scenarios.length - 1 ? widget.scenarios[index + 1] : null;
              final animateConnectorRed = widget.scrollToNext && widget.targetId == nextScenario?.id;
              final fromX = nodeXAt(index, centerX, amplitude);
              final toX = nodeXAt(index + 1, centerX, amplitude);
              final fromSlope = nodeSlopeAt(index, amplitude);
              final toSlope = nodeSlopeAt(index + 1, amplitude);
              return _SineWaveScenarioRow(
                fromX: fromX,
                toX: toX,
                fromSlope: fromSlope,
                toSlope: toSlope,
                width: w,
                showConnectorBelow: showConnectorBelow,
                isScrollTarget: isScrollTarget,
                unlockSnackBarMessage:
                    isScrollTarget ? '次のシナリオが解放されました' : null,
                scenario: scenario,
                index: index + 1,
                userId: widget.userId,
                isSamplePlaceholder: widget.isSamplePlaceholder || scenario.id.startsWith('_sample_'),
                animateConnectorRed: animateConnectorRed,
              );
            }),
            if (isAnonymous) ...[
              const SizedBox(height: 16),
              _AnonymousSaveNudge(),
            ],
          ],
        );
      },
    );
  }
}

/// 正弦波レイアウトの1行：ノード位置＋連続パス区間（シナリオ用）
class _SineWaveScenarioRow extends ConsumerWidget {
  final double fromX;
  final double toX;
  final double? fromSlope;
  final double? toSlope;
  final double width;
  final bool showConnectorBelow;
  final bool isScrollTarget;
  final String? unlockSnackBarMessage;
  final Scenario scenario;
  final int index;
  final String? userId;
  final bool isSamplePlaceholder;
  final bool animateConnectorRed;

  const _SineWaveScenarioRow({
    required this.fromX,
    required this.toX,
    this.fromSlope,
    this.toSlope,
    required this.width,
    required this.showConnectorBelow,
    required this.isScrollTarget,
    this.unlockSnackBarMessage,
    required this.scenario,
    required this.index,
    this.userId,
    required this.isSamplePlaceholder,
    required this.animateConnectorRed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isSamplePlaceholder) {
      return _buildRow(
        context,
        ref,
        isCompleted: false,
        isInProgress: index == 1,
      );
    }
    final progressAsync = ref.watch(userScenarioProgressProvider(scenario.id));
    final stepsAsync = ref.watch(scenarioStepsProvider(scenario.id));

    return progressAsync.when(
      data: (progress) {
        return stepsAsync.when(
          data: (steps) {
            final isCompleted = progress?.isCompleted ?? false;
            final currentStep = progress?.lastStepIndex ?? 0;
            final isInProgress = !isCompleted && currentStep > 0;
            return _buildRow(
              context,
              ref,
              isCompleted: isCompleted,
              isInProgress: isInProgress,
            );
          },
          loading: () => _buildRow(context, ref, isCompleted: false, isInProgress: false),
          error: (_, __) => _buildRow(context, ref, isCompleted: false, isInProgress: false),
        );
      },
      loading: () => _buildRow(context, ref, isCompleted: false, isInProgress: false),
      error: (_, __) => _buildRow(context, ref, isCompleted: false, isInProgress: false),
    );
  }

  Widget _buildRow(BuildContext context, WidgetRef ref,
      {required bool isCompleted, required bool isInProgress}) {
    const nodeWidth = 100.0;
    const nodeHeight = 110.0; // ノードカード高さ（72+6+テキスト）
    const segmentHeight = 52.0;

    final nodeChild = ScrollTargetWrapper(
      isTarget: isScrollTarget,
      unlockSnackBarMessage: unlockSnackBarMessage,
      child: SizedBox(
        width: nodeWidth,
        child: _MasuCard(
          scenario: scenario,
          index: index,
          isCompleted: isCompleted,
          isInProgress: isInProgress,
          onTap: isSamplePlaceholder
              ? () {
                  HapticFeedback.selectionClick();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('サンプル表示です。Supabase に scenarios を登録すると学習を開始できます'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              : () {
                  HapticFeedback.selectionClick();
                  ref.read(analyticsServiceProvider).logProgressNodeTapped(
                        nodeId: scenario.id,
                        track: 'scenario',
                      );
                  context.push('/scenario/${scenario.id}');
                },
        ),
      ),
    );

    final stackNode = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: (fromX - nodeWidth / 2).clamp(0.0, width - nodeWidth),
          top: 0,
          child: nodeChild,
        ),
      ],
    );

    if (!showConnectorBelow) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SizedBox(height: nodeHeight, width: width, child: stackNode),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: nodeHeight, width: width, child: stackNode),
          ContinuousPathSegment(
            fromX: fromX,
            toX: toX,
            fromSlope: fromSlope,
            toSlope: toSlope,
            width: width,
            height: segmentHeight,
            isCleared: isCompleted,
            animateToRed: animateConnectorRed,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _AnonymousSaveNudge extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AnonymousSaveNudge> createState() => _AnonymousSaveNudgeState();
}

class _AnonymousSaveNudgeState extends ConsumerState<_AnonymousSaveNudge> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).logAnonSaveNudgeShown(source: 'scenario_board');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(analyticsServiceProvider).logAnonSaveNudgeCta(source: 'scenario_board');
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

class _MasuCard extends StatefulWidget {
  final Scenario scenario;
  final int index;
  final bool isCompleted;
  final bool isInProgress;
  final VoidCallback onTap;

  const _MasuCard({
    required this.scenario,
    required this.index,
    required this.isCompleted,
    required this.isInProgress,
    required this.onTap,
  });

  @override
  State<_MasuCard> createState() => _MasuCardState();
}

class _MasuCardState extends State<_MasuCard>
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
  void didUpdateWidget(covariant _MasuCard oldWidget) {
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
          borderRadius: BorderRadius.circular(40),
          splashColor: EngrowthColors.primary.withOpacity(0.2),
          highlightColor: EngrowthColors.primary.withOpacity(0.08),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 丸ノード＋シーン画像（ストーリーと統一）
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
                                : EngrowthColors.silverBorder,
                        width: widget.isCompleted || widget.isInProgress ? 3 : 2,
                      ),
                      boxShadow: EngrowthShadows.softCard,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: widget.scenario.thumbnailUrl != null
                        ? OptimizedImage(
                            imageUrl: widget.scenario.thumbnailUrl!,
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
              const SizedBox(height: 6),
              SizedBox(
                width: 88,
                child: Text(
                  widget.scenario.title,
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
          ),
        ),
      ),
    );
  }
}
