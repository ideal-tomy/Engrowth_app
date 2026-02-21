class FeedbackTemplate {
  final String id;
  final String? consultantId;
  final String name;
  final String content;
  final String? category;
  final int usageCount;
  final DateTime createdAt;

  FeedbackTemplate({
    required this.id,
    this.consultantId,
    required this.name,
    required this.content,
    this.category,
    this.usageCount = 0,
    required this.createdAt,
  });

  factory FeedbackTemplate.fromJson(Map<String, dynamic> json) {
    return FeedbackTemplate(
      id: json['id'] as String,
      consultantId: json['consultant_id'] as String?,
      name: json['name'] as String,
      content: json['content'] as String,
      category: json['category'] as String?,
      usageCount: json['usage_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
