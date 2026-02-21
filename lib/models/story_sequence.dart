/// 3分ストーリーのメタデータ
class StorySequence {
  final String id;
  final String title;
  final String? description;
  final int totalDurationMinutes;
  final String? thumbnailUrl;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StorySequence({
    required this.id,
    required this.title,
    this.description,
    this.totalDurationMinutes = 3,
    this.thumbnailUrl,
    this.displayOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StorySequence.fromJson(Map<String, dynamic> json) {
    return StorySequence(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      totalDurationMinutes: json['total_duration_minutes'] as int? ?? 3,
      thumbnailUrl: json['thumbnail_url'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
