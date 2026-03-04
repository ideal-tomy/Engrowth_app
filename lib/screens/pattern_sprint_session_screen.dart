import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/pattern_sprint_phase.dart';
import '../providers/pattern_sprint_provider.dart';
import '../providers/analytics_provider.dart';
import '../widgets/marquee/marquee_rail_data.dart';
import '../services/pattern_sprint_service.dart';
import '../services/tts_service.dart';
import '../models/learning_handoff_result.dart';
import '../services/analytics_service.dart';

/// パターンスプリント セッション実行画面
/// 3段階練習: 1回目日英表示→2回目英文のみ→3回目テキストなし→シャドーイング待機→次へ
class PatternSprintSessionScreen extends ConsumerStatefulWidget {
  final String prefix;
  final int durationSec;
  final bool fromOnboarding;

  const PatternSprintSessionScreen({
    super.key,
    required this.prefix,
    required this.durationSec,
    this.fromOnboarding = false,
  });

  @override
  ConsumerState<PatternSprintSessionScreen> createState() =>
      _PatternSprintSessionScreenState();
}

class _PatternSprintSessionScreenState
    extends ConsumerState<PatternSprintSessionScreen> {
  final TtsService _ttsService = TtsService();
  final Map<int, String> _prefetchedUrls = {};
  int _prefetchGenId = 0;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _stopped = false;
  int _currentIndex = 0;
  PatternSprintPhase _currentPhase = PatternSprintPhase.phase1;
  int _elapsedSec = 0;
  Timer? _elapsedTimer;
  Timer? _advanceTimer;
  DateTime? _lastTapTime;
  Completer<void>? _delayCompleter;
  bool _loopStarted = false;
  static const _advanceDebounceMs = 300;
  static const _phase12DelayMs = 2000;
  static const _shadowingGapMinMs = 1200;
  static const _shadowingGapMaxMs = 8000;
  static const _shadowingGapMultiplier = 1.2;

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
    AnalyticsService().logEvent(
      eventType: 'pattern_sprint_session_start',
      eventProperties: {
        'prefix': widget.prefix,
        'duration_sec': widget.durationSec,
      },
    );
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _advanceTimer?.cancel();
    _clearPrefetch();
    _ttsService.stop();
    _ttsService.dispose();
    super.dispose();
  }

  void _clearPrefetch() {
    _prefetchGenId++;
    _prefetchedUrls.clear();
  }

  bool _debounceTap() {
    final now = DateTime.now();
    final last = _lastTapTime;
    _lastTapTime = now;
    if (last != null &&
        now.difference(last).inMilliseconds < _advanceDebounceMs) {
      return false;
    }
    return true;
  }

  Future<void> _prefetchNext(List<PatternSprintItem> items, int index) async {
    final next = index + 1;
    if (next >= items.length) return;
    final gen = _prefetchGenId;
    final url = await _ttsService.fetchAudioUrlForEnglish(
      items[next].englishText,
      role: items[next].speakerRole,
    );
    if (url != null && gen == _prefetchGenId && mounted) {
      _prefetchedUrls[next] = url;
    }
  }

  /// 1回分の再生を行い、再生時間(ms)を返す
  Future<int> _playOnce(
    PatternSprintItem item, {
    String? prefetchedUrl,
  }) async {
    if (!mounted) return 0;
    final stopwatch = Stopwatch()..start();
    setState(() => _isPlaying = true);

    await _ttsService.speakEnglish(
      item.englishText,
      role: item.speakerRole,
      prefetchedUrl: prefetchedUrl,
    );

    stopwatch.stop();
    final playMs = stopwatch.elapsedMilliseconds;

    if (!mounted || _stopped) return playMs;
    setState(() => _isPlaying = false);

    return playMs;
  }

  /// フェーズ1・2後の固定待機、フェーズ3後は再生時間の1.2倍（シャドーイング用）
  Future<void> _waitAfterPlay(PatternSprintPhase phase, int playMs) async {
    final delayMs = phase == PatternSprintPhase.phase3
        ? (playMs * _shadowingGapMultiplier)
            .round()
            .clamp(_shadowingGapMinMs, _shadowingGapMaxMs)
        : _phase12DelayMs;

    if (phase == PatternSprintPhase.phase3) {
      AnalyticsService().logPatternSprintShadowingGap(
        playMs: playMs,
        gapMs: delayMs,
      );
    }

    _delayCompleter = Completer<void>();
    _advanceTimer?.cancel();
    _advanceTimer = Timer(
      Duration(milliseconds: delayMs),
      () {
        if (!_delayCompleter!.isCompleted) {
          _delayCompleter!.complete();
        }
      },
    );
    await _delayCompleter!.future;
  }

  void _completeDelayEarly() {
    _advanceTimer?.cancel();
    if (_delayCompleter != null && !_delayCompleter!.isCompleted) {
      _delayCompleter!.complete();
    }
  }

  void _advance(List<PatternSprintItem> items) {
    if (!mounted || _stopped || _elapsedSec >= widget.durationSec) return;
    if (_currentIndex >= items.length) {
      _onSessionComplete(items);
      return;
    }

    final item = items[_currentIndex];
    _prefetchNext(items, _currentIndex);
    final prefetched = _prefetchedUrls.remove(_currentIndex);

    _runPhase(item, prefetchedUrl: prefetched).then((_) async {
      if (!mounted || _stopped) return;
      while (_isPaused && mounted && !_stopped) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
      if (!mounted || _stopped) return;
      setState(() {
        _currentIndex++;
        _currentPhase = PatternSprintPhase.phase1;
      });
      _advance(items);
    });
  }

  Future<void> _runPhase(
    PatternSprintItem item, {
    String? prefetchedUrl,
  }) async {
    for (final phase in PatternSprintPhase.values) {
      if (!mounted || _stopped) return;
      setState(() => _currentPhase = phase);

      AnalyticsService().logPatternSprintPhaseStarted(
        phase: phase.index,
        itemIndex: _currentIndex,
      );

      final playMs = await _playOnce(item, prefetchedUrl: phase == PatternSprintPhase.phase1 ? prefetchedUrl : null);
      if (!mounted || _stopped) return;

      await _waitAfterPlay(phase, playMs);
      if (!mounted || _stopped) return;

      AnalyticsService().logPatternSprintPhaseCompleted(
        phase: phase.index,
        itemIndex: _currentIndex,
      );
    }
  }

  Future<void> _runLoop(List<PatternSprintItem> items) async {
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _stopped) return;
      setState(() => _elapsedSec++);
      if (_elapsedSec >= widget.durationSec) {
        _elapsedTimer?.cancel();
        _onSessionComplete(items);
      }
    });
    _advance(items);
  }

  void _onSessionComplete(List<PatternSprintItem> items) {
    _elapsedTimer?.cancel();
    _advanceTimer?.cancel();
    AnalyticsService().logEvent(
      eventType: 'pattern_sprint_session_complete',
      eventProperties: {
        'prefix': widget.prefix,
        'duration_sec': widget.durationSec,
        'played_count': items.length,
        'elapsed_sec': _elapsedSec,
      },
    );
    if (!mounted) return;
    _showCompleteDialog(items);
  }

  void _showCompleteDialog(List<PatternSprintItem> items) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('セッション完了'),
        content: Text(
          '${items.length} フレーズを練習しました。\n'
          '推定 ${_elapsedSec} 秒。',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (context.mounted) {
                if (widget.fromOnboarding) {
                  context.pop(LearningHandoffResult.completedWithMode('pattern_sprint'));
                } else {
                  context.go('/pattern-sprint');
                }
              }
            },
            child: const Text('一覧へ'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _currentIndex = 0;
                _currentPhase = PatternSprintPhase.phase1;
                _elapsedSec = 0;
                _stopped = false;
                _loopStarted = true;
              });
              _runLoop(items);
            },
            child: const Text('もう1セット'),
          ),
        ],
      ),
    );
  }

  void _onStop() {
    if (!_debounceTap()) return;
    HapticFeedback.selectionClick();
    _stopped = true;
    _clearPrefetch();
    _ttsService.stop();
    _elapsedTimer?.cancel();
    _advanceTimer?.cancel();
    AnalyticsService().logEvent(
      eventType: 'pattern_sprint_session_abort',
      eventProperties: {
        'prefix': widget.prefix,
        'elapsed_sec': _elapsedSec,
        'current_index': _currentIndex,
      },
    );
    setState(() => _isPlaying = false);
    context.pop();
  }

  void _onSkip() {
    if (!_debounceTap()) return;
    HapticFeedback.selectionClick();
    _ttsService.stop();
    _completeDelayEarly();
  }

  void _onPauseResume() {
    if (!_debounceTap()) return;
    HapticFeedback.selectionClick();
    setState(() => _isPaused = !_isPaused);
    if (!_isPaused) {
      _completeDelayEarly();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctx = ref.read(lastMarqueeTapContextProvider.notifier).consumeIfRecent();
    if (ctx != null) {
      ref.read(analyticsServiceProvider).logLearningEntryStarted(
            learningMode: 'pattern_sprint',
            entrySource: 'marquee',
            tapId: ctx.tapId,
          );
    }
    final params = (prefix: widget.prefix, durationSec: widget.durationSec);
    final itemsAsync = ref.watch(patternSprintSessionItemsProvider(params));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('パターンスプリント'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('終了'),
                content: const Text('セッションを終了しますか？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('キャンセル'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _onStop();
                    },
                    child: const Text('終了'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'このパターンに該当する発話がありません',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.pop(),
                    child: const Text('一覧へ戻る'),
                  ),
                ],
              ),
            );
          }

          if (_currentIndex >= items.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final item = items[_currentIndex];
          final remaining =
              (widget.durationSec - _elapsedSec).clamp(0, widget.durationSec);

          if (!_loopStarted && _elapsedSec == 0 && !_stopped) {
            _loopStarted = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _runLoop(items);
            });
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '残り ${remaining}秒',
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${_currentIndex + 1} / ${items.length} (${_currentPhase.index}/3)',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_currentPhase.showJapanese)
                          Text(
                            item.japaneseText,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        if (_currentPhase.showJapanese && _currentPhase.showEnglish)
                          const SizedBox(height: 12),
                        if (_currentPhase.showEnglish)
                          Text(
                            item.englishText,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        if (!_currentPhase.showEnglish && !_currentPhase.showJapanese)
                          Text(
                            _isPlaying ? 'Listen...' : 'Repeat now',
                            style: TextStyle(
                              fontSize: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Text(
                  _isPlaying
                      ? 'Listening...'
                      : _isPaused
                          ? '一時停止中'
                          : 'Repeat now',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton.filled(
                      onPressed: _onPauseResume,
                      icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                      tooltip: _isPaused ? '再開' : '一時停止',
                    ),
                    IconButton.filled(
                      onPressed: _onSkip,
                      icon: const Icon(Icons.skip_next),
                      tooltip: 'スキップ',
                    ),
                    IconButton.filled(
                      onPressed: _onStop,
                      icon: const Icon(Icons.stop),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.errorContainer,
                        foregroundColor: colorScheme.onErrorContainer,
                      ),
                      tooltip: '停止',
                    ),
                  ],
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
              Text('エラー: $e', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('一覧へ戻る'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
