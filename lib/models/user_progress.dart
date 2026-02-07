class UserProgress {
  final String id;
  final String userId;
  final String sentenceId;
  final bool isMastered;
  final DateTime? lastStudiedAt;
  final DateTime createdAt;
  
  // ヒント関連フィールド（拡張）
  final int hintUsageCount;
  final bool usedHintToMaster;
  final int averageThinkingTimeSeconds;
  final String? lastHintPhase;
  
  // 復習最適化フィールド
  final DateTime? lastReviewAt;
  final DateTime? nextReviewAt;
  final double stability;  // 記憶安定度
  final double difficulty;  // 難易度
  final int reviewCount;  // 復習回数

  UserProgress({
    required this.id,
    required this.userId,
    required this.sentenceId,
    required this.isMastered,
    this.lastStudiedAt,
    required this.createdAt,
    this.hintUsageCount = 0,
    this.usedHintToMaster = false,
    this.averageThinkingTimeSeconds = 0,
    this.lastHintPhase,
    this.lastReviewAt,
    this.nextReviewAt,
    this.stability = 1.0,
    this.difficulty = 0.3,
    this.reviewCount = 0,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      sentenceId: json['sentence_id'] as String,
      isMastered: json['is_mastered'] as bool? ?? false,
      lastStudiedAt: json['last_studied_at'] != null
          ? DateTime.parse(json['last_studied_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      hintUsageCount: json['hint_usage_count'] as int? ?? 0,
      usedHintToMaster: json['used_hint_to_master'] as bool? ?? false,
      averageThinkingTimeSeconds: json['average_thinking_time_seconds'] as int? ?? 0,
      lastHintPhase: json['last_hint_phase'] as String?,
      lastReviewAt: json['last_review_at'] != null
          ? DateTime.parse(json['last_review_at'] as String)
          : null,
      nextReviewAt: json['next_review_at'] != null
          ? DateTime.parse(json['next_review_at'] as String)
          : null,
      stability: (json['stability'] as num?)?.toDouble() ?? 1.0,
      difficulty: (json['difficulty'] as num?)?.toDouble() ?? 0.3,
      reviewCount: json['review_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'sentence_id': sentenceId,
      'is_mastered': isMastered,
      'last_studied_at': lastStudiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'hint_usage_count': hintUsageCount,
      'used_hint_to_master': usedHintToMaster,
      'average_thinking_time_seconds': averageThinkingTimeSeconds,
      'last_hint_phase': lastHintPhase,
      'last_review_at': lastReviewAt?.toIso8601String(),
      'next_review_at': nextReviewAt?.toIso8601String(),
      'stability': stability,
      'difficulty': difficulty,
      'review_count': reviewCount,
    };
  }
}
