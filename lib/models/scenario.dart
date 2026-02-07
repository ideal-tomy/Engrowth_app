/// シナリオモデル
class Scenario {
  final String id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String difficulty;  // 'easy', 'medium', 'hard'
  final int estimatedMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Scenario({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.difficulty = 'medium',
    this.estimatedMinutes = 10,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Scenario.fromJson(Map<String, dynamic> json) {
    return Scenario(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      difficulty: json['difficulty'] as String? ?? 'medium',
      estimatedMinutes: json['estimated_minutes'] as int? ?? 10,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'difficulty': difficulty,
      'estimated_minutes': estimatedMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// シナリオステップモデル
class ScenarioStep {
  final String id;
  final String scenarioId;
  final String sentenceId;
  final int orderIndex;
  final DateTime createdAt;

  ScenarioStep({
    required this.id,
    required this.scenarioId,
    required this.sentenceId,
    required this.orderIndex,
    required this.createdAt,
  });

  factory ScenarioStep.fromJson(Map<String, dynamic> json) {
    return ScenarioStep(
      id: json['id'] as String,
      scenarioId: json['scenario_id'] as String,
      sentenceId: json['sentence_id'] as String,
      orderIndex: json['order_index'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scenario_id': scenarioId,
      'sentence_id': sentenceId,
      'order_index': orderIndex,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// ユーザーシナリオ進捗モデル
class UserScenarioProgress {
  final String id;
  final String userId;
  final String scenarioId;
  final int lastStepIndex;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserScenarioProgress({
    required this.id,
    required this.userId,
    required this.scenarioId,
    this.lastStepIndex = 0,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserScenarioProgress.fromJson(Map<String, dynamic> json) {
    return UserScenarioProgress(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      scenarioId: json['scenario_id'] as String,
      lastStepIndex: json['last_step_index'] as int? ?? 0,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'scenario_id': scenarioId,
      'last_step_index': lastStepIndex,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 進捗率（0.0-1.0）
  double getProgressRate(int totalSteps) {
    if (totalSteps == 0) return 0.0;
    return (lastStepIndex / totalSteps).clamp(0.0, 1.0);
  }

  /// 完了済みかどうか
  bool get isCompleted => completedAt != null;
}
