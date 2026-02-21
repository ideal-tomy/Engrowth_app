import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/voice_submission.dart';

const _bucketName = 'voice-recordings';

/// 音声提出サービス
/// 録音をStorageへアップロードし、voice_submissionsに登録
class VoiceSubmissionService {
  final SupabaseClient _client = Supabase.instance.client;

  /// 録音ファイルをアップロードし、practiceとして登録
  Future<VoiceSubmission?> uploadAsPractice({
    required File audioFile,
    required String sessionId,
    String? conversationId,
    String? utteranceId,
    String? sentenceId,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final storagePath = '${userId}/practice/${sessionId}_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _client.storage.from(_bucketName).upload(
            storagePath,
            audioFile,
            fileOptions: const FileOptions(upsert: true),
          );
      // audio_url にはストレージパスを保存（再生時は getSignedUrl で取得）
      final response = await _client.from('voice_submissions').insert({
        'user_id': userId,
        'conversation_id': conversationId,
        'utterance_id': utteranceId,
        'sentence_id': sentenceId != null && sentenceId.isNotEmpty ? sentenceId : null,
        'audio_url': storagePath,
        'session_id': sessionId,
        'submission_type': 'practice',
        'review_status': 'pending',
      }).select().single();

      return VoiceSubmission.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('VoiceSubmissionService.uploadAsPractice error: $e');
      rethrow;
    }
  }

  /// 既存のvoice_submissionをsubmittedに更新
  Future<void> markAsSubmitted(String submissionId) async {
    await _client.from('voice_submissions').update({
      'submission_type': 'submitted',
    }).eq('id', submissionId);
  }

  /// ユーザーの音声提出一覧を取得（日付で絞り込み可能）
  Future<List<VoiceSubmission>> getUserSubmissions({
    required String userId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var query = _client
          .from('voice_submissions')
          .select()
          .eq('user_id', userId);

      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('created_at', toDate.toIso8601String());
      }

      final response = await query.order('created_at', ascending: false);
      return (response as List)
          .map((e) => VoiceSubmission.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('VoiceSubmissionService.getUserSubmissions error: $e');
      return [];
    }
  }

  /// 音声の再生用URLを取得（signed URL、1時間有効）
  Future<String?> getSignedPlaybackUrl(String storagePathOrUrl) async {
    if (storagePathOrUrl.startsWith('http')) return storagePathOrUrl;
    try {
      final result = await _client.storage.from(_bucketName).createSignedUrl(storagePathOrUrl, 3600);
      // createSignedUrl returns SignedUrl (path, signedUrl) or String depending on version
      if (result is String) return result;
      return (result as dynamic).signedUrl as String?;
    } catch (_) {
      return null;
    }
  }

  /// 録音をアップロードし、即座にsubmittedとして登録（先生に送る）
  Future<VoiceSubmission?> uploadAndSubmit({
    required File audioFile,
    required String sessionId,
    String? conversationId,
    String? utteranceId,
    String? sentenceId,
  }) async {
    final submission = await uploadAsPractice(
      audioFile: audioFile,
      sessionId: sessionId,
      conversationId: conversationId,
      utteranceId: utteranceId,
      sentenceId: sentenceId,
    );
    if (submission != null) {
      await markAsSubmitted(submission.id);
      return VoiceSubmission(
        id: submission.id,
        userId: submission.userId,
        conversationId: submission.conversationId,
        utteranceId: submission.utteranceId,
        sentenceId: submission.sentenceId,
        audioUrl: submission.audioUrl,
        sessionId: submission.sessionId,
        submissionType: 'submitted',
        reviewStatus: submission.reviewStatus,
        consultantId: submission.consultantId,
        reviewedAt: submission.reviewedAt,
        createdAt: submission.createdAt,
      );
    }
    return null;
  }
}
