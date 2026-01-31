class UserProgress {
  final String id;
  final String userId;
  final String sentenceId;
  final bool isMastered;
  final DateTime? lastStudiedAt;
  final DateTime createdAt;

  UserProgress({
    required this.id,
    required this.userId,
    required this.sentenceId,
    required this.isMastered,
    this.lastStudiedAt,
    required this.createdAt,
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
    };
  }
}
