import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/pattern_sprint_category.dart';
import '../providers/pattern_sprint_provider.dart';
import '../providers/analytics_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/first_listen_completed_provider.dart';
import '../services/listen_first_popup_prefs_service.dart';
import '../widgets/guided_flow/listen_first_popup.dart';
import '../services/pattern_sprint_service.dart';
import '../widgets/favorite_toggle_icon.dart';
import '../widgets/tutorial/simulated_finger_overlay.dart';
import '../models/learning_handoff_result.dart';
import '../widgets/tutorial/learning_intro_dialog.dart';
import '../widgets/common/engrowth_popup.dart';
import '../widgets/pattern_sprint_selection_dialog.dart';
import 'pattern_sprint_session_dialog.dart';

/// パターンスプリント: パターン選択・秒数選択・セッション開始
class PatternSprintListScreen extends ConsumerStatefulWidget {
  const PatternSprintListScreen({super.key, this.fromOnboarding = false});

  final bool fromOnboarding;

  @override
  ConsumerState<PatternSprintListScreen> createState() =>
      _PatternSprintListScreenState();
}

class _PatternSprintListScreenState extends ConsumerState<PatternSprintListScreen> {
  int _selectedDurationSec = 45;
  String? _selectedPrefix;
  final GlobalKey _overlayTargetKey = GlobalKey();

  // Speak風ガイドフロー: ポップアップ閉じ済みのプレフィックス
  final Set<String> _guidedFlowPlayRevealedForPrefix = {};

  /// もう1セットからの再開時は ListenFirstPopup を出さない
  bool _skipListenFirstForRestart = false;

  /// 選択ポップアップからセッション開始時は ListenFirstPopup を出さない（選択＝即開始のため）
  bool _skipListenFirstForSelectionPopup = false;

  /// オンボーディング時、直接ダイアログ表示済みか（二重表示防止）
  bool _onboardingIntroShown = false;

  /// セッションを開き、オンボーディングからなら戻り値で一覧を閉じてオンボーディングに返す
  Future<void> _pushSessionAndReturnIfOnboarding(String prefix) async {
    if (widget.fromOnboarding) {
      final fromParam = '&from_onboarding=true';
      final uri =
          '/pattern-sprint/session?prefix=${Uri.encodeComponent(prefix)}&duration=$_selectedDurationSec$fromParam';
      final result = await context.push<LearningHandoffResult>(uri);
      if (!mounted) return;
      // セッション終了後、一覧を閉じてオンボーディングへ戻り次のセクションへ自動進行
      final value = result ?? LearningHandoffResult.notCompleted;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop(value);
      });
      return;
    }

    await _startSession(prefix);
  }

  /// カテゴリ内の次のパターン prefix を返す（同じカテゴリで次へ、末尾なら先頭に戻る）
  String _getNextPrefixInCategory(String currentPrefix) {
    final byCategory = ref.read(patternByCategoryProvider);
    for (final list in byCategory.values) {
      final idx = list.indexWhere((p) => p.prefix == currentPrefix);
      if (idx >= 0) {
        final nextIdx = (idx + 1) % list.length;
        return list[nextIdx].prefix;
      }
    }
    return currentPrefix;
  }

  /// 通常利用時: showDialog でセッション実行 → 完了時のみミッション達成ポップアップ → もう1セットで再帰
  Future<void> _startSession(String prefix) async {
    final result = await showDialog<PatternSprintResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PatternSprintSessionDialog(
        prefix: prefix,
        durationSec: _selectedDurationSec,
      ),
    );

    if (!mounted || result == null || !result.completed) return;

    bool wantsRestart = false;
    await EngrowthPopup.show<void>(
      context,
      variant: EngrowthPopupVariant.missionClear,
      title: 'パターンスプリントおつかれさまです',
      subtitle: '約${result.elapsedSec}秒で ${result.playedCount} フレーズ練習しました。',
      primaryLabel: 'もう1セット',
      onPrimary: () {
        wantsRestart = true;
      },
      secondaryLabel: '一覧へ',
      onSecondary: () {},
    );

    if (mounted && wantsRestart) {
      final nextPrefix = _getNextPrefixInCategory(prefix);
      setState(() {
        _selectedPrefix = nextPrefix;
        _skipListenFirstForRestart = true;
      });
      _startSession(nextPrefix);
    }
  }

  /// オンボーディング時のみ: ダイアログをスキップして直接セッションへ遷移
  Future<void> _pushSessionDirectlyFromOnboarding() async {
    if (_selectedPrefix == null || !widget.fromOnboarding) return;
    if (_onboardingIntroShown) return;
    _onboardingIntroShown = true;
    final prefix = _selectedPrefix!;
    ref.read(analyticsServiceProvider).logTutorialStepAutoadvanced(
          stepType: 'pattern_sprint',
        );
    ref.read(analyticsServiceProvider).logTutorialOneTapStartSuccess(
          learningMode: 'pattern_sprint',
          targetId: prefix,
        );
    await _pushSessionAndReturnIfOnboarding(prefix);
  }

  void _onOverlayComplete() {
    if (_selectedPrefix == null) return;
    if (widget.fromOnboarding && _onboardingIntroShown) return;
    if (widget.fromOnboarding) _onboardingIntroShown = true;
    final prefix = _selectedPrefix!;
    ref.read(analyticsServiceProvider).logTutorialStepAutoadvanced(
          stepType: 'pattern_sprint',
        );
    ref.read(analyticsServiceProvider).logTutorialOneTapStartSuccess(
          learningMode: 'pattern_sprint',
          targetId: prefix,
        );
    LearningIntroDialog.show(
      context,
      title: 'パターンスプリント',
      body: '聞く→まねして言うを短時間で繰り返します。音声を聴いたら即座にリピートしましょう。',
      onStart: () => _pushSessionAndReturnIfOnboarding(prefix),
      autoDismissDuration: widget.fromOnboarding
          ? const Duration(seconds: 3)
          : const Duration(seconds: 5),
    );
  }

  @override
  void initState() {
    super.initState();
    final patterns = PatternSprintService.predefinedPatterns;
    if (patterns.isNotEmpty) {
      _selectedPrefix = patterns.first.prefix;
    }
    if (!widget.fromOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowSelectionPopup());
    } else {
      // オンボーディング時: 一覧を短く表示後、直接セッションへ遷移（音声自動再生）
      // （LearningIntroDialog を挟むと一覧で止まる不具合対策）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!mounted || !widget.fromOnboarding || _selectedPrefix == null) return;
          _pushSessionDirectlyFromOnboarding();
        });
      });
    }
  }

  /// パターンスプリントページ初回訪問時: ラージポップアップで選択→即セッション開始
  Future<void> _maybeShowSelectionPopup() async {
    if (!mounted) return;
    final prefix = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (_) => const PatternSprintSelectionDialog(),
    );
    if (!mounted || prefix == null) return;
    setState(() {
      _selectedPrefix = prefix;
      _skipListenFirstForSelectionPopup = true;
    });
    ref.read(analyticsServiceProvider).logPatternSprintCategoryStarted(
          categoryId: '',
          prefix: prefix,
        );
    await _startSession(prefix);
  }

  static const _durations = <int>[30, 45, 60];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final categories = ref.watch(patternCategoriesProvider);
    final byCategory = ref.watch(patternByCategoryProvider);
    final selectedPrefix = _selectedPrefix ?? '';
    final firstListenAsync = selectedPrefix.isEmpty
        ? const AsyncValue.data(true)
        : ref.watch(firstListenCompletedProvider(('pattern', selectedPrefix)));

    // Speak風ガイドフロー: 初回カテゴリアクセス時にポップアップ（もう1セット時は出さない）
    ref.listen(
      selectedPrefix.isNotEmpty
          ? firstListenCompletedProvider(('pattern', selectedPrefix))
          : firstListenCompletedProvider(('pattern', '__skip__')),
      (_, next) {
        if (selectedPrefix.isEmpty) return;
        if (_skipListenFirstForRestart || _skipListenFirstForSelectionPopup) {
          if (mounted) {
            setState(() {
              _skipListenFirstForRestart = false;
              _skipListenFirstForSelectionPopup = false;
            });
          }
          return;
        }
        next.whenData((isCompleted) async {
          if (isCompleted) return;
          if (_guidedFlowPlayRevealedForPrefix.contains(selectedPrefix) || !mounted) return;
          final prefs = ListenFirstPopupPrefsService();
          if (await prefs.isDismissedPermanently()) return;
          final isAnonymous = ref.read(isAnonymousProvider);
          if (isAnonymous && await prefs.wasShownToday()) return;
          if (!mounted) return;
          await ListenFirstPopup.show(
            context,
            message: 'まずは音声を聴いてから、まねして言いましょう',
            showDismissPermanentlyCheckbox: !isAnonymous,
            contentType: 'pattern',
            contentId: selectedPrefix,
            onShown: () => ref.read(analyticsServiceProvider).logGuidedFlowPopupShown(
              contentType: 'pattern',
              step: 'listen_first',
              contentId: selectedPrefix,
            ),
            onDismiss: (dismissPermanently) {
              if (mounted) {
                if (dismissPermanently) {
                  prefs.setDismissedPermanently(true);
                }
                if (isAnonymous) {
                  prefs.markShownToday();
                }
                setState(() => _guidedFlowPlayRevealedForPrefix.add(selectedPrefix));
                ref.read(analyticsServiceProvider).logGuidedFlowPopupDismissed(
                  contentType: 'pattern',
                  step: 'listen_first',
                );
                ref.read(analyticsServiceProvider).logGuidedFlowPlayRevealed(
                  contentType: 'pattern',
                  contentId: selectedPrefix,
                );
              }
            },
          );
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('パターンスプリント'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/account'),
            tooltip: 'アカウント',
          ),
        ],
      ),
      body: _buildBody(categories, byCategory, colorScheme, textTheme, firstListenAsync),
    );
  }

  List<Widget> _buildCategorySections(
    List<PatternSprintCategory> categories,
    Map<String, List<PatternDefinition>> byCategory,
    ColorScheme colorScheme,
    AsyncValue<bool> firstListenAsync,
  ) {
    // 一覧画面は常に全カテゴリ・全パターンを表示する
    return categories.map((category) {
      final patterns = byCategory[category.id] ?? [];
      if (patterns.isEmpty) return const SizedBox.shrink();

      final firstPrefix = patterns.first.prefix;
      final isFirstCategory = categories.indexOf(category) == 0;
      final useOverlayKey = widget.fromOnboarding && isFirstCategory;
      final isSelectedCategory = patterns.any((p) => p.prefix == _selectedPrefix);

      return Padding(
        key: useOverlayKey ? _overlayTargetKey : null,
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  category.icon,
                  size: 22,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    category.usageHint,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () async {
                  HapticFeedback.selectionClick();
                  ref.read(analyticsServiceProvider).logPatternSprintCategoryStarted(
                        categoryId: category.id,
                        prefix: firstPrefix,
                      );
                  await _pushSessionAndReturnIfOnboarding(firstPrefix);
                },
                child: Text('${patterns.first.displayName}でスタート'),
              ),
            ),
            const SizedBox(height: 8),
            ...patterns.map((p) {
                final isSelected = _selectedPrefix == p.prefix;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    dense: true,
                    visualDensity: const VisualDensity(vertical: -2),
                    leading: Icon(
                      Icons.play_circle_outline,
                      color: isSelected ? colorScheme.primary : colorScheme.outline,
                      size: 24,
                    ),
                    title: Text(
                      p.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      p.japaneseHint,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    selected: isSelected,
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      ref.read(analyticsServiceProvider).logPatternSprintCategorySelected(
                            categoryId: category.id,
                            prefix: p.prefix,
                          );
                      setState(() => _selectedPrefix = p.prefix);
                      ref.read(analyticsServiceProvider).logPatternSprintCategoryStarted(
                            categoryId: category.id,
                            prefix: p.prefix,
                          );
                      await _pushSessionAndReturnIfOnboarding(p.prefix);
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ハートのみタップで再生しない（お気に入り登録専用）
                        FavoriteToggleIcon(
                          targetType: 'pattern',
                          targetId: p.prefix,
                          size: 22,
                        ),
                        const SizedBox(width: 4),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.play_arrow_rounded),
                          tooltip: 'このパターンですぐ始める',
                          onPressed: () async {
                            HapticFeedback.selectionClick();
                            ref.read(analyticsServiceProvider).logHapticFired(
                                  trigger: 'pattern_sprint_start_from_list_item',
                                );
                            ref.read(analyticsServiceProvider).logPatternSprintCategoryStarted(
                                  categoryId: category.id,
                                  prefix: p.prefix,
                                );
                            await _pushSessionAndReturnIfOnboarding(p.prefix);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildBody(
    List<PatternSprintCategory> categories,
    Map<String, List<PatternDefinition>> byCategory,
    ColorScheme colorScheme,
    TextTheme textTheme,
    AsyncValue<bool> firstListenAsync,
  ) {
    final scrollChild = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/training.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildHeroFallback(),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: colorScheme.onPrimaryContainer.withOpacity(0.9),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '鬼教官と一緒に\nパターンスプリント',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '聞く→まねして言う を\n短時間でぐるぐる回していきます。',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '口慣らしトレーニング。聞く→リピートを短時間で繰り返します。',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'セッションの長さ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _durations.map((sec) {
              final isSelected = _selectedDurationSec == sec;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text('約${sec}秒'),
                    selected: isSelected,
                    onSelected: (v) {
                      if (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedDurationSec = sec);
                      }
                    },
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'カテゴリ別パターン（集中トレーニング）',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '同じカテゴリのパターンを繰り返すと、音にも発音にも慣れやすくなります。',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildCategorySections(
            categories,
            byCategory,
            colorScheme,
            firstListenAsync,
          ),
          const SizedBox(height: 32),
          if (widget.fromOnboarding && _selectedPrefix != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '最初のパターンでスタート',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _selectedPrefix != null
                          ? () => _pushSessionAndReturnIfOnboarding(_selectedPrefix!)
                          : null,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('今すぐスタート'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          FilledButton(
            onPressed: _selectedPrefix == null
                ? null
                : () async {
                    HapticFeedback.selectionClick();
                    ref.read(analyticsServiceProvider).logHapticFired(
                          trigger: 'pattern_sprint_start',
                        );
                    await _pushSessionAndReturnIfOnboarding(_selectedPrefix!);
                  },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('スタート'),
            ),
          ),
        ],
      ),
    );

    // オンボーディング時は initState で直接ダイアログ表示するためオーバーレイは使わない
    if (widget.fromOnboarding && _selectedPrefix != null) {
      return scrollChild;
    }
    return scrollChild;
  }

  /// 画像読み込み失敗時や画像未配置時のヒーロー表示
  Widget _buildHeroFallback() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            Icons.fitness_center,
            size: 64,
            color: colorScheme.onPrimaryContainer.withOpacity(0.9),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '鬼教官と一緒に\nパターンスプリント',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '聞く→まねして言う を\n短時間でぐるぐる回していきます。',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

}
