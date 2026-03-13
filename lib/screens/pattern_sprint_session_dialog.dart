import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pattern_sprint_phase.dart';
import '../providers/pattern_sprint_provider.dart';
import '../providers/analytics_provider.dart';
import '../services/pattern_sprint_service.dart';
import '../services/tts_service.dart';
import '../services/analytics_service.dart';
import '../theme/engrowth_theme.dart';

/// セッション終了時に showDialog の呼び出し元へ返す結果
class PatternSprintResult {
  const PatternSprintResult({
    required this.completed,
    required this.playedCount,
    required this.elapsedSec,
  });

  final bool completed;
  final int playedCount;
  final int elapsedSec;
}

/// パターンスプリント セッションを Dialog 内で実行するウィジェット。
/// 3段階練習: 1回目日英表示→2回目英文のみ→3回目テキストなし→シャドーイング待機→次へ
/// 終了時は Navigator.pop(context, PatternSprintResult) で結果を返す。
class PatternSprintSessionDialog extends ConsumerStatefulWidget {
  const PatternSprintSessionDialog({
    super.key,
    required this.prefix,
    required this.durationSec,
  });

  final String prefix;
  final int durationSec;

  @override
  ConsumerState<PatternSprintSessionDialog> createState() =>
      _PatternSprintSessionDialogState();
}

class _PatternSprintSessionDialogState
    extends ConsumerState<PatternSprintSessionDialog> {
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
  bool _timeExpired = false;
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
      eventType: 'pattern_sprint_session_start_dialog',
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

  Future<void> _warmupFirst(List<PatternSprintItem> items) async {
    if (items.isEmpty) return;
    final gen = _prefetchGenId;
    final url = await _ttsService.fetchAudioUrlForEnglish(
      items[0].englishText,
      role: items[0].speakerRole,
    );
    if (!mounted || gen != _prefetchGenId) return;
    if (url != null) {
      _prefetchedUrls[0] = url;
    }
  }

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
    if (!mounted || _stopped) return;
    if (_timeExpired || _elapsedSec >= widget.durationSec) {
      _onSessionComplete(items);
      return;
    }
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
      if (_timeExpired || _elapsedSec >= widget.durationSec) {
        _onSessionComplete(items);
        return;
      }
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

      final playMs = await _playOnce(
        item,
        prefetchedUrl: phase == PatternSprintPhase.phase1 ? prefetchedUrl : null,
      );
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
    if (items.isEmpty) {
      _onSessionComplete(items);
      return;
    }

    await _warmupFirst(items);
    if (!mounted || _stopped) return;

    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _stopped) return;
      setState(() => _elapsedSec++);
      if (_elapsedSec >= widget.durationSec) {
        _elapsedTimer?.cancel();
        setState(() => _timeExpired = true);
      }
    });
    _advance(items);
  }

  void _onSessionComplete(List<PatternSprintItem> items) {
    _elapsedTimer?.cancel();
    _advanceTimer?.cancel();
    final playedCount = (_currentIndex + 1).clamp(0, items.length);
    AnalyticsService().logEvent(
      eventType: 'pattern_sprint_session_complete_dialog',
      eventProperties: {
        'prefix': widget.prefix,
        'duration_sec': widget.durationSec,
        'played_count': playedCount,
        'elapsed_sec': _elapsedSec,
      },
    );
    if (!mounted) return;
    Navigator.of(context).pop(
      PatternSprintResult(
        completed: true,
        playedCount: playedCount,
        elapsedSec: _elapsedSec,
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
      eventType: 'pattern_sprint_session_abort_dialog',
      eventProperties: {
        'prefix': widget.prefix,
        'elapsed_sec': _elapsedSec,
        'current_index': _currentIndex,
      },
    );
    setState(() => _isPlaying = false);
    if (!mounted) return;
    Navigator.of(context).pop(
      PatternSprintResult(
        completed: false,
        playedCount: _currentIndex,
        elapsedSec: _elapsedSec,
      ),
    );
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
    final params = (
      prefix: widget.prefix,
      durationSec: widget.durationSec,
      minPhrases: null,
    );
    final itemsAsync = ref.watch(patternSprintSessionItemsProvider(params));
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height *
              EngrowthPopupTokens.largeHeightFraction,
          maxHeight: MediaQuery.of(context).size.height *
              EngrowthPopupTokens.largeHeightFraction,
        ),
        child: Material(
          borderRadius: BorderRadius.circular(20),
          color: colorScheme.surface,
          child: itemsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
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
                        onPressed: () {
                          if (mounted) {
                            Navigator.of(context).pop(
                              const PatternSprintResult(
                                completed: false,
                                playedCount: 0,
                                elapsedSec: 0,
                              ),
                            );
                          }
                        },
                        child: const Text('閉じる'),
                      ),
                    ],
                  ),
                );
              }

              if (_currentIndex >= items.length) {
                return const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final item = items[_currentIndex];
              final remaining = (widget.durationSec - _elapsedSec)
                  .clamp(0, widget.durationSec);

              if (!_loopStarted && _elapsedSec == 0 && !_stopped) {
                _loopStarted = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _runLoop(items);
                });
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    // 固定レイアウト: 上から日本語・英語orアイコン(中央)・ボタン(下30%)
                    Expanded(
                      child: Column(
                        children: [
                          const Spacer(flex: 2),
                          // 日本語（phase1 のみ表示、それ以外は高さだけ確保）
                          AnimatedOpacity(
                            opacity: _currentPhase.showJapanese ? 1 : 0,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOut,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                item.japaneseText,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          // 英語（phase1,2）またはアイコン（phase3）— 常に同じ位置
                          SizedBox(
                            height: 72,
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                child: _currentPhase.showEnglish
                                    ? Text(
                                        item.englishText,
                                        key: const ValueKey('en'),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSurface,
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                    : _PulsingAudioIcon(
                                        key: const ValueKey('icon'),
                                        color: colorScheme.primary,
                                        isPlaying: _isPlaying && !_isPaused,
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (_isPaused)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '一時停止中',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          // ボタン（日本語・アイコンと同じブロック内・下30％付近に固定）
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton.filled(
                                onPressed: _onPauseResume,
                                icon: Icon(
                                    _isPaused ? Icons.play_arrow : Icons.pause),
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
                          const Spacer(flex: 3),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('エラー: $e', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (mounted) {
                        Navigator.of(context).pop(
                          const PatternSprintResult(
                            completed: false,
                            playedCount: 0,
                            elapsedSec: 0,
                          ),
                        );
                      }
                    },
                    child: const Text('閉じる'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 音声再生中を示すパルスアニメーション付きアイコン
class _PulsingAudioIcon extends StatefulWidget {
  const _PulsingAudioIcon({
    super.key,
    required this.color,
    required this.isPlaying,
  });

  final Color color;
  final bool isPlaying;

  @override
  State<_PulsingAudioIcon> createState() => _PulsingAudioIconState();
}

class _PulsingAudioIconState extends State<_PulsingAudioIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scale = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_PulsingAudioIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying) {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isPlaying ? _scale.value : 1,
          child: Icon(
            Icons.graphic_eq,
            size: 56,
            color: widget.color,
          ),
        );
      },
    );
  }
}
