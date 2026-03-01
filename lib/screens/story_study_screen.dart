import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/conversation.dart';
import '../models/story_sequence.dart';
import '../providers/story_provider.dart';
import '../services/tts_service.dart';
import '../theme/engrowth_theme.dart';
import '../widgets/favorite_toggle_icon.dart';

/// 3分ストーリー学習画面
/// メイン: 3分一気に聴く / A役・B役で3分通し練習
/// サブ: チャンクごとに聴く・練習する
class StoryStudyScreen extends ConsumerStatefulWidget {
  final String storyId;
  final bool asSheet;
  final VoidCallback? onClose;
  final bool autoStartPlayback;

  const StoryStudyScreen({
    super.key,
    required this.storyId,
    this.asSheet = false,
    this.onClose,
    this.autoStartPlayback = false,
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

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
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
      await _ttsService.speakEnglish(utterance.englishText);

      if (!mounted) break;
      if (_stopPlaybackRequested) break;

      if (i < utterances.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    if (mounted) {
      setState(() {
        _isPlaying = false;
        _stopPlaybackRequested = false;
      });
    }
  }

  Future<void> _stopPlayback() async {
    _stopPlaybackRequested = true;
    await _ttsService.stop();
    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storiesAsync = ref.watch(storySequencesProvider);
    final utterancesAsync = ref.watch(storyUtterancesOrderedProvider(widget.storyId));
    final conversationsAsync = ref.watch(storyConversationsProvider(widget.storyId));

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
          if (utterances.isEmpty) {
            return Center(
              child: Text('発話がありません', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            );
          }
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
                        FilledButton.icon(
                          onPressed: () => _playAllUtterances(utterances),
                          icon: const Icon(Icons.play_arrow, size: 26),
                          label: const Text('再生して聴く'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
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
        body: content,
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
