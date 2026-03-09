import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/conversation.dart';
import '../models/learning_handoff_result.dart';
import '../models/story_sequence.dart';
import '../providers/story_provider.dart';
import '../services/tts_playback_blocked_exception.dart';
import '../services/tts_service.dart';
import '../theme/engrowth_theme.dart';
import '../widgets/favorite_toggle_icon.dart';
import '../widgets/optimized_image.dart';
import '../widgets/scenario_background.dart';
import '../widgets/common/fade_slide_switcher.dart';
import '../widgets/common/content_skeleton.dart';
import '../providers/analytics_provider.dart';
import '../providers/transition_metrics_provider.dart';
import '../providers/first_listen_completed_provider.dart';
import '../widgets/guided_flow/listen_first_popup.dart';
import '../widgets/marquee/marquee_rail_data.dart';

/// 3分ストーリー学習画面
/// メイン: 3分一気に聴く / A役・B役で3分通し練習
/// サブ: チャンクごとに聴く・練習する
class StoryStudyScreen extends ConsumerStatefulWidget {
  final String storyId;
  final bool asSheet;
  final VoidCallback? onClose;
  final bool autoStartPlayback;
  final bool fromOnboarding;

  const StoryStudyScreen({
    super.key,
    required this.storyId,
    this.asSheet = false,
    this.onClose,
    this.autoStartPlayback = false,
    this.fromOnboarding = false,
  });

  @override
  ConsumerState<StoryStudyScreen> createState() => _StoryStudyScreenState();
}

class _StoryStudyScreenState extends ConsumerState<StoryStudyScreen> {
  final TtsService _ttsService = TtsService();
  bool _isPlaying = false;
  int _currentUtteranceIndex = 0;
  bool _stopPlaybackRequested = false;
  bool _autoStarted = false;
  bool _hasLoggedTapToFirstContent = false;
  bool _hasLoggedPrimaryCtaVisible = false;

  // Speak風ガイドフロー用
  bool _guidedFlowPlayButtonRevealed = false;
  bool _hasShownListenFirstPopup = false;
  bool _hasListenedToAll = false;

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) => _logTransitionCompleteIfNeeded());
  }

  void _logTransitionCompleteIfNeeded() {
    if (!mounted) return;
    final ctx = ref.read(transitionMetricsProvider.notifier).peek();
    if (ctx != null && ctx.toRoute.contains('/story/')) {
      ref.read(analyticsServiceProvider).logTransitionComplete(
            transitionCompleteMs: ctx.elapsedMs(),
            routeType: ctx.routeType,
            fromRoute: ctx.fromRoute,
            toRoute: ctx.toRoute,
            variant: 'motion_sync',
          );
    }
  }

  void _logTapToFirstContentIfNeeded() {
    if (!mounted) return;
    final ctx = ref.read(transitionMetricsProvider.notifier).consume();
    if (ctx != null && ctx.toRoute.contains('/story/')) {
      ref.read(analyticsServiceProvider).logTapToFirstContent(
            screenName: 'story_study',
            tapToFirstContentMs: ctx.elapsedMs(),
            entrySource: widget.fromOnboarding ? 'onboarding' : null,
            variant: 'motion_sync',
          );
    }
  }

  @override
  void dispose() {
    _ttsService.stop();
    _ttsService.dispose();
    super.dispose();
  }

  Future<void> _playAllUtterances(List<ConversationUtterance> utterances) async {
    if (_isPlaying) return;
    _stopPlaybackRequested = false;
    setState(() => _isPlaying = true);

    for (var i = 0; i < utterances.length; i++) {
      if (!mounted) break;
      if (_stopPlaybackRequested) break;

      final utterance = utterances[i];
      setState(() => _currentUtteranceIndex = i);
      try {
        await _ttsService.speakEnglish(utterance.englishText);
      } on TtsPlaybackBlockedException {
        break;
      } on Exception catch (e) {
        // 会話画面と同様: TTSキャッシュミスはスキップして続行し、それ以外は再スロー
        final msg = e.toString();
        if (msg.contains('TTS cache miss') || msg.contains('音声がDBにありません')) {
          if (kDebugMode) {
            final preview = utterance.englishText.length > 50
                ? '${utterance.englishText.substring(0, 50)}...'
                : utterance.englishText;
            debugPrint(
              'TTS skip (story): 発話 ${i + 1}/${utterances.length} はDBにありません（スキップして続行） text="$preview"',
            );
          }
          continue;
        }
        rethrow;
      }

      if (!mounted) break;
      if (_stopPlaybackRequested) break;

      if (i < utterances.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    if (mounted) {
      final wasStoppedByUser = _stopPlaybackRequested;
      setState(() {
        _isPlaying = false;
        _stopPlaybackRequested = false;
        if (!wasStoppedByUser) _hasListenedToAll = true;
      });
      if (widget.fromOnboarding && !widget.asSheet) {
        // オンボーディング導線: 聴き終わりで即戻る
        final service = ref.read(firstListenCompletedServiceProvider);
        final wasFirstTime = !await service.isCompleted('story', widget.storyId);
        if (wasFirstTime) {
          await service.markCompleted('story', widget.storyId);
          ref.invalidate(firstListenCompletedProvider(('story', widget.storyId)));
          ref.read(analyticsServiceProvider).logGuidedFlowFirstListenCompleted(
            contentType: 'story',
            contentId: widget.storyId,
          );
        }
        if (!mounted) return;
        context.pop(LearningHandoffResult.completedWithMode('focus3'));
        return;
      }
      if (!wasStoppedByUser) {
        final service = ref.read(firstListenCompletedServiceProvider);
        final wasFirstTime = !await service.isCompleted('story', widget.storyId);
        if (wasFirstTime) {
          await service.markCompleted('story', widget.storyId);
          ref.invalidate(firstListenCompletedProvider(('story', widget.storyId)));
          ref.read(analyticsServiceProvider).logGuidedFlowFirstListenCompleted(
            contentType: 'story',
            contentId: widget.storyId,
          );
          if (mounted) _showStoryNextActionDialog();
        }
      }
    }
  }

  Future<void> _stopPlayback() async {
    _stopPlaybackRequested = true;
    await _ttsService.stop();
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

  void _showStoryNextActionDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: FutureBuilder<List<Conversation>>(
          future: ref.read(storyConversationsProvider(widget.storyId).future),
          builder: (ctx, snapshot) {
            final conversations = snapshot.data ?? [];
            final firstId = conversations.isNotEmpty ? conversations.first.id : null;
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '次はどうする？',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  if (firstId != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          context.push('/conversation/$firstId?mode=roleA');
                        },
                        icon: const Icon(Icons.person, size: 18),
                        label: const Text('A役で3分通し練習'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: EngrowthColors.roleA,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          context.push('/conversation/$firstId?mode=roleB');
                        },
                        icon: const Icon(Icons.person_outline, size: 18),
                        label: const Text('B役で3分通し練習'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: EngrowthColors.roleB,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  ...conversations.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          context.push('/conversation/${e.value.id}?mode=listen');
                        },
                        icon: const Icon(Icons.queue_music, size: 18),
                        label: Text(conversations.length > 1 ? 'パート ${e.key + 1} で聴く' : 'チャンクで聴く'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('閉じる'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctx = ref.read(lastMarqueeTapContextProvider.notifier).consumeIfRecent();
    if (ctx != null) {
      ref.read(analyticsServiceProvider).logLearningEntryStarted(
            learningMode: 'story',
            entrySource: 'marquee',
            tapId: ctx.tapId,
          );
    }
    final storiesAsync = ref.watch(storySequencesProvider);
    final utterancesAsync = ref.watch(storyUtterancesOrderedProvider(widget.storyId));
    final conversationsAsync = ref.watch(storyConversationsProvider(widget.storyId));
    final firstListenAsync = ref.watch(firstListenCompletedProvider(('story', widget.storyId)));

    // Speak風ガイドフロー: 初回のみポップアップ表示
    ref.listen(firstListenCompletedProvider(('story', widget.storyId)), (_, next) {
      next.whenData((isCompleted) {
        if (isCompleted) return;
        if (_hasShownListenFirstPopup || !mounted) return;
        _hasShownListenFirstPopup = true;
        ListenFirstPopup.show(
          context,
          contentType: 'story',
          contentId: widget.storyId,
          onShown: () => ref.read(analyticsServiceProvider).logGuidedFlowPopupShown(
            contentType: 'story',
            step: 'listen_first',
            contentId: widget.storyId,
          ),
          onDismiss: () {
            if (mounted) {
              setState(() => _guidedFlowPlayButtonRevealed = true);
              ref.read(analyticsServiceProvider).logGuidedFlowPopupDismissed(
                contentType: 'story',
                step: 'listen_first',
              );
              ref.read(analyticsServiceProvider).logGuidedFlowPlayRevealed(
                contentType: 'story',
                contentId: widget.storyId,
              );
            }
          },
        );
      });
    });

    StorySequence? story;
    for (final s in storiesAsync.valueOrNull ?? <StorySequence>[]) {
      if (s.id == widget.storyId) {
        story = s;
        break;
      }
    }
    final title = story?.title ?? '3分ストーリー';

    final content = utterancesAsync.when(
        data: (utterances) {
          if (!_hasLoggedTapToFirstContent) {
            _hasLoggedTapToFirstContent = true;
            WidgetsBinding.instance.addPostFrameCallback((_) => _logTapToFirstContentIfNeeded());
          }
          if (utterances.isEmpty) {
            return Center(
              child: Text('発話がありません', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            );
          }
          final isFirstTimeGuidedFlow = (firstListenAsync.valueOrNull ?? true) == false;
          if (widget.autoStartPlayback && !_autoStarted && !_isPlaying && !isFirstTimeGuidedFlow) {
            _autoStarted = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _isPlaying) return;
              _playAllUtterances(utterances);
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Speak風ガイドフロー Phase 1: ポップアップ表示前は何も表示しない
                if (isFirstTimeGuidedFlow && !_guidedFlowPlayButtonRevealed)
                  const SizedBox.shrink()
                else ...[
                // メイン: 3分一気に聴く
                _SectionTitle(icon: Icons.headphones, label: '3分一気に聴く'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: Theme.of(context).brightness == Brightness.dark ? null : [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (_isPlaying) ...[
                        Text(
                          '${_currentUtteranceIndex + 1} / ${utterances.length}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: utterances.isEmpty
                              ? 0
                              : ((_currentUtteranceIndex + 1) / utterances.length).clamp(0.0, 1.0),
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _stopPlayback,
                          icon: const Icon(Icons.stop, size: 22),
                          label: const Text('停止'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                            foregroundColor: Theme.of(context).colorScheme.onError,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          ),
                        ),
                      ] else
                        Builder(
                          builder: (context) {
                            if (!_hasLoggedPrimaryCtaVisible) {
                              _hasLoggedPrimaryCtaVisible = true;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  ref.read(analyticsServiceProvider).logPrimaryCtaVisible(
                                        screenName: 'story_study',
                                        surface: 'play_button',
                                        variant: 'motion_sync',
                                      );
                                }
                              });
                            }
                            return FilledButton.icon(
                              onPressed: () {
                                ref.read(analyticsServiceProvider).logPrimaryCtaTapped(
                                      screenName: 'story_study',
                                      surface: 'play_button',
                                      variant: 'motion_sync',
                                    );
                                _playAllUtterances(utterances);
                              },
                              icon: const Icon(Icons.play_arrow, size: 26),
                              label: const Text('再生して聴く'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Speak風ガイドフロー: 初回聴き終わり前は A役/B役・チャンクを非表示
                if (!isFirstTimeGuidedFlow || _hasListenedToAll) ...[
                // A役・B役で3分通し練習
                _SectionTitle(icon: Icons.mic, label: '役で3分通し練習'),
                const SizedBox(height: 8),
                conversationsAsync.when(
                  data: (conversations) {
                    if (conversations.isEmpty) return const SizedBox.shrink();
                    final firstId = conversations.first.id;
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/conversation/$firstId?mode=roleA'),
                            icon: const Icon(Icons.person_outline, size: 20),
                            label: const Text('A役で練習'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: EngrowthColors.roleA,
                              side: const BorderSide(color: EngrowthColors.roleA),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/conversation/$firstId?mode=roleB'),
                            icon: const Icon(Icons.person_outline, size: 20),
                            label: const Text('B役で練習'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: EngrowthColors.roleB,
                              side: const BorderSide(color: EngrowthColors.roleB),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 28),
                // サブ: チャンクで聴く・練習する
                _SectionTitle(icon: Icons.queue_music, label: 'チャンクで聴く・練習する'),
                const SizedBox(height: 8),
                conversationsAsync.when(
                  data: (conversations) {
                    return Column(
                      children: [
                        for (var i = 0; i < conversations.length; i++) ...[
                          _ChunkTile(
                            conversation: conversations[i],
                            partLabel: conversations.length > 1 ? 'パート ${i + 1}' : null,
                          ),
                          if (i < conversations.length - 1) const SizedBox(height: 8),
                        ],
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('エラー: $e', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
                ],  // !isFirstTimeGuidedFlow || _hasListenedToAll
                ],  // else (guided flow phase 2+)
              ],
            ),
          );
        },
        loading: () => const StoryDetailSkeleton(),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('エラー: $e', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
        ),
      );

    if (!widget.asSheet) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            FavoriteToggleIcon(
              targetType: 'story',
              targetId: widget.storyId,
              size: 24,
            ),
          ],
        ),
        body: Column(
          children: [
            _StoryHeroBanner(storyId: widget.storyId, story: story),
            Expanded(
              child: FadeSlideSwitcher(
                childKey: ValueKey(
                  utterancesAsync.hasValue
                      ? 'data'
                      : (utterancesAsync.hasError ? 'error' : 'loading'),
                ),
                child: content,
              ),
            ),
          ],
        ),
      );
    }

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.35),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: '閉じる',
                    onPressed: () {
                      if (widget.onClose != null) {
                        widget.onClose!.call();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}

/// Heroターゲット: 一覧カードのサムネイルと連続感を出す
class _StoryHeroBanner extends StatelessWidget {
  final String storyId;
  final StorySequence? story;

  const _StoryHeroBanner({required this.storyId, this.story});

  static const _defaultGradient = LinearGradient(
    colors: [Color(0xFFF0F1F4), Color(0xFFDDE1E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'storyHero_$storyId',
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        child: SizedBox(
          height: 120,
          width: double.infinity,
          child: story?.thumbnailUrl != null
              ? OptimizedImage(
                  imageUrl: story!.thumbnailUrl!,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                )
              : DecoratedBox(
                  decoration: const BoxDecoration(gradient: _defaultGradient),
                  child: Image.asset(
                    kScenarioBgAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                  ),
                ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ChunkTile extends StatelessWidget {
  final Conversation conversation;
  final String? partLabel;

  const _ChunkTile({required this.conversation, this.partLabel});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => context.push('/conversation/${conversation.id}?mode=listen'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.play_circle_outline, color: Theme.of(context).colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (partLabel != null)
                      Text(
                        partLabel!,
                        style: TextStyle(
                          fontSize: 12,
                          color: EngrowthColors.onSurfaceVariant,
                        ),
                      ),
                    if (partLabel != null) const SizedBox(height: 2),
                    Text(
                      conversation.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
