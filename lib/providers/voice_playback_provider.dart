import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/voice_playback_service.dart';

/// 音声再生履歴サービスプロバイダ
final voicePlaybackServiceProvider = Provider<VoicePlaybackService>((ref) {
  return VoicePlaybackService();
});

/// セッション内での発話再生状態プロバイダ
final utterancePlaybackStatusProvider = FutureProvider.family<bool, PlaybackStatusParams>((ref, params) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null || params.sessionId == null) return false;

  final service = ref.read(voicePlaybackServiceProvider);
  return await service.hasPlayedInSession(
    userId: userId,
    conversationId: params.conversationId,
    utteranceId: params.utteranceId,
    sessionId: params.sessionId!,
  );
});

/// 再生状態パラメータ
class PlaybackStatusParams {
  final String conversationId;
  final String utteranceId;
  final String? sessionId;

  PlaybackStatusParams({
    required this.conversationId,
    required this.utteranceId,
    this.sessionId,
  });
}
