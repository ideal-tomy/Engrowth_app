/// 音声提出モデル
class VoiceSubmission {
  final String id;
  final String userId;
  final String? conversationId;
  final String? utteranceId;
  final String? sentenceId;
  final String audioUrl;
  final String? sessionId;
  final String submissionType; // 'practice' | 'submitted'
  final String reviewStatus; // 'pending' | 'reviewed'
  final String? consultantId;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  VoiceSubmission({
    required this.id,
    required this.userId,
    this.conversationId,
    this.utteranceId,
    this.sentenceId,
    required this.audioUrl,
    this.sessionId,
    required this.submissionType,
    required this.reviewStatus,
    this.consultantId,
    this.reviewedAt,
    required this.createdAt,
  });

  factory VoiceSubmission.fromJson(Map<String, dynamic> json) {
    return VoiceSubmission(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      conversationId: json['conversation_id'] as String?,
      utteranceId: json['utterance_id'] as String?,
      sentenceId: json['sentence_id'] as String?,
      audioUrl: json['audio_url'] as String,
      sessionId: json['session_id'] as String?,
      submissionType: json['submission_type'] as String? ?? 'practice',
      reviewStatus: json['review_status'] as String? ?? 'pending',
      consultantId: json['consultant_id'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool get isSubmitted => submissionType == 'submitted';
  bool get isPendingReview => isSubmitted && reviewStatus == 'pending';
}
