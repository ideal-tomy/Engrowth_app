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
    };
  }
}
