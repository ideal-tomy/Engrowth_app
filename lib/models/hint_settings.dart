class HintSettings {
  final String id;
  final String userId;
  
  // ヒントタイミング設定
  final int initialHintDelaySeconds;
  final int extendedHintDelaySeconds;
  final int keywordsHintDelaySeconds;
  
  // ヒント表示設定
  final double hintOpacity;
  final List<String> hintPhasesEnabled;
  
  // フィードバック設定
  final bool hapticFeedbackEnabled;
  final bool visualFeedbackEnabled;
  
  // メタデータ
  final DateTime createdAt;
  final DateTime updatedAt;

  HintSettings({
    required this.id,
    required this.userId,
    this.initialHintDelaySeconds = 2,
    this.extendedHintDelaySeconds = 6,
    this.keywordsHintDelaySeconds = 10,
    this.hintOpacity = 0.6,
    this.hintPhasesEnabled = const ['initial', 'extended', 'keywords'],
    this.hapticFeedbackEnabled = true,
    this.visualFeedbackEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HintSettings.fromJson(Map<String, dynamic> json) {
    return HintSettings(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      initialHintDelaySeconds: json['initial_hint_delay_seconds'] as int? ?? 2,
      extendedHintDelaySeconds: json['extended_hint_delay_seconds'] as int? ?? 6,
      keywordsHintDelaySeconds: json['keywords_hint_delay_seconds'] as int? ?? 10,
      hintOpacity: (json['hint_opacity'] as num?)?.toDouble() ?? 0.6,
      hintPhasesEnabled: json['hint_phases_enabled'] != null
          ? List<String>.from(json['hint_phases_enabled'] as List)
          : ['initial', 'extended', 'keywords'],
      hapticFeedbackEnabled: json['haptic_feedback_enabled'] as bool? ?? true,
      visualFeedbackEnabled: json['visual_feedback_enabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'initial_hint_delay_seconds': initialHintDelaySeconds,
      'extended_hint_delay_seconds': extendedHintDelaySeconds,
      'keywords_hint_delay_seconds': keywordsHintDelaySeconds,
      'hint_opacity': hintOpacity,
      'hint_phases_enabled': hintPhasesEnabled,
      'haptic_feedback_enabled': hapticFeedbackEnabled,
      'visual_feedback_enabled': visualFeedbackEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  HintSettings copyWith({
    String? id,
    String? userId,
    int? initialHintDelaySeconds,
    int? extendedHintDelaySeconds,
    int? keywordsHintDelaySeconds,
    double? hintOpacity,
    List<String>? hintPhasesEnabled,
    bool? hapticFeedbackEnabled,
    bool? visualFeedbackEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HintSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      initialHintDelaySeconds: initialHintDelaySeconds ?? this.initialHintDelaySeconds,
      extendedHintDelaySeconds: extendedHintDelaySeconds ?? this.extendedHintDelaySeconds,
      keywordsHintDelaySeconds: keywordsHintDelaySeconds ?? this.keywordsHintDelaySeconds,
      hintOpacity: hintOpacity ?? this.hintOpacity,
      hintPhasesEnabled: hintPhasesEnabled ?? this.hintPhasesEnabled,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      visualFeedbackEnabled: visualFeedbackEnabled ?? this.visualFeedbackEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
