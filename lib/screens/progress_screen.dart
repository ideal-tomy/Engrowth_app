import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/ring_progress_indicator.dart';
import '../widgets/streak_display.dart';
import '../widgets/audio_comparison_player.dart';
import '../models/achievement.dart';
import '../models/next_action_suggestion.dart';
import '../widgets/achievement_display.dart' show AchievementBadge;
import '../providers/progress_provider.dart';
import '../providers/progress_analysis_provider.dart';
import '../providers/next_action_provider.dart';
import '../providers/sentence_provider.dart';
import '../providers/user_stats_provider.dart';
import '../providers/conversation_practice_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/analytics_provider.dart';
import '../services/scenario_service.dart';
import '../services/supabase_service.dart';
import '../theme/engrowth_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 学習進捗ページ - 要点ダッシュボード + 深掘り分析の2層構造
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);
    final masteredCountAsync = ref.watch(masteredCountProvider);
    final sentencesAsync = ref.watch(sentencesProvider);
    final achievementsAsync = ref.watch(achievementsProvider);
    final unlockedIdsAsync = ref.watch(unlockedAchievementIdsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          tooltip: '戻る',
        ),
        title: const Text('進捗確認'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/account'),
            tooltip: 'アカウント',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // === 第1層: 要点ダッシュボード ===
            const StreakDisplay(),
            const _RingProgressSection(),
            const _ProgressSummarySection(),
            const _NextActionsSection(),
            const _ConversationPracticeSection(),
            const AudioComparisonPlayer(),
            // === 第2層: 深掘り分析 ===
            const _DeepDiveSection(),
            // バッジ・称号（解除済み/次に狙うを分けて表示）
            achievementsAsync.when(
              data: (achievements) {
                if (achievements.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Text(
                      'バッジ・称号はDB設定後に表示されます（achievements テーブル）',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  );
                }
                return unlockedIdsAsync.when(
                  data: (unlockedIds) {
                    final unlocked = achievements
                        .where((a) => unlockedIds.contains(a.id))
                        .toList();
                    final locked = achievements
                        .where((a) => !unlockedIds.contains(a.id))
                        .toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (unlocked.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                            child: Text(
                              '解除済み',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _AchievementGrid(achievements: unlocked, isUnlocked: true),
                        ],
                        if (locked.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                            child: Text(
                              '次に狙う',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _AchievementGrid(achievements: locked, isUnlocked: false),
                        ],
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Text(
                  'バッジ・称号は現在利用できません（DB未設定の場合は achievements テーブルを用意してください）',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            ),
            // 全体進捗
            masteredCountAsync.when(
              data: (mastered) {
                return sentencesAsync.when(
                  data: (sentences) {
                    return CustomProgressIndicator(
                      mastered: mastered,
                      total: sentences.length,
                      label: '覚えた例文',
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            // 詳細リスト（空状態改善）
            progressAsync.when(
              data: (progressList) {
                if (progressList.isEmpty) {
                  final colorScheme = Theme.of(context).colorScheme;
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.trending_up, size: 64, color: colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text(
                          'まだ学習を開始していません',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '瞬間英作文で1問解いてみましょう',
                          style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => context.push('/study'),
                          icon: const Icon(Icons.school, size: 20),
                          label: const Text('学習を始める'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final masteredList = progressList.where((p) => p.isMastered).toList();
                final studyingList = progressList.where((p) => !p.isMastered).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (masteredList.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, 4),
                        child: Text(
                          '覚えた例文',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...masteredList.take(5).map((progress) => ListTile(
                            leading: Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                            title: Text('例文ID: ${progress.sentenceId.substring(0, 8)}...'),
                            subtitle: progress.lastStudiedAt != null
                                ? Text('学習日: ${progress.lastStudiedAt!.toString().split(' ')[0]}')
                                : null,
                          )),
                      if (masteredList.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 8),
                          child: Text(
                            '他 ${masteredList.length - 5} 件',
                            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ),
                    ],
                    if (studyingList.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Text(
                          '学習中',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...studyingList.take(5).map((progress) => ListTile(
                            leading: Icon(Icons.school, color: Theme.of(context).colorScheme.tertiary),
                            title: Text('例文ID: ${progress.sentenceId.substring(0, 8)}...'),
                            subtitle: progress.lastStudiedAt != null
                                ? Text('学習日: ${progress.lastStudiedAt!.toString().split(' ')[0]}')
                                : null,
                          )),
                      if (studyingList.length > 5)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 24),
                          child: Text(
                            '他 ${studyingList.length - 5} 件',
                            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ),
                    ],
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Text(
                  '進捗リストを取得できませんでした（DB未設定の場合はSupabaseに user_progress テーブルを用意してください）',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 次アクション提案セクション（復習・お気に入り・録音・日次目標）
class _NextActionsSection extends ConsumerWidget {
  const _NextActionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(nextActionSuggestionsProvider);

    return suggestionsAsync.when(
      data: (suggestions) {
        if (suggestions.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '次にやること',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              ...suggestions.map((s) => _NextActionCard(suggestion: s)),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _NextActionCard extends StatelessWidget {
  final NextActionSuggestion suggestion;

  const _NextActionCard({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(suggestion.route),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: suggestion.accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: suggestion.accentColor.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Icon(suggestion.icon, color: suggestion.accentColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        suggestion.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: suggestion.accentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 深掘り分析セクション（すごろく・学習分析・バッジ・詳細リスト）
class _DeepDiveSection extends ConsumerWidget {
  const _DeepDiveSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            '深掘り分析',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const _SugorokuBoardEntry(),
        const _ProgressAnalysisSection(),
      ],
    );
  }
}

/// 学習セッション分析（習得率・ヒント依存度）
class _ProgressAnalysisSection extends ConsumerWidget {
  const _ProgressAnalysisSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(progressAnalysisProvider);

    return analysisAsync.when(
      data: (analysis) {
        if (analysis.totalCount == 0) return const SizedBox.shrink();
        final colorScheme = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '学習セッション分析',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _AnalysisMetric(
                          label: '習得率',
                          value: '${(analysis.masteredRate * 100).toInt()}%',
                          subtitle: '${analysis.masteredCount}/${analysis.totalCount}例文',
                        ),
                      ),
                      Expanded(
                        child: _AnalysisMetric(
                          label: 'ヒント依存',
                          value: '${(analysis.hintDependentRate * 100).toInt()}%',
                          subtitle: '習得済みのうち${analysis.hintDependentCount}件',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _AnalysisMetric extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;

  const _AnalysisMetric({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// すごろく進捗ボードへの入口カード
class _SugorokuBoardEntry extends ConsumerWidget {
  const _SugorokuBoardEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '進捗を見る',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _BoardEntryCard(
                  icon: Icons.timer,
                  label: 'シナリオ学習',
                  onTap: () {
                    ref.read(analyticsServiceProvider).logProgressBoardOpened(track: 'scenario');
                    context.push('/progress/scenario-board');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BoardEntryCard(
                  icon: Icons.auto_stories,
                  label: '3分英会話',
                  onTap: () {
                    ref.read(analyticsServiceProvider).logProgressBoardOpened(track: 'story');
                    context.push('/progress/story-board');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BoardEntryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BoardEntryCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: Theme.of(context).brightness == Brightness.dark
                ? null
                : EngrowthShadows.softCard,
          ),
          child: Column(
            children: [
              Icon(icon, size: 28, color: colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// リング型の今日の達成率（Nike Run Club風）
class _RingProgressSection extends ConsumerWidget {
  const _RingProgressSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);

    return statsAsync.when(
      data: (stats) {
        final progress = stats.missionProgress;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RingProgressIndicator(
                progress: progress,
                label: '${stats.dailyDoneCount}/${stats.dailyGoalCount}',
                sublabel: '今日の達成',
                size: 100,
                strokeWidth: 10,
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// 会話練習サマリ（今日のターン数・目標）
class _ConversationPracticeSection extends ConsumerWidget {
  const _ConversationPracticeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turnsAsync = ref.watch(todayConversationTurnsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(analyticsServiceProvider).logProgressBoardOpened(track: 'conversation');
            context.push('/conversations');
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.smart_toy, size: 32, color: colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI会話練習',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      turnsAsync.when(
                        data: (turns) => Text(
                          '今日 $turns ターン完了　目標: $dailyConversationGoalTurns ターン',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                        loading: () => Text(
                          'AIと会話して英語を練習しよう',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                        error: (_, __) => Text(
                          'AIと会話して英語を練習しよう',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 上部サマリ：今日の達成率・次のメダルまで
class _ProgressSummarySection extends ConsumerWidget {
  const _ProgressSummarySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);

    return statsAsync.when(
      data: (stats) => _NextMedalInfo(stats: stats),
      loading: () => const Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// 今日の達成率と次のメダル（非同期取得）
class _NextMedalInfo extends ConsumerStatefulWidget {
  final dynamic stats;

  const _NextMedalInfo({required this.stats});

  @override
  ConsumerState<_NextMedalInfo> createState() => _NextMedalInfoState();
}

class _NextMedalInfoState extends ConsumerState<_NextMedalInfo> {
  int? _remaining;
  String? _nextMedalTitle;

  @override
  void initState() {
    super.initState();
    _loadNextMedal();
  }

  Future<void> _loadNextMedal() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final achievements = await ref.read(achievementsProvider.future);
    final unlockedIds = await ref.read(unlockedAchievementIdsProvider.future);
    final progressList = await SupabaseService.getUserProgress(userId);
    final masteredCount = progressList.where((p) => p.isMastered).length;
    final hintFreeCount = progressList
        .where((p) => p.isMastered && !p.usedHintToMaster)
        .length;
    final scenarioService = ScenarioService();
    final scenarios = await scenarioService.getScenarios();
    int scenarioCount = 0;
    for (final s in scenarios) {
      final p = await scenarioService.getUserProgress(userId, s.id);
      if (p?.isCompleted == true) scenarioCount++;
    }
    final locked = achievements.where((a) => !unlockedIds.contains(a.id)).toList();
    for (final a in locked) {
      int current = 0;
      switch (a.conditionType) {
        case 'streak':
          current = widget.stats.streakCount;
          break;
        case 'sentence_count':
          current = masteredCount;
          break;
        case 'scenario_count':
          current = scenarioCount;
          break;
        case 'hint_free_count':
          current = hintFreeCount;
          break;
      }
      if (current < a.conditionValue) {
        if (mounted) {
          setState(() {
            _remaining = a.conditionValue - current;
            _nextMedalTitle = a.title;
          });
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent(
      context,
      widget.stats,
      remaining: _remaining,
      nextMedalTitle: _nextMedalTitle,
    );
  }

  Widget _buildContent(
    BuildContext context,
    dynamic stats, {
    int? remaining,
    String? nextMedalTitle,
  }) {
    final dailyProgress = stats.dailyGoalCount > 0
        ? (stats.dailyDoneCount / stats.dailyGoalCount).clamp(0.0, 1.0)
        : 0.0;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 今日の達成率
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('今日の達成率', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                Text(
                  '${stats.dailyDoneCount}/${stats.dailyGoalCount}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: dailyProgress,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                dailyProgress >= 1.0
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
            if (remaining != null && nextMedalTitle != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.emoji_events, size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '次のメダル「$nextMedalTitle」まで あと$remaining',
                      style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 実績グリッド（解除済み/次に狙う用）
class _AchievementGrid extends StatelessWidget {
  final List<Achievement> achievements;
  final bool isUnlocked;

  const _AchievementGrid({
    required this.achievements,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return AchievementBadge(
          achievement: achievement,
          isUnlocked: isUnlocked,
        );
      },
    );
  }
}
