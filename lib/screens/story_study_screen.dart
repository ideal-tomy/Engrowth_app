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
import '../widgets/common/engrowth_popup.dart';
import '../widgets/guided_flow/listen_first_popup.dart';
import '../widgets/guided_flow/story_after_listen_action_popup.dart';
import '../widgets/marquee/marquee_rail_data.dart';

/// 3分ストーリー学習画面
/// メイン: 3分一気に聴く / A役・B役で3分通し練習
/// サブ: チャンクごとに聴く・練習する
class StoryStudyScreen extends ConsumerStatefulWidget {
  final String storyId;
  final bool asSheet;
  /// ポップアップカルーセル内に埋め込むとき true。AppBar を出さずコンテンツのみ表示する。
  final bool asPopupContent;
  /// カルーセルで「次の学習」として表示しているとき true。ListenFirst を「学習を始める」表記に。
  final bool isNextInCarousel;
  /// true のとき「まずは音声を…」ポップアップを出さず、再生ボタンを最初から表示（次の学習へ直行時用）
  final bool skipListenFirstPopup;
  /// 次のストーリーのタイトル（6択の「次の学習へ」で「○○へ進みます」を表示するため）
  final String? nextStoryTitle;
  final VoidCallback? onClose;
  /// 初回聴き終わり時に呼ばれる（カルーセルで次ページへ進むトリガーに使用）
  final VoidCallback? onCompleted;
  final bool autoStartPlayback;
  final bool fromOnboarding;

  const StoryStudyScreen({
    super.key,
    required this.storyId,
    this.asSheet = false,
    this.asPopupContent = false,
    this.isNextInCarousel = false,
    this.skipListenFirstPopup = false,
    this.nextStoryTitle,
    this.onClose,
    this.onCompleted,
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
  final ValueNotifier<int> _currentUtteranceIndexNotifier = ValueNotifier<int>(0);
  bool _stopPlaybackRequested = false;
  bool _autoStarted = false;
  bool _hasLoggedTapToFirstContent = false;
  bool _hasLoggedPrimaryCtaVisible = false;

  // Speak風ガイドフロー用
  bool _guidedFlowPlayButtonRevealed = false;
  bool _hasShownListenFirstPopup = false;
  bool _hasListenedToAll = false;
  bool _repeatModeEnabled = false;
  bool _shadowingModeEnabled = false;

  @override
  void initState() {
    super.initState();
    if (widget.skipListenFirstPopup) {
      _guidedFlowPlayButtonRevealed = true;
      _hasShownListenFirstPopup = true;
    }
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
    _currentUtteranceIndexNotifier.dispose();
    _ttsService.stop();
    _ttsService.dispose();
    super.dispose();
  }

  Future<void> _playAllUtterances(List<ConversationUtterance> utterances) async {
    if (_isPlaying) return;
    _stopPlaybackRequested = false;
    setState(() => _isPlaying = true);

    Future<void> playOnce() async {
      for (var i = 0; i < utterances.length; i++) {
        if (!mounted) break;
        if (_stopPlaybackRequested) break;

        final utterance = utterances[i];
        setState(() => _currentUtteranceIndex = i);
        _currentUtteranceIndexNotifier.value = i;
        try {
          await _ttsService.speakEnglish(
            utterance.englishText,
            role: utterance.speakerRole,
          );
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
          final gap = _shadowingModeEnabled ? const Duration(seconds: 3) : const Duration(milliseconds: 500);
          await Future.delayed(gap);
        }
      }
    }

    await playOnce();
    if (!_stopPlaybackRequested && _repeatModeEnabled) {
      await Future.delayed(const Duration(seconds: 1));
      if (!_stopPlaybackRequested && mounted) {
        await playOnce();
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
          if (mounted) {
            if (widget.asPopupContent) {
              StoryAfterListenActionPopup.show(
                context,
                storyId: widget.storyId,
                onNextLearning: () async {
                  if (widget.nextStoryTitle != null && mounted) {
                    await EngrowthPopup.show<void>(
                      context,
                      barrierDismissible: true,
                      title: '${widget.nextStoryTitle} へ進みます',
                      autoCloseAfter: const Duration(seconds: 3),
                      analyticsVariant: 'story_next_transition',
                    );
                  }
                  widget.onCompleted?.call();
                },
              );
            } else {
              _showStoryNextActionDialog();
            }
          }
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

  /// デバッグ用: 聴き終わり状態にし、6択ポップアップを出して流れを確認できるようにする
  Future<void> _debugMarkConversationComplete() async {
    if (!kDebugMode) return;
    final service = ref.read(firstListenCompletedServiceProvider);
    await service.markCompleted('story', widget.storyId);
    ref.invalidate(firstListenCompletedProvider(('story', widget.storyId)));
    if (!mounted) return;
    setState(() {
      _hasListenedToAll = true;
      _guidedFlowPlayButtonRevealed = true;
      _hasShownListenFirstPopup = true;
    });
    if (!mounted) return;
    if (widget.asPopupContent) {
      StoryAfterListenActionPopup.show(
        context,
        storyId: widget.storyId,
        onNextLearning: () => widget.onCompleted?.call(),
      );
    }
  }

  void _showTranscriptSheet(List<ConversationUtterance> utterances) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      enableDrag: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => _StoryTranscriptSheetContent(
          utterances: utterances,
          currentIndexListenable: _currentUtteranceIndexNotifier,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showPracticeMenuSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      enableDrag: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => _StoryPracticeMenuSheetContent(
          storyId: widget.storyId,
          scrollController: scrollController,
        ),
      ),
    );
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
            final nextStoryAsync = ref.read(nextStoryIdProvider(widget.storyId));
            final nextStoryId = nextStoryAsync.valueOrNull;
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
                  if (nextStoryId != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          context.pushReplacement('/story/$nextStoryId');
                        },
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: const Text('次の学習へ'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
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

    // Speak風ガイドフロー: 初回のみポップアップ表示（skipListenFirstPopup 時は出さない）
    ref.listen(firstListenCompletedProvider(('story', widget.storyId)), (_, next) {
      next.whenData((isCompleted) {
        if (isCompleted) return;
        if (widget.skipListenFirstPopup || _hasShownListenFirstPopup || !mounted) return;
        _hasShownListenFirstPopup = true;
        ListenFirstPopup.show(
          context,
          forNextStory: widget.isNextInCarousel,
          contentType: 'story',
          contentId: widget.storyId,
          onShown: () => ref.read(analyticsServiceProvider).logGuidedFlowPopupShown(
            contentType: 'story',
            step: 'listen_first',
            contentId: widget.storyId,
          ),
          onDismiss: (_) {
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
              // 閉じたあと、次のストーリーでは自動で再生開始（1フレーム遅延でUI更新後に再生）
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                ref.read(storyUtterancesOrderedProvider(widget.storyId).future).then((utterances) {
                  if (mounted && !_isPlaying && utterances.isNotEmpty) {
                    _playAllUtterances(utterances);
                  }
                });
              });
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
          final hasCompletedFirstListen = firstListenAsync.valueOrNull ?? false;
          if (widget.autoStartPlayback && !_autoStarted && !_isPlaying) {
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
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _stopPlayback,
                                icon: const Icon(Icons.stop, size: 22),
                                label: const Text('停止'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                  foregroundColor: Theme.of(context).colorScheme.onError,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              tooltip: 'リピート再生',
                              onPressed: () {
                                setState(() {
                                  _repeatModeEnabled = !_repeatModeEnabled;
                                });
                              },
                              icon: Icon(
                                _repeatModeEnabled ? Icons.repeat_one : Icons.repeat,
                                color: _repeatModeEnabled
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            IconButton(
                              tooltip: 'シャドーイングモード',
                              onPressed: () {
                                setState(() {
                                  _shadowingModeEnabled = !_shadowingModeEnabled;
                                });
                              },
                              icon: Icon(
                                Icons.hearing,
                                color: _shadowingModeEnabled
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
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
                            return Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
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
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  tooltip: 'リピート再生',
                                  onPressed: () {
                                    setState(() {
                                      _repeatModeEnabled = !_repeatModeEnabled;
                                    });
                                  },
                                  icon: Icon(
                                    _repeatModeEnabled ? Icons.repeat_one : Icons.repeat,
                                    color: _repeatModeEnabled
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'シャドーイングモード（長めの間を入れる）',
                                  onPressed: () {
                                    setState(() {
                                      _shadowingModeEnabled = !_shadowingModeEnabled;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.hearing,
                                    color: _shadowingModeEnabled
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 下部2ボタン: 会話の英文を見る / 練習メニュー（ボトムシートで表示）
                _BottomActionBar(
                  onShowTranscript: () => _showTranscriptSheet(utterances),
                  onShowPracticeMenu: () => _showPracticeMenuSheet(),
                ),
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

    if (widget.asPopupContent) {
      return Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StoryHeroBanner(storyId: widget.storyId, story: story, large: true),
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
          if (kDebugMode)
            Positioned(
              top: 8,
              left: 8,
              child: Material(
                color: Colors.amber.shade700,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => _debugMarkConversationComplete(),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text(
                      '会話を完了状態にする',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    if (!widget.asSheet) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            if (kDebugMode)
              TextButton(
                onPressed: _debugMarkConversationComplete,
                child: const Text('完了にする', style: TextStyle(fontSize: 12)),
              ),
            FavoriteToggleIcon(
              targetType: 'story',
              targetId: widget.storyId,
              size: 24,
            ),
          ],
        ),
        body: Column(
          children: [
            _StoryHeroBanner(storyId: widget.storyId, story: story, large: true),
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
  /// 一覧ポップアップでは小さく、フル画面では大きく表示するためのフラグ
  final bool large;

  const _StoryHeroBanner({
    required this.storyId,
    this.story,
    this.large = false,
  });

  static const _defaultGradient = LinearGradient(
    colors: [Color(0xFFF0F1F4), Color(0xFFDDE1E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final height = large ? screenHeight * 0.5 : 120.0;

    return Hero(
      tag: 'storyHero_$storyId',
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: story?.thumbnailUrl != null
              ? OptimizedImage(
                  imageUrl: story!.thumbnailUrl!,
                  width: double.infinity,
                  height: height,
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

class _BottomActionBar extends StatelessWidget {
  final VoidCallback onShowTranscript;
  final VoidCallback onShowPracticeMenu;

  const _BottomActionBar({
    required this.onShowTranscript,
    required this.onShowPracticeMenu,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonal(
            onPressed: onShowTranscript,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text(
              '会話の英文を表示する',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.tonal(
            onPressed: onShowPracticeMenu,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text(
              '練習メニュー',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StoryTranscriptSheetContent extends StatelessWidget {
  final List<ConversationUtterance> utterances;
  final ValueListenable<int> currentIndexListenable;
  final ScrollController scrollController;

  const _StoryTranscriptSheetContent({
    required this.utterances,
    required this.currentIndexListenable,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 5,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity(0.35),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '会話の英文',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: currentIndexListenable,
              builder: (context, currentIndex, _) {
                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: utterances.length,
                  itemBuilder: (context, index) {
                    final u = utterances[index];
                    final isActive = index == currentIndex;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isActive
                            ? colorScheme.primary.withOpacity(0.08)
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u.englishText,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            u.japaneseText,
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryPracticeMenuSheetContent extends ConsumerWidget {
  final String storyId;
  final ScrollController scrollController;

  const _StoryPracticeMenuSheetContent({
    required this.storyId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final conversationsAsync = ref.watch(storyConversationsProvider(storyId));

    return Material(
      color: colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 5,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity(0.35),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '練習メニュー',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: conversationsAsync.when(
              data: (conversations) {
                if (conversations.isEmpty) {
                  return const Center(child: Text('このストーリーの会話が見つかりません'));
                }
                final firstId = conversations.first.id;
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    Text(
                      '役で通し練習',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.push('/conversation/$firstId?mode=roleA');
                            },
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
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.push('/conversation/$firstId?mode=roleB');
                            },
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
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'チャンクで聴く',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        for (var i = 0; i < conversations.length; i++) ...[
                          _ChunkTile(
                            conversation: conversations[i],
                            partLabel: conversations.length > 1 ? 'パート ${i + 1}' : null,
                          ),
                          if (i < conversations.length - 1) const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'エラー: $e',
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
