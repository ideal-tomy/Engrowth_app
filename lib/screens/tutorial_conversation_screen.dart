import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/tutorial.dart';
import '../providers/analytics_provider.dart';
import '../providers/tutorial_provider.dart';
import '../services/recording_service.dart';
import '../services/recording_consent_service.dart';
import '../services/stt_service.dart';
import '../services/tts_service.dart';
import '../theme/engrowth_theme.dart';
import '../utils/tutorial_intent_resolver.dart';

/// 事前生成チュートリアル会話画面
/// 聞く→話す→返答を低遅延で体験
class TutorialConversationScreen extends ConsumerStatefulWidget {
  const TutorialConversationScreen({super.key});

  @override
  ConsumerState<TutorialConversationScreen> createState() =>
      _TutorialConversationScreenState();
}

class _TutorialConversationScreenState
    extends ConsumerState<TutorialConversationScreen> {
  final TtsService _ttsService = TtsService();
  final RecordingService _recordingService = RecordingService();
  final SttService _sttService = SttService();

  TutorialStep? _currentStep;
  bool _isPlaying = false;
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _statusMessage;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
  }

  @override
  void dispose() {
    _recordingService.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  Future<void> _playPromptOrResponse(
    String textEn, {
    String? audioUrl,
  }) async {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);
    try {
      if (audioUrl != null && audioUrl.isNotEmpty) {
        await _ttsService.speakEnglish(textEn, prefetchedUrl: audioUrl);
      } else {
        await _ttsService.speakEnglish(textEn);
      }
    } finally {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  Future<void> _enterStep(TutorialSession session, TutorialStep step) async {
    setState(() {
      _currentStep = step;
      _statusMessage = null;
    });
    ref.read(analyticsServiceProvider).logTutorialStepStarted(
          stepId: step.id,
          stepOrder: step.stepOrder,
        );
    await _playPromptOrResponse(
      step.promptTextEn,
      audioUrl: step.promptAudioUrl,
    );
    if (!mounted) return;
    setState(() => _statusMessage = 'マイクボタンを押して話してください');
  }

  Future<void> _handleRecordingComplete(
    File file,
    TutorialSession session,
  ) async {
    if (!mounted || _currentStep == null) return;
    setState(() {
      _isProcessing = true;
      _statusMessage = '聞き取っています...';
    });

    try {
      final transcript = await _sttService.transcribeFile(file);
      final intent = TutorialIntentResolver.resolveIntent(transcript);
      final usedFallback = intent == TutorialIntentResolver.unknown;

      if (usedFallback) {
        ref.read(analyticsServiceProvider).logTutorialFallbackUsed(
              stepId: _currentStep!.id,
              sttText: transcript,
            );
      }

      final response = session.getResponseForIntent(_currentStep!.id, intent) ??
          session.getResponseForIntent(
            _currentStep!.id,
            TutorialIntentResolver.unknown,
          );

      if (response == null) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _statusMessage = 'もう一度話してみてください';
          });
        }
        return;
      }

      ref.read(analyticsServiceProvider).logTutorialStepCompleted(
            stepId: _currentStep!.id,
            intent: intent,
            usedFallback: usedFallback,
          );

      await _playPromptOrResponse(
        response.responseTextEn,
        audioUrl: response.responseAudioUrl,
      );
      if (!mounted) return;

      final nextStep = response.nextStepId != null
          ? session.getStepById(response.nextStepId!)
          : null;

      if (nextStep != null) {
        await _enterStep(session, nextStep);
      } else {
        ref.read(analyticsServiceProvider).logTutorialCompleted();
        if (mounted) {
          setState(() {
            _currentStep = null;
            _isProcessing = false;
            _statusMessage = '体験完了！';
          });
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) context.pop();
        }
        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラー: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() => _statusMessage = 'もう一度試してください');
      }
    }
    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _toggleRecord(TutorialSession session) async {
    if (_isProcessing || _currentStep == null) return;

    if (_isRecording) {
      final path = await _recordingService.stopRecording();
      setState(() => _isRecording = false);
      HapticFeedback.mediumImpact();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await _handleRecordingComplete(file, session);
        }
      }
    } else {
      final hasConsent = await RecordingConsentService.hasConsent();
      if (!hasConsent && mounted) {
        final ok = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('音声の記録について'),
            content: const Text(
              'チュートリアルのため、あなたの声を記録します。\n'
              '聞き取った内容に応じて返答を返します。',
              style: TextStyle(height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('キャンセル'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('同意する'),
              ),
            ],
          ),
        );
        if (ok == true) {
          await RecordingConsentService.setConsent(true);
        } else {
          return;
        }
      }
      try {
        await _recordingService.startRecording();
        setState(() {
          _isRecording = true;
          _statusMessage = '録音中... 話したら停止を押してください';
        });
        HapticFeedback.lightImpact();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().contains('Permission') || e.toString().contains('権限')
                    ? 'マイクの使用許可をください'
                    : '録音エラー: $e',
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(firstTutorialSessionProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('挨拶体験'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            HapticFeedback.selectionClick();
            context.pop();
          },
        ),
      ),
      body: sessionAsync.when(
        data: (session) {
          if (session == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'チュートリアルを読み込めませんでした',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('戻る'),
                  ),
                ],
              ),
            );
          }

          if (!_hasStarted && session.steps.isNotEmpty) {
            _hasStarted = true;
            ref.read(analyticsServiceProvider).logTutorialStarted();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _enterStep(session, session.steps.first);
            });
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  if (_currentStep != null) ...[
                    Text(
                      _currentStep!.promptTextEn,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    if (_currentStep!.promptTextJa != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _currentStep!.promptTextJa!,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                  const Spacer(),
                  if (_statusMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Center(
                    child: GestureDetector(
                      onTap: _isProcessing
                          ? null
                          : () => _toggleRecord(session),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording
                              ? EngrowthColors.error
                              : colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: (colorScheme.primary).withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: _isRecording ? 4 : 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isProcessing)
                    const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      ref.read(analyticsServiceProvider).logTutorialSkipped(
                            atStepId: _currentStep?.id,
                          );
                      context.pop();
                    },
                    child: const Text('スキップ'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('$err', style: TextStyle(color: colorScheme.error)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('戻る'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
