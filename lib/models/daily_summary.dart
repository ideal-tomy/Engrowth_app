class DailySummary {
  final String id;
  final String clientId;
  final String? consultantId;
  final DateTime summaryDate;
  final String content;
  final Map<String, dynamic>? stats;
  final DateTime? postedAt;
  final DateTime createdAt;

  DailySummary({
    required this.id,
    required this.clientId,
    this.consultantId,
    required this.summaryDate,
    required this.content,
    this.stats,
    this.postedAt,
    required this.createdAt,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      consultantId: json['consultant_id'] as String?,
      summaryDate: DateTime.parse(json['summary_date'] as String),
      content: json['content'] as String,
      stats: json['stats'] as Map<String, dynamic>?,
      postedAt: json['posted_at'] != null
          ? DateTime.parse(json['posted_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
