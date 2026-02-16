import 'package:supabase_flutter/supabase_flutter.dart';

/// 会話学習イベント記録サービス
/// 管理者ダッシュボードでの分析用
class ConversationLearningEventsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> _logEvent({
    required String userId,
    required String conversationId,
    String? sessionId,
    required String eventType,
    String? role,
  }) async {
    try {
      await _supabase.from('conversation_learning_events').insert({
        'user_id': userId,
        'conversation_id': conversationId,
        'session_id': sessionId,
        'event_type': eventType,
        'role': role,
      });
    } catch (e) {
      // エラー時も続行（イベント記録は補助機能）
      print('Error logging conversation learning event: $e');
    }
  }

  /// 会話全体を聴き終えた
  Future<void> logListenCompleted({
    required String userId,
    required String conversationId,
    String? sessionId,
  }) async {
    await _logEvent(
      userId: userId,
      conversationId: conversationId,
      sessionId: sessionId,
      eventType: 'listen_completed',
    );
  }

  /// 役トレーニングを開始
  Future<void> logRoleStarted({
    required String userId,
    required String conversationId,
    String? sessionId,
    required String role,
  }) async {
    await _logEvent(
      userId: userId,
      conversationId: conversationId,
      sessionId: sessionId,
      eventType: 'role_started',
      role: role,
    );
  }

  /// 役トレーニングを完了
  Future<void> logRoleCompleted({
    required String userId,
    required String conversationId,
    String? sessionId,
    required String role,
  }) async {
    await _logEvent(
      userId: userId,
      conversationId: conversationId,
      sessionId: sessionId,
      eventType: 'role_completed',
      role: role,
    );
  }

  /// 自動進行で次へ
  Future<void> logAutoAdvanceUsed({
    required String userId,
    required String conversationId,
    String? sessionId,
  }) async {
    await _logEvent(
      userId: userId,
      conversationId: conversationId,
      sessionId: sessionId,
      eventType: 'auto_advance_used',
    );
  }

  /// 手動「次へ」でスキップ
  Future<void> logManualNextUsed({
    required String userId,
    required String conversationId,
    String? sessionId,
  }) async {
    await _logEvent(
      userId: userId,
      conversationId: conversationId,
      sessionId: sessionId,
      eventType: 'manual_next_used',
    );
  }
}
