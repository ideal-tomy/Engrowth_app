/// ユーザー統計情報モデル
/// ストリーク、日次ミッションなどを管理
class UserStats {
  final String id;
  final String userId;
  final int streakCount;
  final DateTime? lastStudyDate;
  final int dailyGoalCount;
  final int dailyDoneCount;
  final DateTime? dailyResetDate;
  final String timezone;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserStats({
    required this.id,
    required this.userId,
    this.streakCount = 0,
    this.lastStudyDate,
    this.dailyGoalCount = 3,
    this.dailyDoneCount = 0,
    this.dailyResetDate,
    this.timezone = 'Asia/Tokyo',
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      streakCount: json['streak_count'] as int? ?? 0,
      lastStudyDate: json['last_study_date'] != null
          ? DateTime.parse(json['last_study_date'] as String)
          : null,
      dailyGoalCount: json['daily_goal_count'] as int? ?? 3,
      dailyDoneCount: json['daily_done_count'] as int? ?? 0,
      dailyResetDate: json['daily_reset_date'] != null
          ? DateTime.parse(json['daily_reset_date'] as String)
          : null,
      timezone: json['timezone'] as String? ?? 'Asia/Tokyo',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'streak_count': streakCount,
      'last_study_date': lastStudyDate?.toIso8601String().split('T')[0],
      'daily_goal_count': dailyGoalCount,
      'daily_done_count': dailyDoneCount,
      'daily_reset_date': dailyResetDate?.toIso8601String().split('T')[0],
      'timezone': timezone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserStats copyWith({
    String? id,
    String? userId,
    int? streakCount,
    DateTime? lastStudyDate,
    int? dailyGoalCount,
    int? dailyDoneCount,
    DateTime? dailyResetDate,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserStats(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      streakCount: streakCount ?? this.streakCount,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      dailyGoalCount: dailyGoalCount ?? this.dailyGoalCount,
      dailyDoneCount: dailyDoneCount ?? this.dailyDoneCount,
      dailyResetDate: dailyResetDate ?? this.dailyResetDate,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 今日のミッション達成率（0.0-1.0）
  double get missionProgress {
    if (dailyGoalCount == 0) return 0.0;
    return (dailyDoneCount / dailyGoalCount).clamp(0.0, 1.0);
  }

  /// 今日のミッションが達成されたか
  bool get isMissionCompleted => dailyDoneCount >= dailyGoalCount;

  /// 匿名ユーザー用のデフォルト値
  static UserStats anonymous() {
    final now = DateTime.now();
    return UserStats(
      id: '',
      userId: 'anonymous',
      streakCount: 0,
      dailyGoalCount: 3,
      dailyDoneCount: 0,
      dailyResetDate: null,
      lastStudyDate: null,
      timezone: 'Asia/Tokyo',
      createdAt: now,
      updatedAt: now,
    );
  }
}
