import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation.dart';
import '../providers/conversation_provider.dart';
import '../services/tts_service.dart';
import '../services/voice_playback_service.dart';

import '../theme/engrowth_theme.dart';
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
  bool _isPlaying = false;
  Map<String, bool> _textVisibleMap = {};
  bool _showAllTexts = false;
  String _mode = 'listen';  // listen, roleA, roleB
  late AnimationController _pulseController;
  late AnimationController _progressController;  // フレーズ内のゆっくりとした進行用

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
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
    _pulseController.dispose();
    _progressController.dispose();
    _ttsService.dispose();
    super.dispose();
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
      setState(() => _textVisibleMap[utterance.id] = true);
    }
  }

  Future<void> _playAllConversation(List<ConversationUtterance> utterances) async {
    if (_isPlaying) return;

    setState(() => _isPlaying = true);

    for (var i = 0; i < utterances.length; i++) {
      if (!mounted) break;

      final utterance = utterances[i];
      setState(() => _currentUtteranceIndex = i);

      // プログレスバーをゆっくり進行させる（フレーズ再生中）
      _progressController.forward(from: 0);

      final speakFuture = _ttsService.speakEnglish(utterance.englishText);

      // 再生が終わったらプログレスを完了位置に
      speakFuture.whenComplete(() {
        if (mounted) _progressController.value = 1.0;
      });

      await speakFuture;

      if (!mounted) break;

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null && _sessionId != null) {
        await _playbackService.recordPlayback(
          userId: userId,
          conversationId: widget.conversationId,
          utteranceId: utterance.id,
          sessionId: _sessionId!,
          playbackType: 'tts',
        );
        setState(() => _textVisibleMap[utterance.id] = true);
      }

      if (i < utterances.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    if (mounted) {
      setState(() => _isPlaying = false);
    }
  }

  bool _canShowText(ConversationUtterance utterance) {
    return _showAllTexts || _textVisibleMap[utterance.id] == true;
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
        // 背景画像（全シチュエーションで仮設定）
        Positioned.fill(
            child: Image.asset(
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
        // コンテンツ
        SafeArea(
          child: Column(
            children: [
              // AppBar + プログレスバー（アニメーション付き）
              _buildAppBar(context),
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

  Widget _buildAppBar(BuildContext context) {
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
          const Spacer(),
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
      return Row(
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

  Widget _buildBottomButtons(
    BuildContext context,
    List<ConversationUtterance> utterances,
    ConversationUtterance currentUtterance,
    bool canShowText,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.6),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 「音声を再生すると～」を会話全体を聞くの直上に配置
          if (!canShowText)
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
                      '音声を再生するとテキストが表示されます',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // 会話全体を聞く
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isPlaying ? null : () => _playAllConversation(utterances),
              icon: Icon(_isPlaying ? Icons.hourglass_empty : Icons.play_circle_filled, size: 24),
              label: Text(_isPlaying ? '再生中...' : '会話全体を聞く'),
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
          const SizedBox(height: 12),
          // A役/B役として再度挑戦（聞き流し後の発話学習へスムーズに移行）
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _mode = 'roleA';
                      _currentUtteranceIndex = 0;
                      _textVisibleMap.clear();
                    });
                  },
                  icon: const Icon(Icons.person, size: 18),
                  label: const Text('A役として再度挑戦', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: EngrowthColors.roleA),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _mode = 'roleB';
                      _currentUtteranceIndex = 0;
                      _textVisibleMap.clear();
                    });
                  },
                  icon: const Icon(Icons.person_outline, size: 18),
                  label: const Text('B役として再度挑戦', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: EngrowthColors.roleB),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
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
                      ? () => setState(() => _currentUtteranceIndex--)
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
              // 次へ
              Expanded(
                child: IconButton.filled(
                  onPressed: _currentUtteranceIndex < utterances.length - 1
                      ? () => setState(() => _currentUtteranceIndex++)
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
