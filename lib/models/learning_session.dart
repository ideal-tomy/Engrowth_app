class LearningSession {
  final String sessionId;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<String> sentenceIds;
  final int totalSentences;
  final int masteredCount;
  final int hintUsedCount;
  final Duration totalDuration;

  LearningSession({
    required this.sessionId,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.sentenceIds,
    this.totalSentences = 0,
    this.masteredCount = 0,
    this.hintUsedCount = 0,
    Duration? totalDuration,
  }) : totalDuration = totalDuration ?? 
        (endTime != null ? endTime.difference(startTime) : Duration.zero);

  factory LearningSession.create({
    required String userId,
    required List<String> sentenceIds,
  }) {
    return LearningSession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      startTime: DateTime.now(),
      sentenceIds: sentenceIds,
      totalSentences: sentenceIds.length,
    );
  }

  LearningSession copyWith({
    String? sessionId,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? sentenceIds,
    int? totalSentences,
    int? masteredCount,
    int? hintUsedCount,
    Duration? totalDuration,
  }) {
    return LearningSession(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sentenceIds: sentenceIds ?? this.sentenceIds,
      totalSentences: totalSentences ?? this.totalSentences,
      masteredCount: masteredCount ?? this.masteredCount,
      hintUsedCount: hintUsedCount ?? this.hintUsedCount,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }

  LearningSession end() {
    return copyWith(endTime: DateTime.now());
  }
}
