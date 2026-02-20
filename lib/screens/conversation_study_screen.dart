import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation.dart';
import '../providers/conversation_provider.dart';
import '../services/tts_service.dart';
import '../services/voice_playback_service.dart';
import '../services/conversation_learning_events_service.dart';
import '../services/learning_completion_orchestrator.dart';

import '../theme/engrowth_theme.dart';
import '../widgets/audio_controls.dart';
import '../widgets/bottom_interaction_bar.dart';
import '../widgets/optimized_image.dart';
import '../widgets/scenario_background.dart';

/// 会話学習画面（音声メイン）
/// スマホ1画面で完結・スクロール不要のUI
class ConversationStudyScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String initialMode;  // listen, roleA, roleB

  const ConversationStudyScreen({
    super.key,
    required this.conversationId,
    this.initialMode = 'listen',
  });

  @override
  ConsumerState<ConversationStudyScreen> createState() => _ConversationStudyScreenState();
}

class _ConversationStudyScreenState extends ConsumerState<ConversationStudyScreen>
    with TickerProviderStateMixin {
  int _currentUtteranceIndex = 0;
  String? _sessionId;
  final TtsService _ttsService = TtsService();
  final VoicePlaybackService _playbackService = VoicePlaybackService();
  final ConversationLearningEventsService _learningEvents = ConversationLearningEventsService();
  bool _isPlaying = false;
  Map<String, bool> _textVisibleMap = {};
  bool _showAllTexts = false;
  String _mode = 'listen';  // listen, roleA, roleB
  bool _hasListenedToAll = false;  // ①会話全体を聞いたか
  Set<String> _revealedTextInRoleMode = {};  // 役モードで「テキスト表示」を押した発話
  bool _isCountdownActive = false;  // 3秒カウントダウン中
  int _countdownValue = 3;  // カウントダウン表示用
  bool _stopPlaybackRequested = false;  // 再生停止フラグ
  ValueNotifier<int>? _transcriptCurrentIndexNotifier;  // 英語シート用：再生中のフレーズインデックス
  ValueNotifier<bool>? _transcriptIsPlayingNotifier;  // 英語シート用：再生中フラグ（同期用）
  Timer? _autoAdvanceTimer;
  int? _autoAdvanceSecondsRemaining;  // 残り秒（表示用）
  late AnimationController _pulseController;
  late AnimationController _progressController;  // フレーズ内のゆっくりとした進行用

  @override
  void initState() {
    super.initState();
    // ①会話を聞いてから②A/B役の流れを徹底するため、常に listen から開始
    _mode = 'listen';
    _initializeSession();
    _ttsService.initialize();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),  // 1フレーズあたり約2.5秒でゆっくり進行
    );
  }

  @override
  void dispose() {
    _transcriptCurrentIndexNotifier?.dispose();
    _transcriptCurrentIndexNotifier = null;
    _transcriptIsPlayingNotifier?.dispose();
    _transcriptIsPlayingNotifier = null;
    _autoAdvanceTimer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  static const _delayAfterRecordingSec = 1.2;
  static const _delayAfterOpponentSec = 0.6;

  void _cancelAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;
    if (_autoAdvanceSecondsRemaining != null) {
      setState(() => _autoAdvanceSecondsRemaining = null);
    }
  }

  void _scheduleAdvanceAfterRecording(List<ConversationUtterance> utterances) {
    _cancelAutoAdvance();
    final ms = (_delayAfterRecordingSec * 1000).round();
    setState(() => _autoAdvanceSecondsRemaining = _delayAfterRecordingSec.ceil());
    _autoAdvanceTimer = Timer(Duration(milliseconds: ms), () {
      if (!mounted) return;
      _autoAdvanceTimer = null;
      setState(() => _autoAdvanceSecondsRemaining = null);
      _doAdvance(utterances);
    });
  }

  void _scheduleAdvanceAfterOpponentTts(List<ConversationUtterance> utterances) {
    _cancelAutoAdvance();
    final opponentMs = (_delayAfterOpponentSec * 1000).round();
    _autoAdvanceTimer = Timer(Duration(milliseconds: opponentMs), () {
      if (!mounted) return;
      _autoAdvanceTimer = null;
      _doAdvance(utterances);
    });
  }

  /// インデックスを進め、自分の番/相手の番に応じて再生・録音待機を自動切り替え
  /// ・自分の番：UIが録音待機を表示（onRecordingComplete → _scheduleAdvanceAfterRecording）
  /// ・相手の番：TTS再生 → 終了後 _scheduleAdvanceAfterOpponentTts で再帰的に進行
  void _doAdvance(List<ConversationUtterance> utterances) {
    _cancelAutoAdvance();
    if (_currentUtteranceIndex >= utterances.length - 1) {
      _maybeLogRoleCompleted(utterances);
      return;
    }
    if (_mode == 'roleA' || _mode == 'roleB') _logAutoAdvanceUsed();
    setState(() => _currentUtteranceIndex++);
    final next = utterances[_currentUtteranceIndex];
    if ((_mode == 'roleA' || _mode == 'roleB') && !_isMyRole(next)) {
      _playOpponentAndScheduleAdvance(utterances, _currentUtteranceIndex);
    }
    // 自分の番の場合は何もしない（録音待機UIを表示）
  }

  Future<void> _playOpponentAndScheduleAdvance(List<ConversationUtterance> utterances, int index) async {
    if (index >= utterances.length) return;
    final utterance = utterances[index];
    setState(() => _isPlaying = true);
    _progressController.forward(from: 0);
    await _ttsService.speakEnglish(utterance.englishText);
    if (!mounted) return;
    _progressController.value = 1.0;
    setState(() => _isPlaying = false);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null && _sessionId != null) {
      await _playbackService.recordPlayback(
        userId: userId,
        conversationId: widget.conversationId,
        utteranceId: utterance.id,
        sessionId: _sessionId!,
        playbackType: 'tts',
      );
    }
    if (!mounted) return;
    _scheduleAdvanceAfterOpponentTts(utterances);
  }

  void _advanceNext(List<ConversationUtterance> utterances) {
    _cancelAutoAdvance();
    if (_currentUtteranceIndex >= utterances.length - 1) {
      _maybeLogRoleCompleted(utterances);
      return;
    }
    if (_mode == 'roleA' || _mode == 'roleB') _logManualNextUsed();
    setState(() => _currentUtteranceIndex++);
    final next = utterances[_currentUtteranceIndex];
    if ((_mode == 'roleA' || _mode == 'roleB') && !_isMyRole(next)) {
      _playOpponentAndScheduleAdvance(utterances, _currentUtteranceIndex);
    }
  }

  void _advancePrev(List<ConversationUtterance> utterances) {
    _cancelAutoAdvance();
    if (_currentUtteranceIndex <= 0) return;
    setState(() => _currentUtteranceIndex--);
  }

  void _logAutoAdvanceUsed() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _learningEvents.logAutoAdvanceUsed(
        userId: userId,
        conversationId: widget.conversationId,
        sessionId: _sessionId,
      );
    }
  }

  void _logManualNextUsed() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _learningEvents.logManualNextUsed(
        userId: userId,
        conversationId: widget.conversationId,
        sessionId: _sessionId,
      );
    }
  }

  void _maybeLogRoleCompleted(List<ConversationUtterance> utterances) {
    if (_mode != 'roleA' && _mode != 'roleB') return;
    if (_currentUtteranceIndex < utterances.length - 1) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _learningEvents.logRoleCompleted(
        userId: userId,
        conversationId: widget.conversationId,
        sessionId: _sessionId,
        role: _mode == 'roleA' ? 'A' : 'B',
      );
      unawaited(LearningCompletionOrchestrator.onLearningCompleted(ref, context));
    }
  }

  void _initializeSession() {
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _playUtterance(ConversationUtterance utterance) async {
    if (_isPlaying) {
      await _ttsService.stop();
      setState(() => _isPlaying = false);
      return;
    }

    setState(() => _isPlaying = true);
    _progressController.forward(from: 0);

      await _ttsService.speakEnglish(utterance.englishText);

    if (mounted) _progressController.value = 1.0;
    setState(() => _isPlaying = false);

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null && _sessionId != null) {
      await _playbackService.recordPlayback(
        userId: userId,
        conversationId: widget.conversationId,
        utteranceId: utterance.id,
        sessionId: _sessionId!,
        playbackType: 'tts',
      );
    }
    // 役モードではテキスト表示しない（音のみ学習のため）
    if (mounted && _mode == 'listen') {
      setState(() => _textVisibleMap[utterance.id] = true);
    }
  }

  Future<void> _stopPlayback() async {
    _stopPlaybackRequested = true;
    await _ttsService.stop();
    if (mounted) {
      setState(() => _isPlaying = false);
      _transcriptIsPlayingNotifier?.value = false;
    }
    // _stopPlaybackRequested はループ終了時にクリア（wasStopped 判定のためここでは触らない）
  }

  /// 会話全体を再生。startIndex 指定時はその位置から（再開時は一つ前からで文脈を思い出せるように）
  Future<void> _playAllConversation(
    List<ConversationUtterance> utterances, {
    bool showPromptOnComplete = true,
    int? startIndex,
  }) async {
    if (_isPlaying) return;

    _stopPlaybackRequested = false;
    final fromIndex = startIndex ?? 0;
    setState(() => _isPlaying = true);
    _transcriptIsPlayingNotifier?.value = true;

    for (var i = fromIndex; i < utterances.length; i++) {
      if (!mounted) break;
      if (_stopPlaybackRequested) break;

      final utterance = utterances[i];
      setState(() => _currentUtteranceIndex = i);
      _transcriptCurrentIndexNotifier?.value = i;  // 英語シートのハイライト同期

      // プログレスバーをゆっくり進行させる（フレーズ再生中）
      _progressController.forward(from: 0);

      final speakFuture = _ttsService.speakEnglish(utterance.englishText);

      // 再生が終わったらプログレスを完了位置に
      speakFuture.whenComplete(() {
        if (mounted) _progressController.value = 1.0;
      });

      await speakFuture;

      if (!mounted) break;
      if (_stopPlaybackRequested) break;

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null && _sessionId != null) {
        await _playbackService.recordPlayback(
          userId: userId,
          conversationId: widget.conversationId,
          utteranceId: utterance.id,
          sessionId: _sessionId!,
          playbackType: 'tts',
        );
        if (_mode == 'listen') {
          setState(() => _textVisibleMap[utterance.id] = true);
        }
      }

      if (i < utterances.length - 1 && !_stopPlaybackRequested) {
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
      _transcriptIsPlayingNotifier?.value = false;
      if (!wasStoppedByUser && showPromptOnComplete) {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          _learningEvents.logListenCompleted(
            userId: userId,
            conversationId: widget.conversationId,
            sessionId: _sessionId,
          );
          await LearningCompletionOrchestrator.onLearningCompleted(ref, context);
        }
        if (mounted) _showNextActionDialog(utterances);
      }
    }
  }

  /// 再開用：一つ前のフレーズから再生（文脈を思い出す余白）
  void _resumeAllConversation(List<ConversationUtterance> utterances) {
    final startIndex = _currentUtteranceIndex > 0 ? _currentUtteranceIndex - 1 : 0;
    _playAllConversation(utterances, showPromptOnComplete: true, startIndex: startIndex);
  }

  /// 役モード時は音のみを原則。テキストは「どうしても」の場合のみ
  bool _canShowText(ConversationUtterance utterance) {
    if (_mode == 'roleA' || _mode == 'roleB') {
      return _revealedTextInRoleMode.contains(utterance.id);
    }
    return _showAllTexts || _textVisibleMap[utterance.id] == true;
  }

  bool _isMyRole(ConversationUtterance utterance) {
    return _mode == 'roleA' && utterance.speakerRole == 'A' ||
        _mode == 'roleB' && utterance.speakerRole == 'B';
  }

  void _showNextActionDialog(List<ConversationUtterance> utterances) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _playAllConversation(utterances);
                  },
                  icon: const Icon(Icons.replay, size: 20),
                  label: const Text('もう一度全体を聴く'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EngrowthColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _startRolePractice('roleA', utterances);
                  },
                  icon: const Icon(Icons.person, size: 18),
                  label: const Text('A役でトレーニング'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: EngrowthColors.roleA),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _startRolePractice('roleB', utterances);
                  },
                  icon: const Icon(Icons.person_outline, size: 18),
                  label: const Text('B役でトレーニング'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: EngrowthColors.roleB),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Text(
                  'タップして閉じる',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startRolePractice(String role, List<ConversationUtterance> utterances) async {
    if (!_hasListenedToAll) return;
    if (_isPlaying || _isCountdownActive) return;

    setState(() {
      _mode = role;
      _textVisibleMap.clear();
      _revealedTextInRoleMode.clear();
    });
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _learningEvents.logRoleStarted(
        userId: userId,
        conversationId: widget.conversationId,
        sessionId: _sessionId,
        role: role == 'roleA' ? 'A' : 'B',
      );
    }

    setState(() => _isCountdownActive = true);

    // 3秒カウントダウン
    for (var i = 3; i >= 1; i--) {
      if (!mounted) return;
      setState(() => _countdownValue = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    if (!mounted) return;
    setState(() => _isCountdownActive = false);

    // 最初の発話（index 0）が自分の番か相手の番かで分岐
    setState(() => _currentUtteranceIndex = 0);
    final first = utterances[0];
    if (_isMyRole(first)) {
      // 自分の番から開始 → 即座に録音待機（A役で最初がA、B役で最初がB のとき）
    } else {
      // 相手の番から開始 → TTS再生後に自動で自分の録音待機へ
      _playOpponentAndScheduleAdvance(utterances, 0);
    }
  }

  /// ④英語ボタン用：全文トランスクリプト（EN+JP）＋フレーズ飛び＋再生（メイン画面と同期）
  void _showEnglishTranscriptSheet(List<ConversationUtterance> utterances) {
    _transcriptCurrentIndexNotifier?.dispose();
    _transcriptIsPlayingNotifier?.dispose();
    _transcriptCurrentIndexNotifier = ValueNotifier<int>(_currentUtteranceIndex);
    _transcriptIsPlayingNotifier = ValueNotifier<bool>(_isPlaying);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      enableDrag: true,
      builder: (ctx) {
        final screenH = MediaQuery.of(ctx).size.height;
        final barrierHeight = screenH * 0.28;  // シート上の余白（外側タップ領域）
        return Stack(
          children: [
            // シート本体（下に配置）
            Positioned.fill(
              child: _buildEnglishTranscriptSheet(
                ctx,
                utterances,
                _transcriptCurrentIndexNotifier!,
                _transcriptIsPlayingNotifier!,
                (index) {
                  setState(() => _currentUtteranceIndex = index);
                  _transcriptCurrentIndexNotifier?.value = index;
                  _playUtterance(utterances[index]);  // タップしたフレーズを再生
                },
                _stopPlayback,
                () => _resumeAllConversation(utterances),
                () => _playAllConversation(utterances, showPromptOnComplete: false),
                _hasListenedToAll,
              ),
            ),
            // 外側タップで閉じる（シートの上・背景部分を手前に配置）
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: barrierHeight,
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      _transcriptCurrentIndexNotifier?.dispose();
      _transcriptCurrentIndexNotifier = null;
      _transcriptIsPlayingNotifier?.dispose();
      _transcriptIsPlayingNotifier = null;
    });
    // 最初から聴く場合のみ自動再生（途中停止後の再開時はボタンで続きを聴く）
    if (_currentUtteranceIndex == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playAllConversation(utterances, showPromptOnComplete: false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationAsync = ref.watch(conversationWithUtterancesProvider(widget.conversationId));

    return Scaffold(
      body: conversationAsync.when(
        data: (data) => _buildBody(context, data.conversation, data.utterances),
        loading: () => _buildLoading(context),
        error: (error, stack) => _buildError(context, error),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Conversation conversation, List<ConversationUtterance> utterances) {
    if (utterances.isEmpty) {
      return _buildEmpty(context);
    }

    final currentUtterance = utterances[_currentUtteranceIndex];
    final canShowText = _canShowText(currentUtterance);
    final total = utterances.length;

    return Stack(
      children: [
        // 背景画像（thumbnail_urlがあれば会話に合わせた画像、なければデフォルト）
        Positioned.fill(
          child: conversation.thumbnailUrl != null
              ? OptimizedImage(
                  imageUrl: conversation.thumbnailUrl!,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  kScenarioBgAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                ),
        ),
        // 暗いオーバーレイ（テキスト可読性向上）
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
        ),
        // 3秒カウントダウンオーバーレイ
        if (_isCountdownActive)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_countdownValue',
                        style: TextStyle(
                          fontSize: 120,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '準備してください...',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // コンテンツ
        SafeArea(
          child: Column(
            children: [
              // AppBar + プログレスバー（アニメーション付き）
              _buildAppBar(context, conversation.title),
              _buildProgressBar(total),
              // 中央：現在の発話のみ表示（スクロール不要）
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildCurrentUtteranceCard(
                      currentUtterance,
                      canShowText,
                      utterances.length,
                      _currentUtteranceIndex + 1,
                    ),
                  ),
                ),
              ),
              // 固定ボタンエリア
              _buildBottomButtons(context, utterances, currentUtterance, canShowText),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, String conversationTitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => context.pop(),
            tooltip: '終了',
            style: IconButton.styleFrom(
              backgroundColor: Colors.black26,
            ),
          ),
          if (_mode == 'roleA' || _mode == 'roleB') ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _mode == 'roleA' ? EngrowthColors.roleA : EngrowthColors.roleB,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_mode == 'roleA' ? Icons.person : Icons.person_outline, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _mode == 'roleA' ? 'A役で練習中' : 'B役で練習中',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
          Expanded(
            child: Text(
              conversationTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          // 役モードでは音のみ学習のためテキスト表示は下部のフォールバックのみ
          if (_mode == 'listen')
            IconButton(
              icon: Icon(
                _showAllTexts ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: () => setState(() => _showAllTexts = !_showAllTexts),
              tooltip: '全テキスト表示',
              style: IconButton.styleFrom(
                backgroundColor: Colors.black26,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int totalUtterances) {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, _) {
        // 再生中はフレーズ内でゆっくり進行、非再生時は現在位置で固定
        final phraseProgress = _isPlaying ? _progressController.value : 1.0;
        final progress = totalUtterances > 1
            ? ((_currentUtteranceIndex + phraseProgress) / totalUtterances).clamp(0.0, 1.0)
            : 1.0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '会話の進行',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(_currentUtteranceIndex + 1).toString().padLeft(2)} / $totalUtterances',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isPlaying ? EngrowthColors.primary : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentUtteranceCard(
    ConversationUtterance utterance,
    bool canShowText,
    int total,
    int current,
  ) {
    final roleColor = _getSpeakerColor(utterance.speakerRole);
    final roleLabel = utterance.speakerRole == 'A' ? 'A（お客様）' : utterance.speakerRole == 'B' ? 'B（店員）' : utterance.speakerRole;

    // 音声未再生時は最小限のUI（役バッジのみ）で画像を最大限見せる
    if (!canShowText) {
      final isMyRole = _isMyRole(utterance);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  roleLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (_isPlaying) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: EngrowthColors.primary.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.graphic_eq, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '再生中',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
          if (isMyRole && (_mode == 'roleA' || _mode == 'roleB')) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: EngrowthColors.primary.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EngrowthColors.primary.withOpacity(0.6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic, color: EngrowthColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'あなたのセリフ。録音して言いましょう',
                    style: TextStyle(
                      color: EngrowthColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }

    // テキスト表示時は従来のカード
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: _isPlaying
                ? Border.all(
                    color: EngrowthColors.primary.withOpacity(0.3 + _pulseController.value * 0.4),
                    width: 3,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: _isPlaying ? EngrowthColors.primary.withOpacity(0.3) : Colors.black26,
                blurRadius: _isPlaying ? 16 : 8,
                spreadRadius: _isPlaying ? 2 : 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: roleColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: roleColor.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      roleLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_isPlaying)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.graphic_eq, color: EngrowthColors.primary, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '再生中',
                          style: TextStyle(
                            color: EngrowthColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (_isMyRole(utterance))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: EngrowthColors.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: EngrowthColors.primary.withOpacity(0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic, color: EngrowthColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'あなたのセリフです。録音して練習しましょう',
                          style: TextStyle(color: EngrowthColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                utterance.englishText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              if (utterance.japaneseText.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  utterance.japaneseText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRolePracticeButtons(BuildContext context, List<ConversationUtterance> utterances) {
    final canStart = _hasListenedToAll && !_isPlaying && !_isCountdownActive;
    void onTapLocked() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('まず会話全体を聴いてから練習しましょう'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Opacity(
            opacity: canStart ? 1.0 : 0.5,
            child: OutlinedButton.icon(
              onPressed: canStart
                  ? () => _startRolePractice('roleA', utterances)
                  : onTapLocked,
              icon: Icon(canStart ? Icons.person : Icons.lock_outline, size: 18),
              label: const Text('A役で練習', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: canStart ? Colors.white : Colors.grey[400],
                side: BorderSide(
                  color: canStart ? EngrowthColors.roleA : Colors.grey,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Opacity(
            opacity: canStart ? 1.0 : 0.5,
            child: OutlinedButton.icon(
              onPressed: canStart
                  ? () => _startRolePractice('roleB', utterances)
                  : onTapLocked,
              icon: Icon(canStart ? Icons.person_outline : Icons.lock_outline, size: 18),
              label: const Text('B役で練習', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: canStart ? Colors.white : Colors.grey[400],
                side: BorderSide(
                  color: canStart ? EngrowthColors.roleB : Colors.grey,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListenAllButton(List<ConversationUtterance> utterances) {
    final isStoppedMidway = !_hasListenedToAll && _currentUtteranceIndex > 0 && !_isPlaying;
    final isCompleted = _hasListenedToAll && !_isPlaying;

    String label;
    VoidCallback? onPressed;
    IconData icon = Icons.play_circle_filled;

    if (_isPlaying) {
      label = '再生中...';
      onPressed = null;
      icon = Icons.graphic_eq;
    } else if (isCompleted) {
      label = '最初から聴き直す';
      onPressed = () => _playAllConversation(utterances);
    } else if (isStoppedMidway) {
      label = '続きを聴く（一つ前のフレーズから）';
      onPressed = () => _resumeAllConversation(utterances);
    } else {
      label = '会話全体を聴く';
      onPressed = () => _playAllConversation(utterances);
    }

    return Row(
      children: [
        if (_isPlaying) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _stopPlayback,
              icon: const Icon(Icons.stop, size: 22),
              label: const Text('停止'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: _isPlaying ? 1 : 2,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 24),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isPlaying ? Colors.grey : EngrowthColors.primary,
              foregroundColor: EngrowthColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(
    BuildContext context,
    List<ConversationUtterance> utterances,
    ConversationUtterance currentUtterance,
    bool canShowText,
  ) {
    return BottomInteractionBar(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.6),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 役モード：音のみ案内（テキスト非表示が原則）
          if (!canShowText && (_mode == 'roleA' || _mode == 'roleB'))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hearing, color: Colors.white70, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          _isMyRole(currentUtterance)
                              ? '音を思い出して、録音して言いましょう'
                              : '相手のセリフを聞き取りましょう',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _revealedTextInRoleMode.add(currentUtterance.id));
                    },
                    icon: Icon(Icons.visibility_outlined, size: 16, color: Colors.white54),
                    label: Text(
                      'どうしてもわからないときはテキストを表示',
                      style: TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ),
          // 聞き流しモード：「音声を再生すると～」
          if (!canShowText && _mode == 'listen')
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.volume_up, color: Colors.white70, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      '音声で会話の流れを把握しましょう',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // 会話全体を聴く（状況に応じてボタン文言・動作を切り替え）
          _buildListenAllButton(utterances),
          const SizedBox(height: 12),
          // ①会話全体を聞いていない場合は案内
          if (!_hasListenedToAll)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber[200], size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'まず「会話全体を聞く」で会話を聴いてください',
                      style: TextStyle(color: Colors.amber[100], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          // A役/B役として練習（未完了時は半透明でロック表示、タップでスナックバー）
          _buildRolePracticeButtons(context, utterances),
          const SizedBox(height: 12),
          // 現在の発話のみ再生 + 前へ/次へ
          Row(
            children: [
              // 現在の発話を再生
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: _isPlaying ? null : () => _playUtterance(currentUtterance),
                  icon: _isPlaying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.volume_up, size: 20),
                  label: const Text('この発話を再生'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 前へ
              Expanded(
                child: IconButton.filled(
                  onPressed: _currentUtteranceIndex > 0
                      ? () => _advancePrev(utterances)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 次へ（自動進行中でも手動でスキップ可能）
              Expanded(
                child: IconButton.filled(
                  onPressed: _currentUtteranceIndex < utterances.length - 1
                      ? () => _advanceNext(utterances)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                  ),
                ),
              ),
            ],
          ),
          // 録音・聴き直し・先生に送る（会話トレーニング用）
          const SizedBox(height: 12),
          // 役モードで自分のターン時：録音完了後に自動進行（1.2秒）
          if (_autoAdvanceSecondsRemaining != null && (_mode == 'roleA' || _mode == 'roleB'))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: EngrowthColors.primary.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: EngrowthColors.primary.withOpacity(0.6)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer, color: EngrowthColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '$_autoAdvanceSecondsRemaining秒後に次へ',
                      style: TextStyle(
                        color: EngrowthColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'タップでスキップ',
                      style: TextStyle(
                        color: EngrowthColors.primary.withOpacity(0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          AudioControls(
            englishText: currentUtterance.englishText,
            japaneseText: currentUtterance.japaneseText,
            conversationId: widget.conversationId,
            utteranceId: currentUtterance.id,
            sessionId: _sessionId,
            useDarkTheme: true,
            hideJapaneseButton: true,
            onPlayFullEnglish: () => _showEnglishTranscriptSheet(utterances),
            onRecordingComplete: (_mode == 'roleA' || _mode == 'roleB') && _isMyRole(currentUtterance)
                ? () => _scheduleAdvanceAfterRecording(utterances)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(kScenarioBgAsset, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[300])),
        ),
        const Center(child: CircularProgressIndicator(color: Colors.white)),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(kScenarioBgAsset, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[300])),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.white70),
              const SizedBox(height: 16),
              Text('会話の発話が登録されていません', style: TextStyle(fontSize: 16, color: Colors.white70)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnglishTranscriptSheet(
    BuildContext ctx,
    List<ConversationUtterance> utterances,
    ValueNotifier<int> currentIndexNotifier,
    ValueNotifier<bool> isPlayingNotifier,
    void Function(int) onJumpTo,
    VoidCallback onStop,
    VoidCallback onResume,
    VoidCallback onPlayFromStart,
    bool hasListenedToAll,
  ) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => ValueListenableBuilder<bool>(
        valueListenable: isPlayingNotifier,
        builder: (context, isPlaying, __) {
          return ValueListenableBuilder<int>(
            valueListenable: currentIndexNotifier,
            builder: (context, currentIndex, _) {
              // 再生中のフレーズが画面内に収まるようスクロール
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (scrollController.hasClients && currentIndex < utterances.length) {
                  const approxItemHeight = 110.0;
                  final targetOffset = (currentIndex * approxItemHeight)
                      .clamp(0.0, scrollController.position.maxScrollExtent);
                  scrollController.animateTo(
                    targetOffset,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                }
              });

              final showResumeButton = !isPlaying && currentIndex > 0 && !hasListenedToAll;
              final showPlayFromStartButton = !isPlaying && (currentIndex == 0 || hasListenedToAll);

              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        children: [
                          if (isPlaying)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: onStop,
                                icon: const Icon(Icons.stop, size: 22),
                                label: const Text('再生を停止'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: EngrowthColors.primary,
                                  side: BorderSide(color: EngrowthColors.primary),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            )
                          else if (showResumeButton)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: onResume,
                                icon: const Icon(Icons.play_arrow, size: 22),
                                label: const Text('続きを聴く（一つ前のフレーズから）'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: EngrowthColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            )
                          else if (showPlayFromStartButton)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: onPlayFromStart,
                                icon: const Icon(Icons.play_circle_filled, size: 22),
                                label: Text(hasListenedToAll ? '最初から聴き直す' : '会話全体を聴く'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: EngrowthColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: utterances.length,
                itemBuilder: (context, i) {
                  final u = utterances[i];
                  final roleLabel = u.speakerRole == 'A' ? 'A（お客様）' : u.speakerRole == 'B' ? 'B（店員）' : u.speakerRole;
                  final isCurrent = i == currentIndex;  // 再生中のフレーズと同期
                  return InkWell(
                    onTap: () => onJumpTo(i),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? EngrowthColors.primary.withOpacity(0.1)
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent ? EngrowthColors.primary : Colors.grey[200]!,
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getSpeakerColor(u.speakerRole),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  roleLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.volume_up, size: 14, color: EngrowthColors.primary),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            u.englishText,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isCurrent ? EngrowthColors.primary : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            u.japaneseText,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
            },
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('エラー: $error'),
        ],
      ),
    );
  }

  Color _getSpeakerColor(String role) {
    switch (role) {
      case 'A':
        return EngrowthColors.roleA;  // お客様
      case 'B':
        return EngrowthColors.roleB;  // 店員
      case 'C':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
