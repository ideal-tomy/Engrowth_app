import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/scenario.dart';
import '../providers/analytics_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/scenario_provider.dart';
import '../theme/engrowth_theme.dart';

/// シナリオ学習のすごろく進捗ボード
/// 各シナリオをマスとして表示し、タップで学習へ遷移
class ScenarioProgressBoardScreen extends ConsumerWidget {
  const ScenarioProgressBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsync = ref.watch(scenariosProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: EngrowthColors.backgroundSoft,
      appBar: AppBar(
        title: const Text('シナリオ進捗'),
        backgroundColor: EngrowthColors.surface,
        foregroundColor: EngrowthColors.onBackground,
      ),
      body: scenariosAsync.when(
        data: (scenarios) {
          if (scenarios.isEmpty) {
            return _ScenarioBoardBody(
              scenarios: _sampleScenariosForEmptyState(),
              userId: userId,
              isSamplePlaceholder: true,
            );
          }
          return _ScenarioBoardBody(scenarios: scenarios, userId: userId);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ScenarioBoardBody(
          scenarios: _sampleScenariosForEmptyState(),
          userId: userId,
          isSamplePlaceholder: true,
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

/// マスとマスの間の点線（すごろくの道のり）
class _ScenarioMasuWithConnector extends StatelessWidget {
  final bool showConnectorBelow;
  final Widget child;

  const _ScenarioMasuWithConnector({
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
              painter: _ScenarioDottedLinePainter(
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

class _ScenarioBoardBody extends ConsumerWidget {
  final List<Scenario> scenarios;
  final String? userId;
  final bool isSamplePlaceholder;

  const _ScenarioBoardBody({
    required this.scenarios,
    this.userId,
    this.isSamplePlaceholder = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAnonymous = ref.watch(isAnonymousProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isSamplePlaceholder) ...[
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
        _ScenarioSectionBanner(isSamplePlaceholder: isSamplePlaceholder),
        const SizedBox(height: 16),
        ...scenarios.asMap().entries.map((entry) {
          final index = entry.key;
          final scenario = entry.value;
          final showConnectorBelow = index < scenarios.length - 1;
          return _ScenarioMasuWithConnector(
            showConnectorBelow: showConnectorBelow,
            child: _ScenarioMasu(
              index: index + 1,
              scenario: scenario,
              userId: userId,
              isSamplePlaceholder: isSamplePlaceholder || scenario.id.startsWith('_sample_'),
            ),
          );
        }),
        if (isAnonymous) ...[
          const SizedBox(height: 16),
          _AnonymousSaveNudge(),
        ],
      ],
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

class _ScenarioMasu extends ConsumerWidget {
  final int index;
  final Scenario scenario;
  final String? userId;
  final bool isSamplePlaceholder;

  const _ScenarioMasu({
    required this.index,
    required this.scenario,
    this.userId,
    this.isSamplePlaceholder = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isSamplePlaceholder) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _MasuCard(
          scenario: scenario,
          index: index,
          isCompleted: false,
          isInProgress: index == 1,
          progressText: '約${scenario.estimatedMinutes}分',
          onTap: () {
            HapticFeedback.selectionClick();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('サンプル表示です。Supabase に scenarios を登録すると学習を開始できます'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      );
    }

    final progressAsync = ref.watch(userScenarioProgressProvider(scenario.id));
    final stepsAsync = ref.watch(scenarioStepsProvider(scenario.id));

    return progressAsync.when(
      data: (progress) {
        return stepsAsync.when(
          data: (steps) {
            final totalSteps = steps.length;
            final isCompleted = progress?.isCompleted ?? false;
            final currentStep = progress?.lastStepIndex ?? 0;
            final isInProgress = !isCompleted && currentStep > 0;
            final isCurrent = !isCompleted && (currentStep == 0 || index == 1);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MasuCard(
                scenario: scenario,
                index: index,
                isCompleted: isCompleted,
                isInProgress: isInProgress,
                progressText: totalSteps > 0
                    ? '${currentStep}/${totalSteps}'
                    : '約${scenario.estimatedMinutes}分',
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(analyticsServiceProvider).logProgressNodeTapped(
                        nodeId: scenario.id,
                        track: 'scenario',
                      );
                  context.push('/scenario/${scenario.id}');
                },
              ),
            );
          },
          loading: () => _MasuCard(
            scenario: scenario,
            index: index,
            isCompleted: false,
            isInProgress: false,
            progressText: '約${scenario.estimatedMinutes}分',
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(analyticsServiceProvider).logProgressNodeTapped(
                    nodeId: scenario.id,
                    track: 'scenario',
                  );
              context.push('/scenario/${scenario.id}');
            },
          ),
          error: (_, __) => _MasuCard(
            scenario: scenario,
            index: index,
            isCompleted: false,
            isInProgress: false,
            progressText: '約${scenario.estimatedMinutes}分',
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(analyticsServiceProvider).logProgressNodeTapped(
                    nodeId: scenario.id,
                    track: 'scenario',
                  );
              context.push('/scenario/${scenario.id}');
            },
          ),
        );
      },
      loading: () => _MasuCard(
        scenario: scenario,
        index: index,
        isCompleted: false,
        isInProgress: false,
        progressText: '約${scenario.estimatedMinutes}分',
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/scenario/${scenario.id}');
        },
      ),
      error: (_, __) => _MasuCard(
        scenario: scenario,
        index: index,
        isCompleted: false,
        isInProgress: false,
        progressText: '約${scenario.estimatedMinutes}分',
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/scenario/${scenario.id}');
        },
      ),
    );
  }
}

class _MasuCard extends StatefulWidget {
  final Scenario scenario;
  final int index;
  final bool isCompleted;
  final bool isInProgress;
  final String progressText;
  final VoidCallback onTap;

  const _MasuCard({
    required this.scenario,
    required this.index,
    required this.isCompleted,
    required this.isInProgress,
    required this.progressText,
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
          borderRadius: BorderRadius.circular(12),
          splashColor: EngrowthColors.primary.withOpacity(0.2),
          highlightColor: EngrowthColors.primary.withOpacity(0.08),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: EngrowthColors.surface,
              borderRadius: BorderRadius.circular(12),
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
                // Duolingo風：マス番号を台座のように表示
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.isCompleted
                        ? EngrowthColors.success.withOpacity(0.2)
                        : widget.isInProgress
                            ? EngrowthColors.primary.withOpacity(0.15)
                            : EngrowthColors.background,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: EngrowthColors.silverShadow,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: widget.isCompleted
                        ? const Icon(Icons.check, color: EngrowthColors.success, size: 24)
                        : Text(
                            '${widget.index}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: widget.isInProgress
                                  ? EngrowthColors.primary
                                  : EngrowthColors.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.scenario.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: EngrowthColors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.progressText,
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
