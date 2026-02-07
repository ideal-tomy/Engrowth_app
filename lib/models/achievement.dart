/// バッジ/称号モデル
class Achievement {
  final String id;
  final String title;
  final String? description;
  final String icon;  // Material Icons名
  final String conditionType;  // 'streak', 'sentence_count', 'scenario_count', 'hint_free_count'
  final int conditionValue;
  final DateTime createdAt;

  Achievement({
    required this.id,
    required this.title,
    this.description,
    this.icon = 'star',
    required this.conditionType,
    required this.conditionValue,
    required this.createdAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String? ?? 'star',
      conditionType: json['condition_type'] as String,
      conditionValue: json['condition_value'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'condition_type': conditionType,
      'condition_value': conditionValue,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// ユーザー達成モデル
class UserAchievement {
  final String id;
  final String userId;
  final String achievementId;
  final DateTime unlockedAt;

  UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      achievementId: json['achievement_id'] as String,
      unlockedAt: DateTime.parse(json['unlocked_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'achievement_id': achievementId,
      'unlocked_at': unlockedAt.toIso8601String(),
    };
  }
}
