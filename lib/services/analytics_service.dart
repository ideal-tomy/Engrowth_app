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

  // B16: 再開先決定結果（resume / recommended_fallback / plain_fallback）
  void logResumeResolution({required String resolution}) =>
      logEvent(
        eventType: 'resume_resolution',
        eventProperties: {'resolution': resolution},
      );

  // ホーム QuickActionFAB 導線KPI
  void logHomeQuickFabOpened() =>
      logEvent(eventType: 'home_quick_fab_opened');
  void logHomeQuickActionTapped({required String actionType}) =>
      logEvent(
        eventType: 'home_quick_action_tapped',
        eventProperties: {'action_type': actionType},
      );

  // 起動時ショートカットポップアップ
  void logHomeShortcutPopupShown({
    required String source,
    bool? hasMission,
  }) =>
      logEvent(
        eventType: 'home_shortcut_popup_shown',
        eventProperties: {
          'source': source,
          if (hasMission != null) 'has_mission': hasMission,
        },
      );
  void logHomeShortcutPopupCtaTapped({
    required String route,
    required String source,
  }) =>
      logEvent(
        eventType: 'home_shortcut_popup_cta_tapped',
        eventProperties: {'route': route, 'source': source},
      );
  void logHomeShortcutPopupDismissed({String? reason}) =>
      logEvent(
        eventType: 'home_shortcut_popup_dismissed',
        eventProperties: {if (reason != null) 'reason': reason},
      );

  // パターンスプリントカテゴリ
  void logPatternSprintCategorySelected({
    required String categoryId,
    required String prefix,
  }) =>
      logEvent(
        eventType: 'pattern_sprint_category_selected',
        eventProperties: {'category_id': categoryId, 'prefix': prefix},
      );
  void logPatternSprintCategoryStarted({
    required String categoryId,
    required String prefix,
  }) =>
      logEvent(
        eventType: 'pattern_sprint_category_started',
        eventProperties: {'category_id': categoryId, 'prefix': prefix},
      );

  // パターンスプリント3段階練習
  void logPatternSprintPhaseStarted({
    required int phase,
    required int itemIndex,
  }) =>
      logEvent(
        eventType: 'pattern_sprint_phase_started',
        eventProperties: {'phase': phase, 'item_index': itemIndex},
      );
  void logPatternSprintPhaseCompleted({
    required int phase,
    required int itemIndex,
  }) =>
      logEvent(
        eventType: 'pattern_sprint_phase_completed',
        eventProperties: {'phase': phase, 'item_index': itemIndex},
      );
  void logPatternSprintShadowingGap({
    required int playMs,
    required int gapMs,
  }) =>
      logEvent(
        eventType: 'pattern_sprint_shadowing_gap_ms',
        eventProperties: {'play_ms': playMs, 'gap_ms': gapMs},
      );

  // B16: 学習初回コンテンツ表示（tap_to_first_content_ms で体感遅延を計測）
  void logStudyFirstContentRendered({
    String? entrySource,
    int? tapToFirstContentMs,
  }) =>
      logEvent(
        eventType: 'study_first_content_rendered',
        eventProperties: {
          if (entrySource != null) 'entry_source': entrySource,
          if (tapToFirstContentMs != null)
            'tap_to_first_content_ms': tapToFirstContentMs,
        },
      );
  void logStoryResumeTap({String? storyId}) =>
      logEvent(eventType: 'story_resume_tap', eventProperties: {'story_id': storyId});
  void logNextTaskAccepted({String? nextType}) =>
      logEvent(eventType: 'next_task_accepted', eventProperties: {'next_type': nextType});

  // B04/B05/B06: リザルト導線KPI（到達率・離脱率・遷移率算出用）
  void logResultShown({
    required String surface,
    required String flow,
    int? dwellMs,
  }) =>
      logEvent(
        eventType: 'result_shown',
        eventProperties: {
          'surface': surface,
          'flow': flow,
          if (dwellMs != null) 'dwell_ms': dwellMs,
        },
      );
  void logResultCtaTapped({
    required String surface,
    required String flow,
    required String cta,
  }) =>
      logEvent(
        eventType: 'result_cta_tapped',
        eventProperties: {
          'surface': surface,
          'flow': flow,
          'cta': cta,
        },
      );
  void logResultDismissed({
    required String surface,
    required String flow,
    String? reason,
  }) =>
      logEvent(
        eventType: 'result_dismissed',
        eventProperties: {
          'surface': surface,
          'flow': flow,
          if (reason != null) 'reason': reason,
        },
      );

  // B08: marquee_tap → 学習開始 到達率（tap_id で接続）
  void logLearningEntryStarted({
    required String learningMode,
    String? entrySource,
    String? tapId,
  }) =>
      logEvent(
        eventType: 'learning_entry_started',
        eventProperties: {
          'learning_mode': learningMode,
          if (entrySource != null) 'entry_source': entrySource,
          if (tapId != null) 'tap_id': tapId,
        },
      );

  // B07: MainTilesGrid 導線KPI
  void logMainTileTap({
    required String tileId,
    required String destination,
    String? authStage,
    int? rank,
  }) =>
      logEvent(
        eventType: 'main_tile_tap',
        eventProperties: {
          'tile_id': tileId,
          'destination': destination,
          if (authStage != null) 'auth_stage': authStage,
          if (rank != null) 'rank': rank,
        },
      );

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
    String? pathTaken,
    String? dbResult,
    int? dbElapsedMs,
    int? edgeElapsedMs,
    String? errorCode,
  }) =>
      logEvent(
        eventType: 'tts_request',
        eventProperties: {
          'latency_ms': latencyMs,
          'cache_hit': cacheHit,
          if (sessionId != null) 'tts_session_id': sessionId,
          if (source != null) 'tts_source': source,
          if (pathTaken != null) 'path_taken': pathTaken,
          if (dbResult != null) 'db_result': dbResult,
          if (dbElapsedMs != null) 'db_elapsed_ms': dbElapsedMs,
          if (edgeElapsedMs != null) 'edge_elapsed_ms': edgeElapsedMs,
          if (errorCode != null) 'error_code': errorCode,
        },
      );
  void logTtsFallback({
    String? reason,
    String? pathTaken,
    String? screen,
    bool? wasPrefetched,
    String? ttsSessionId,
  }) =>
      logEvent(
        eventType: 'tts_fallback',
        eventProperties: {
          if (reason != null) 'reason': reason,
          if (pathTaken != null) 'path_taken': pathTaken,
          if (screen != null) 'screen': screen,
          if (wasPrefetched != null) 'was_prefetched': wasPrefetched,
          if (ttsSessionId != null) 'tts_session_id': ttsSessionId,
        },
      );
  void logTtsWebPlayError({
    required String errorType,
    String? ttsSessionId,
    int? elapsedFromTapMs,
    String? urlHost,
  }) =>
      logEvent(
        eventType: 'tts_web_play_error',
        eventProperties: {
          'error_type': errorType,
          if (ttsSessionId != null) 'tts_session_id': ttsSessionId,
          if (elapsedFromTapMs != null) 'elapsed_from_tap_ms': elapsedFromTapMs,
          if (urlHost != null) 'url_host': urlHost,
        },
      );
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
  void logOnboardingStarted({String? step, String? variant}) => logEvent(
        eventType: 'onboarding_started',
        eventProperties: {
          if (step != null) 'step': step,
          if (variant != null) 'variant': variant,
        },
      );
  void logOnboardingStepCompleted({
    required String step,
    int? index,
    String? variant,
  }) =>
      logEvent(
        eventType: 'onboarding_step_completed',
        eventProperties: {
          'step': step,
          if (index != null) 'step_index': index,
          if (variant != null) 'variant': variant,
        },
      );
  void logOnboardingEntryTapped({String? variant}) => logEvent(
        eventType: 'onboarding_entry_tapped',
        eventProperties: {if (variant != null) 'variant': variant},
      );
  void logOnboardingCompleted({
    String? variant,
    String? nextRecommendedAction,
  }) =>
      logEvent(
        eventType: 'onboarding_completed',
        eventProperties: {
          if (variant != null) 'variant': variant,
          if (nextRecommendedAction != null)
            'next_recommended_action': nextRecommendedAction,
        },
      );
  void logOnboardingHomeHandoffShown() =>
      logEvent(eventType: 'onboarding_home_handoff_shown');
  void logOnboardingHomeHandoffTapped({String? target}) => logEvent(
        eventType: 'onboarding_home_handoff_tapped',
        eventProperties: {if (target != null) 'target': target},
      );
  void logOnboardingSkipped({String? atStep, String? variant}) => logEvent(
        eventType: 'onboarding_skipped',
        eventProperties: {
          if (atStep != null) 'at_step': atStep,
          if (variant != null) 'variant': variant,
        },
      );
  void logOnboardingMockSubmitStarted({String? variant}) => logEvent(
        eventType: 'onboarding_mock_submit_started',
        eventProperties: {
          if (variant != null) 'variant': variant,
        },
      );
  void logOnboardingMockSubmitCompleted({
    String? variant,
    bool? skippedEarly,
  }) =>
      logEvent(
        eventType: 'onboarding_mock_submit_completed',
        eventProperties: {
          if (variant != null) 'variant': variant,
          if (skippedEarly != null) 'skipped_early': skippedEarly,
        },
      );
  void logDailyReportRecorded() => logEvent(eventType: 'daily_report_recorded');
  void logDailyReportSubmitted() => logEvent(eventType: 'daily_report_submitted');
  void logDailyReportCardShown({String? status}) =>
      logEvent(eventType: 'daily_report_card_shown', eventProperties: {'status': status});

  // チュートリアル会話KPI（事前生成体験）
  void logTutorialStarted({String? entrySource}) => logEvent(
        eventType: 'tutorial_started',
        eventProperties: {if (entrySource != null) 'entry_source': entrySource},
      );
  void logTutorialLoadFailed({String? reason}) => logEvent(
        eventType: 'tutorial_load_failed',
        eventProperties: {if (reason != null) 'reason': reason},
      );
  void logTutorialStepStarted({required String stepId, required int stepOrder}) =>
      logEvent(
        eventType: 'tutorial_step_started',
        eventProperties: {'step_id': stepId, 'step_order': stepOrder},
      );
  void logTutorialStepCompleted({
    required String stepId,
    required String intent,
    bool? usedFallback,
  }) =>
      logEvent(
        eventType: 'tutorial_step_completed',
        eventProperties: {
          'step_id': stepId,
          'intent': intent,
          if (usedFallback != null) 'used_fallback': usedFallback,
        },
      );
  void logTutorialFallbackUsed({required String stepId, String? sttText}) =>
      logEvent(
        eventType: 'tutorial_fallback_used',
        eventProperties: {'step_id': stepId, if (sttText != null) 'stt_text': sttText},
      );
  void logTutorialCompleted() => logEvent(eventType: 'tutorial_completed');
  void logTutorialSkipped({String? atStepId}) =>
      logEvent(eventType: 'tutorial_skipped', eventProperties: {'at_step_id': atStepId});
  void logTutorialAutorecStarted({String? stepId}) =>
      logEvent(
        eventType: 'tutorial_autorec_started',
        eventProperties: {if (stepId != null) 'step_id': stepId},
      );
  void logTutorialStepAutoadvanced({
    required String stepType,
    String? targetId,
  }) =>
      logEvent(
        eventType: 'tutorial_step_autoadvanced',
        eventProperties: {
          'step_type': stepType,
          if (targetId != null) 'target_id': targetId,
        },
      );
  void logTutorialOneTapStartSuccess({
    required String learningMode,
    String? targetId,
  }) =>
      logEvent(
        eventType: 'tutorial_one_tap_start_success',
        eventProperties: {
          'learning_mode': learningMode,
          if (targetId != null) 'target_id': targetId,
        },
      );
  void logLearningHandoffShown({
    required String source,
    required String track,
    int? candidateCount,
  }) =>
      logEvent(
        eventType: 'learning_handoff_shown',
        eventProperties: {
          'source': source,
          'track': track,
          if (candidateCount != null) 'candidate_count': candidateCount,
        },
      );
  void logLearningResumeFromProgress({
    required String route,
    String? source,
  }) =>
      logEvent(
        eventType: 'learning_resume_from_progress',
        eventProperties: {
          'route': route,
          if (source != null) 'source': source,
        },
      );
  void logLearningHandoffAccepted({
    required String choice,
    String? track,
    String? targetRoute,
  }) =>
      logEvent(
        eventType: 'learning_handoff_accepted',
        eventProperties: {
          'choice': choice,
          if (track != null) 'track': track,
          if (targetRoute != null) 'target_route': targetRoute,
        },
      );
  void logHandoffQueueBlocked({String? reason}) => logEvent(
        eventType: 'handoff_queue_blocked',
        eventProperties: {if (reason != null) 'reason': reason},
      );
  void logTutorialAutoAdvanced({
    required String learningMode,
    required String fromStep,
    required String toStep,
    int? elapsedSec,
  }) =>
      logEvent(
        eventType: 'tutorial_auto_advanced',
        eventProperties: {
          'learning_mode': learningMode,
          'from_step': fromStep,
          'to_step': toStep,
          if (elapsedSec != null) 'elapsed_sec': elapsedSec,
        },
      );
  void logSubmissionCtaTap({
    required String surface,
    String? submissionId,
  }) =>
      logEvent(
        eventType: 'submission_cta_tap',
        eventProperties: {
          'surface': surface,
          if (submissionId != null) 'submission_id': submissionId,
        },
      );
  void logResultNextLearningTap({
    required String flow,
    String? targetRoute,
  }) =>
      logEvent(
        eventType: 'result_next_learning_tap',
        eventProperties: {
          'flow': flow,
          if (targetRoute != null) 'target_route': targetRoute,
        },
      );

  // B10: コンサルタント詳細ログドロワー
  void logConsultantDetailOpened({
    String? submissionId,
    bool? hasSessionData,
  }) =>
      logEvent(
        eventType: 'consultant_detail_opened',
        eventProperties: {
          if (submissionId != null) 'submission_id': submissionId,
          if (hasSessionData != null) 'has_session_data': hasSessionData,
        },
      );
  void logConsultantDetailClosed({String? submissionId}) =>
      logEvent(
        eventType: 'consultant_detail_closed',
        eventProperties: {
          if (submissionId != null) 'submission_id': submissionId,
        },
      );
  void logConsultantDetailError({
    required String reason,
    String? submissionId,
  }) =>
      logEvent(
        eventType: 'consultant_detail_error',
        eventProperties: {
          'reason': reason,
          if (submissionId != null) 'submission_id': submissionId,
        },
      );

  // B15: 担当コンサル連絡導線
  void logConsultantContactOpened({bool? hasConsultant}) =>
      logEvent(
        eventType: 'consultant_contact_opened',
        eventProperties: {
          if (hasConsultant != null) 'has_consultant': hasConsultant,
        },
      );
  void logConsultantContactChannelSelected({required String channel}) =>
      logEvent(
        eventType: 'consultant_contact_channel_selected',
        eventProperties: {'channel': channel},
      );
  void logConsultantContactMessageSent({
    required String channel,
    String? reportType,
  }) =>
      logEvent(
        eventType: 'consultant_contact_message_sent',
        eventProperties: {
          'channel': channel,
          if (reportType != null) 'report_type': reportType,
        },
      );
  void logConsultantContactMessageFailed({
    required String channel,
    required String reason,
  }) =>
      logEvent(
        eventType: 'consultant_contact_message_failed',
        eventProperties: {'channel': channel, 'reason': reason},
      );

  // B11: 課題発行
  void logMissionIssued({
    required String clientId,
    bool? hasPreset,
  }) =>
      logEvent(
        eventType: 'mission_issued',
        eventProperties: {
          'client_id': clientId,
          if (hasPreset != null) 'has_preset': hasPreset,
        },
      );
  void logMissionIssueFailed({required String reason}) =>
      logEvent(
        eventType: 'mission_issue_failed',
        eventProperties: {'reason': reason},
      );

  // B12: 管理者ダッシュボード閲覧
  void logAdminDashboardViewed({String? tab}) =>
      logEvent(
        eventType: 'admin_dashboard_viewed',
        eventProperties: {if (tab != null) 'tab': tab},
      );

  // B13: 権限付与・取り消し
  void logAdminPermissionGranted({
    required String consultantId,
    required String clientId,
  }) =>
      logEvent(
        eventType: 'admin_permission_granted',
        eventProperties: {
          'consultant_id': consultantId,
          'client_id': clientId,
        },
      );
  void logAdminPermissionRevoked({
    required String consultantId,
    required String clientId,
  }) =>
      logEvent(
        eventType: 'admin_permission_revoked',
        eventProperties: {
          'consultant_id': consultantId,
          'client_id': clientId,
        },
      );

  // 配信デモ表示
  void logAdminDeliveryDemoViewed({int? missionCount}) =>
      logEvent(
        eventType: 'admin_delivery_demo_viewed',
        eventProperties: {if (missionCount != null) 'mission_count': missionCount},
      );

  // Phase B: ふわっと表示統一の計測
  void logUiRevealStarted({
    required String screenName,
    String? surface,
    String? animationType,
  }) =>
      logEvent(
        eventType: 'ui_reveal_started',
        eventProperties: {
          'screen_name': screenName,
          if (surface != null) 'surface': surface,
          if (animationType != null) 'animation_type': animationType,
        },
      );
  void logUiRevealCompleted({
    required String screenName,
    String? surface,
    String? animationType,
    int? durationMs,
    int? delayMs,
  }) =>
      logEvent(
        eventType: 'ui_reveal_completed',
        eventProperties: {
          'screen_name': screenName,
          if (surface != null) 'surface': surface,
          if (animationType != null) 'animation_type': animationType,
          if (durationMs != null) 'duration_ms': durationMs,
          if (delayMs != null) 'delay_ms': delayMs,
        },
      );
  void logUiSwitcherTransition({
    required String screenName,
    String? surface,
    int? durationMs,
  }) =>
      logEvent(
        eventType: 'ui_switcher_transition',
        eventProperties: {
          'screen_name': screenName,
          if (surface != null) 'surface': surface,
          if (durationMs != null) 'duration_ms': durationMs,
        },
      );
  void logPrimaryCtaVisible({
    required String screenName,
    String? surface,
    String? variant,
  }) =>
      logEvent(
        eventType: 'primary_cta_visible',
        eventProperties: {
          'screen_name': screenName,
          if (surface != null) 'surface': surface,
          if (variant != null) 'variant': variant,
        },
      );
  void logPrimaryCtaTapped({
    required String screenName,
    String? surface,
    String? variant,
  }) =>
      logEvent(
        eventType: 'primary_cta_tapped',
        eventProperties: {
          'screen_name': screenName,
          if (surface != null) 'surface': surface,
          if (variant != null) 'variant': variant,
        },
      );

  // Motion Sync: 遷移完了・体感遅延・CTA到達率の before/after 比較用
  void logTransitionComplete({
    required int transitionCompleteMs,
    required String routeType,
    String? fromRoute,
    String? toRoute,
    String? variant,
  }) =>
      logEvent(
        eventType: 'transition_complete',
        eventProperties: {
          'transition_complete_ms': transitionCompleteMs,
          'route_type': routeType,
          if (fromRoute != null) 'from_route': fromRoute,
          if (toRoute != null) 'to_route': toRoute,
          if (variant != null) 'variant': variant,
        },
      );
  void logTapToFirstContent({
    required String screenName,
    required int tapToFirstContentMs,
    String? entrySource,
    String? variant,
  }) =>
      logEvent(
        eventType: 'tap_to_first_content',
        eventProperties: {
          'screen_name': screenName,
          'tap_to_first_content_ms': tapToFirstContentMs,
          if (entrySource != null) 'entry_source': entrySource,
          if (variant != null) 'variant': variant,
        },
      );

  // Speak風ガイドフロー計測
  void logGuidedFlowPopupShown({
    required String contentType,
    required String step,
    String? contentId,
  }) =>
      logEvent(
        eventType: 'guided_flow_popup_shown',
        eventProperties: {
          'content_type': contentType,
          'step': step,
          if (contentId != null) 'content_id': contentId,
        },
      );
  void logGuidedFlowPopupDismissed({
    required String contentType,
    required String step,
    String? reason,
  }) =>
      logEvent(
        eventType: 'guided_flow_popup_dismissed',
        eventProperties: {
          'content_type': contentType,
          'step': step,
          if (reason != null) 'reason': reason,
        },
      );
  void logGuidedFlowPlayRevealed({required String contentType, String? contentId}) =>
      logEvent(
        eventType: 'guided_flow_play_revealed',
        eventProperties: {
          'content_type': contentType,
          if (contentId != null) 'content_id': contentId,
        },
      );
  void logGuidedFlowFirstListenCompleted({
    required String contentType,
    required String contentId,
  }) =>
      logEvent(
        eventType: 'guided_flow_first_listen_completed',
        eventProperties: {
          'content_type': contentType,
          'content_id': contentId,
        },
      );

  // 統一ポップアップテンプレート計測
  void logEngrowthPopupShown({
    required String variant,
    String? sourceScreen,
  }) =>
      logEvent(
        eventType: 'engrowth_popup_shown',
        eventProperties: {
          'variant': variant,
          if (sourceScreen != null) 'source_screen': sourceScreen,
        },
      );

  void logEngrowthPopupDismissed({
    required String variant,
    String? dismissReason,
  }) =>
      logEvent(
        eventType: 'engrowth_popup_dismissed',
        eventProperties: {
          'variant': variant,
          if (dismissReason != null) 'dismiss_reason': dismissReason,
        },
      );

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
