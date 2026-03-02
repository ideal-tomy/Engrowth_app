import 'package:flutter_riverpod/flutter_riverpod.dart';

/// B16: ResumeLearningCard タップから学習初回表示までの遅延計測用
/// タップ時刻と entry_source を保持し、StudyScreen で study_first_content_rendered に利用
class ResumeCardTapContext {
  final DateTime tappedAt;
  final String entrySource; // resume_card, recommended_fallback, plain_fallback

  const ResumeCardTapContext({
    required this.tappedAt,
    required this.entrySource,
  });

  int tapToContentMs() =>
      DateTime.now().difference(tappedAt).inMilliseconds;
}

final resumeCardTapContextProvider =
    StateNotifierProvider<ResumeCardTapContextNotifier, ResumeCardTapContext?>(
        (ref) => ResumeCardTapContextNotifier());

class ResumeCardTapContextNotifier extends StateNotifier<ResumeCardTapContext?> {
  ResumeCardTapContextNotifier() : super(null);

  void record(String entrySource) {
    state = ResumeCardTapContext(
      tappedAt: DateTime.now(),
      entrySource: entrySource,
    );
  }

  ResumeCardTapContext? consume() {
    final ctx = state;
    state = null;
    return ctx;
  }
}
