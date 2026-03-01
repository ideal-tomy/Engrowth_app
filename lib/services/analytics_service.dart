import 'package:supabase_flutter/supabase_flutter.dart';

/// KPI計測用イベント送信
/// D1/D7継続率、匿名→会員CVR、デイリーミッション達成率等の算出に使用
class AnalyticsService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> logEvent({
    required String eventType,
    Map<String, dynamic>? eventProperties,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      await _client.from('analytics_events').insert({
        'user_id': userId,
        'event_type': eventType,
        'event_properties': eventProperties ?? {},
      });
    } catch (_) {
      // テーブル未作成や権限エラー時は無視
    }
  }

  void logStudyStart() => logEvent(eventType: 'study_start');
  void logStudyComplete({int? masteredCount}) =>
      logEvent(eventType: 'study_complete', eventProperties: {'mastered': masteredCount});
  void logMissionComplete() => logEvent(eventType: 'mission_complete');
  void logVoiceSubmit() => logEvent(eventType: 'voice_submit');
  void logSignUp() => logEvent(eventType: 'signup');
  void logCoachingStart() => logEvent(eventType: 'coaching_start');
  void logAppOpen() => logEvent(eventType: 'app_open');

  // UX強化プラン用イベント
  void logSessionStart({String? sessionMode}) =>
      logEvent(eventType: 'session_start', eventProperties: {'session_mode': sessionMode});
  void logQuick30Complete({int? count}) =>
      logEvent(eventType: 'quick30_complete', eventProperties: {'count': count});
  void logFocus3Complete({int? count}) =>
      logEvent(eventType: 'focus3_complete', eventProperties: {'count': count});
  void logVoiceAttempt() =>
      logEvent(eventType: 'voice_attempt');
  void logAudioComparePlayed() =>
      logEvent(eventType: 'audio_compare_played');
  void logHintAutoShown({String? phase}) =>
      logEvent(eventType: 'hint_auto_shown', eventProperties: {'phase': phase});
  void logResumeCardTap({String? source}) =>
      logEvent(eventType: 'resume_card_tap', eventProperties: {'source': source});
  void logStoryResumeTap({String? storyId}) =>
      logEvent(eventType: 'story_resume_tap', eventProperties: {'story_id': storyId});
  void logNextTaskAccepted({String? nextType}) =>
      logEvent(eventType: 'next_task_accepted', eventProperties: {'next_type': nextType});

  // 匿名→登録導線
  void logAnonPromptShown() => logEvent(eventType: 'anon_prompt_shown');
  void logAnonPromptCtaGoogle() => logEvent(eventType: 'anon_prompt_cta_google');
  void logAnonPromptCtaEmail() => logEvent(eventType: 'anon_prompt_cta_email');
  void logAnonPromptDismissed() => logEvent(eventType: 'anon_prompt_dismissed');
  void logAnonToRegisteredSuccess() =>
      logEvent(eventType: 'anon_to_registered_success');

  // 上質化UIUX追加
  void logUiSnapUsed({String? section}) =>
      logEvent(eventType: 'ui_snap_used', eventProperties: {'section': section});
  void logHapticFired({String? trigger}) =>
      logEvent(eventType: 'haptic_fired', eventProperties: {'trigger': trigger});
  void logLottieShown({String? scene}) =>
      logEvent(eventType: 'lottie_shown', eventProperties: {'scene': scene});
  void logSituationAmbienceTrigger({String? storyId, String? theme}) => logEvent(
      eventType: 'situation_ambience_trigger',
      eventProperties: {'story_id': storyId, 'theme': theme});

  // すごろく進捗UI
  void logProgressBoardOpened({String? track}) =>
      logEvent(eventType: 'progress_board_opened', eventProperties: {'track': track});
  void logProgressNodeTapped({String? nodeId, String? track}) => logEvent(
      eventType: 'progress_node_tapped',
      eventProperties: {'node_id': nodeId, 'track': track});
  void logProgressPopupShown({String? reason, String? track}) => logEvent(
      eventType: 'progress_popup_shown',
      eventProperties: {'reason': reason, 'track': track});
  void logProgressPopupCtaContinue({String? track}) => logEvent(
      eventType: 'progress_popup_cta_continue', eventProperties: {'track': track});
  void logProgressPopupCtaViewBoard({String? track}) => logEvent(
      eventType: 'progress_popup_cta_view_board', eventProperties: {'track': track});

  // 匿名保存訴求
  void logAnonSaveNudgeShown({String? source}) =>
      logEvent(eventType: 'anon_save_nudge_shown', eventProperties: {'source': source});
  void logAnonSaveNudgeCta({String? source}) =>
      logEvent(eventType: 'anon_save_nudge_cta', eventProperties: {'source': source});

  // TTS 低遅延化・運用計測（Phase 6）
  void logTtsRequest({
    required int latencyMs,
    bool? cacheHit,
    String? sessionId,
    String? source,
  }) =>
      logEvent(
        eventType: 'tts_request',
        eventProperties: {
          'latency_ms': latencyMs,
          'cache_hit': cacheHit,
          if (sessionId != null) 'tts_session_id': sessionId,
          if (source != null) 'tts_source': source,
        },
      );
  void logTtsFallback({String? reason}) =>
      logEvent(eventType: 'tts_fallback', eventProperties: {'reason': reason});
  void logTtsCancel() => logEvent(eventType: 'tts_cancel');

  // 会話ループKPI（AI会話モード）
  void logConversationTurnCompleted({
    required String conversationId,
    required int turnCount,
  }) =>
      logEvent(
        eventType: 'conversation_turn_completed',
        eventProperties: {
          'conversation_id': conversationId,
          'turn_count': turnCount,
        },
      );
  void logSttFailed({String? reason}) =>
      logEvent(eventType: 'stt_failed', eventProperties: {'reason': reason});
  void logReplyLatency({required int latencyMs}) =>
      logEvent(
        eventType: 'reply_latency_ms',
        eventProperties: {'latency_ms': latencyMs},
      );
  void logSessionDropReason({String? reason}) =>
      logEvent(
        eventType: 'session_drop_reason',
        eventProperties: {'reason': reason},
      );

  // 初回体験・日課提出KPI（初回完了率・提出率・D1継続率算出用）
  void logOnboardingStarted({String? step}) =>
      logEvent(eventType: 'onboarding_started', eventProperties: {'step': step});
  void logOnboardingStepCompleted({required String step, int? index}) =>
      logEvent(
        eventType: 'onboarding_step_completed',
        eventProperties: {'step': step, if (index != null) 'step_index': index},
      );
  void logOnboardingCompleted() => logEvent(eventType: 'onboarding_completed');
  void logOnboardingSkipped({String? atStep}) =>
      logEvent(eventType: 'onboarding_skipped', eventProperties: {'at_step': atStep});
  void logDailyReportRecorded() => logEvent(eventType: 'daily_report_recorded');
  void logDailyReportSubmitted() => logEvent(eventType: 'daily_report_submitted');
  void logDailyReportCardShown({String? status}) =>
      logEvent(eventType: 'daily_report_card_shown', eventProperties: {'status': status});

  /// TTS 会話再生セッション計測（Phase 1: 症状時のボトルネック特定用）
  void logTtsPlaybackSession({
    required String conversationId,
    required int utteranceCount,
    required bool firstUtterancePrefetched,
    required int prefetchHitCount,
    required int prefetchMissCount,
    int? tapToFirstAudioMs,
    int? avgUtteranceGapMs,
    int? maxUtteranceGapMs,
    int? first5PrefetchHitCount,
    int? flutterFallbackCount,
  }) =>
      logEvent(
        eventType: 'tts_playback_session',
        eventProperties: {
          'conversation_id': conversationId,
          'utterance_count': utteranceCount,
          'first_utterance_prefetched': firstUtterancePrefetched,
          'prefetch_hit_count': prefetchHitCount,
          'prefetch_miss_count': prefetchMissCount,
          if (tapToFirstAudioMs != null) 'tap_to_first_audio_ms': tapToFirstAudioMs,
          if (avgUtteranceGapMs != null) 'utterance_gap_avg_ms': avgUtteranceGapMs,
          if (maxUtteranceGapMs != null) 'utterance_gap_max_ms': maxUtteranceGapMs,
          if (first5PrefetchHitCount != null)
            'first_5_prefetch_hit_count': first5PrefetchHitCount,
          if (flutterFallbackCount != null)
            'flutter_fallback_count': flutterFallbackCount,
        },
      );
}
