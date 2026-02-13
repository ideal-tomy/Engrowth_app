import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation.dart';

/// 音声再生履歴サービス
class VoicePlaybackService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 音声再生を記録
  Future<void> recordPlayback({
    required String userId,
    required String conversationId,
    required String utteranceId,
    required String sessionId,
    String playbackType = 'tts',
  }) async {
    try {
      await _supabase.from('voice_playback_history').insert({
        'user_id': userId,
        'conversation_id': conversationId,
        'utterance_id': utteranceId,
        'session_id': sessionId,
        'playback_type': playbackType,
      });
    } catch (e) {
      print('Error recording playback: $e');
      // エラー時も続行（履歴記録は補助機能）
    }
  }

  /// セッション内で発話が再生されたかチェック
  Future<bool> hasPlayedInSession({
    required String userId,
    required String conversationId,
    required String utteranceId,
    required String sessionId,
  }) async {
    try {
      final response = await _supabase
          .from('voice_playback_history')
          .select('id')
          .eq('user_id', userId)
          .eq('conversation_id', conversationId)
          .eq('utterance_id', utteranceId)
          .eq('session_id', sessionId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking playback history: $e');
      return false;
    }
  }

  /// 会話内の全発話がセッション内で再生されたかチェック
  Future<Map<String, bool>> getPlaybackStatus({
    required String userId,
    required String conversationId,
    required List<String> utteranceIds,
    required String sessionId,
  }) async {
    try {
      final response = await _supabase
          .from('voice_playback_history')
          .select('utterance_id')
          .eq('user_id', userId)
          .eq('conversation_id', conversationId)
          .eq('session_id', sessionId)
          .inFilter('utterance_id', utteranceIds);

      final playedIds = (response as List)
          .map((json) => json['utterance_id'] as String)
          .toSet();

      return {
        for (final id in utteranceIds) id: playedIds.contains(id),
      };
    } catch (e) {
      print('Error getting playback status: $e');
      return {for (final id in utteranceIds) id: false};
    }
  }
}
