/// 会話モデル
class Conversation {
  final String id;
  final String? scenarioId;
  final String title;
  final String? description;
  final String? situationType;  // 'student', 'business'
  final String? weekRange;  // '1-2', '3-4', etc.
  final String? theme;  // '挨拶', '自己紹介', etc.
  final String? thumbnailUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    this.scenarioId,
    required this.title,
    this.description,
    this.situationType,
    this.weekRange,
    this.theme,
    this.thumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      scenarioId: json['scenario_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      situationType: json['situation_type'] as String?,
      weekRange: json['week_range'] as String?,
      theme: json['theme'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scenario_id': scenarioId,
      'title': title,
      'description': description,
      'situation_type': situationType,
      'week_range': weekRange,
      'theme': theme,
      'thumbnail_url': thumbnailUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// 会話発話モデル
class ConversationUtterance {
  final String id;
  final String conversationId;
  final String speakerRole;  // 'A', 'B', 'C', 'system'
  final int utteranceOrder;
  final String englishText;
  final String japaneseText;
  final String? audioUrl;
  final DateTime createdAt;

  ConversationUtterance({
    required this.id,
    required this.conversationId,
    required this.speakerRole,
    required this.utteranceOrder,
    required this.englishText,
    required this.japaneseText,
    this.audioUrl,
    required this.createdAt,
  });

  factory ConversationUtterance.fromJson(Map<String, dynamic> json) {
    return ConversationUtterance(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      speakerRole: json['speaker_role'] as String,
      utteranceOrder: json['utterance_order'] as int,
      englishText: json['english_text'] as String,
      japaneseText: json['japanese_text'] as String,
      audioUrl: json['audio_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'speaker_role': speakerRole,
      'utterance_order': utteranceOrder,
      'english_text': englishText,
      'japanese_text': japaneseText,
      'audio_url': audioUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// 音声再生履歴モデル
class VoicePlaybackHistory {
  final String id;
  final String userId;
  final String conversationId;
  final String utteranceId;
  final DateTime playedAt;
  final String playbackType;  // 'tts', 'user_recording', 'system_audio'
  final String? sessionId;

  VoicePlaybackHistory({
    required this.id,
    required this.userId,
    required this.conversationId,
    required this.utteranceId,
    required this.playedAt,
    this.playbackType = 'tts',
    this.sessionId,
  });

  factory VoicePlaybackHistory.fromJson(Map<String, dynamic> json) {
    return VoicePlaybackHistory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      conversationId: json['conversation_id'] as String,
      utteranceId: json['utterance_id'] as String,
      playedAt: DateTime.parse(json['played_at'] as String),
      playbackType: json['playback_type'] as String? ?? 'tts',
      sessionId: json['session_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'conversation_id': conversationId,
      'utterance_id': utteranceId,
      'played_at': playedAt.toIso8601String(),
      'playback_type': playbackType,
      'session_id': sessionId,
    };
  }
}
