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
}
