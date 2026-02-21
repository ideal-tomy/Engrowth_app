import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/ring_progress_indicator.dart';
import '../widgets/streak_display.dart';
import '../widgets/audio_comparison_player.dart';
import '../models/achievement.dart';
import '../widgets/achievement_display.dart' show AchievementBadge;
import '../providers/progress_provider.dart';
import '../providers/sentence_provider.dart';
import '../providers/user_stats_provider.dart';
import '../providers/achievement_provider.dart';
import '../services/scenario_service.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 学習進捗ページ - 成長実感を中心に再構成
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
            // 上部：連続日数・リング進捗・今日の達成率・次のメダルまでを集約
            const StreakDisplay(),
            const _RingProgressSection(),
            const _ProgressSummarySection(),
            const AudioComparisonPlayer(),
            // バッジ・称号（解除済み/次に狙うを分けて表示）
            achievementsAsync.when(
              data: (achievements) {
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
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('エラー: $error'),
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
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.trending_up, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'まだ学習を開始していません',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '瞬間英作文で1問解いてみましょう',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                            leading: const Icon(Icons.check_circle, color: Colors.green),
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
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                            leading: const Icon(Icons.school, color: Colors.orange),
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
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.error, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('エラー: $error'),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
                const Text('今日の達成率', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${stats.dailyDoneCount}/${stats.dailyGoalCount}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: dailyProgress,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                dailyProgress >= 1.0 ? Colors.green : Colors.blue,
              ),
            ),
            if (remaining != null && nextMedalTitle != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.emoji_events, size: 20, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '次のメダル「$nextMedalTitle」まで あと$remaining',
                      style: const TextStyle(fontSize: 13),
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
