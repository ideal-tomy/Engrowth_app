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
import '../widgets/debug_completion_fab.dart';
import '../widgets/optimized_image.dart';
import '../widgets/scenario_background.dart';
import '../widgets/scroll_target_wrapper.dart';

/// シナリオ学習の進捗ボード（Speak風：セクション＋ずらしカードリスト）
class ScenarioProgressBoardScreen extends ConsumerWidget {
  const ScenarioProgressBoardScreen({super.key, this.scrollToNext = false});

  final bool scrollToNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsync = ref.watch(scenariosProvider);
    final targetIdAsync = ref.watch(firstIncompleteScenarioIdProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('シナリオ進捗'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
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

/// Speak風：セクションヘッダー（第1部 シナリオ学習）
class _ScenarioSectionBanner extends StatelessWidget {
  final bool isSamplePlaceholder;

  const _ScenarioSectionBanner({this.isSamplePlaceholder = false});

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
          Icon(Icons.auto_stories, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text(
            '第1部',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isSamplePlaceholder ? 'シナリオ学習の道のり' : 'シナリオ学習',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Speak風：ずらしオフセット（index % 4）
double _offsetForScenarioIndex(int globalIndex, double width) {
  final cardWidth = width * 0.72;
  final margin = (width - cardWidth) / 2;
  switch (globalIndex % 4) {
    case 0:
      return margin;
    case 1:
      return (margin + 16).clamp(0.0, width - cardWidth);
    case 2:
      return (margin + 28).clamp(0.0, width - cardWidth);
    case 3:
      return (margin - 8).clamp(0.0, width - cardWidth);
    default:
      return margin;
  }
}

/// Speak風：横長レッスンカード（CircleAvatar + タイトル）
class _ScenarioLessonCard extends ConsumerWidget {
  final Scenario scenario;
  final int globalIndex;
  final bool isScrollTarget;
  final String? unlockSnackBarMessage;
  final String? userId;
  final bool isSamplePlaceholder;

  const _ScenarioLessonCard({
    required this.scenario,
    required this.globalIndex,
    required this.isScrollTarget,
    this.unlockSnackBarMessage,
    this.userId,
    required this.isSamplePlaceholder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isSamplePlaceholder) {
      return _buildCard(context, ref, isCompleted: false, isInProgress: globalIndex == 0);
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
            return _buildCard(
              context,
              ref,
              isCompleted: isCompleted,
              isInProgress: isInProgress,
            );
          },
          loading: () => _buildCard(context, ref, isCompleted: false, isInProgress: false),
          error: (_, __) => _buildCard(context, ref, isCompleted: false, isInProgress: false),
        );
      },
      loading: () => _buildCard(context, ref, isCompleted: false, isInProgress: false),
      error: (_, __) => _buildCard(context, ref, isCompleted: false, isInProgress: false),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref,
      {required bool isCompleted, required bool isInProgress}) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width - 32;
    final cardWidth = width * 0.72;
    final offset = _offsetForScenarioIndex(globalIndex, width);

    final cardBg = theme.brightness == Brightness.light
        ? EngrowthColors.cardSurfaceLight
        : theme.colorScheme.surface;
    final card = Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(24),
      elevation: theme.brightness == Brightness.light ? 2 : 0,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.08),
      child: InkWell(
        onTap: isSamplePlaceholder
            ? () {
                HapticFeedback.selectionClick();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'サンプル表示です。Supabase に scenarios を登録すると学習を開始できます'),
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
                    child: scenario.thumbnailUrl != null
                        ? ClipOval(
                            child: OptimizedImage(
                              imageUrl: scenario.thumbnailUrl!,
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
                  else if (isInProgress)
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
                  scenario.title,
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
        unlockSnackBarMessage: unlockSnackBarMessage,
        child: card,
      ),
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

/// 継続のナッジ：「あと1つでこの章がクリアです！」
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

class _ScenarioBoardBody extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isAnonymous = ref.watch(isAnonymousProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isSamplePlaceholder)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'シナリオが登録されていません。Supabase の scenarios テーブルにデータを登録すると、ここに表示されます。',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        _ScenarioSectionBanner(isSamplePlaceholder: isSamplePlaceholder),
        const SizedBox(height: 16),
        _ScenarioSectionNudge(scenarios: scenarios),
        ...scenarios.asMap().entries.map((entry) {
          final index = entry.key;
          final scenario = entry.value;
          final isScrollTarget = scrollToNext && targetId == scenario.id;
          final nextScenario = index < scenarios.length - 1 ? scenarios[index + 1] : null;
          final animateConnectorRed = scrollToNext && targetId == nextScenario?.id;
          return _ScenarioLessonCard(
            scenario: scenario,
            globalIndex: index,
            isScrollTarget: isScrollTarget,
            unlockSnackBarMessage: isScrollTarget ? '次のシナリオが解放されました' : null,
            userId: userId,
            isSamplePlaceholder: isSamplePlaceholder || scenario.id.startsWith('_sample_'),
          );
        }),
        if (isAnonymous) ...[
          const SizedBox(height: 16),
          const _AnonymousSaveNudgeScenario(),
        ],
      ],
    );
  }
}

class _AnonymousSaveNudgeScenario extends ConsumerWidget {
  const _AnonymousSaveNudgeScenario();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
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
