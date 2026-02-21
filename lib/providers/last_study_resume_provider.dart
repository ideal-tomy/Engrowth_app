import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 最後の瞬間英作文の再開用
/// アプリ再起動後も永続化して再開しやすくする
class LastStudyResumeState {
  final String? sentenceId;
  final DateTime? lastResumeAt;

  const LastStudyResumeState({
    this.sentenceId,
    this.lastResumeAt,
  });
}

final lastStudyResumeProvider =
    StateNotifierProvider<LastStudyResumeNotifier, LastStudyResumeState>((ref) {
  return LastStudyResumeNotifier();
});

class LastStudyResumeNotifier extends StateNotifier<LastStudyResumeState> {
  static const _keySentenceId = 'last_study_sentence_id';
  static const _keyLastResumeAt = 'last_study_resume_at';

  LastStudyResumeNotifier() : super(const LastStudyResumeState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final sentenceId = prefs.getString(_keySentenceId);
    final lastAt = prefs.getString(_keyLastResumeAt);
    state = LastStudyResumeState(
      sentenceId: sentenceId,
      lastResumeAt: lastAt != null ? DateTime.tryParse(lastAt) : null,
    );
  }

  Future<void> saveResumePoint(String sentenceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySentenceId, sentenceId);
    await prefs.setString(
      _keyLastResumeAt,
      DateTime.now().toIso8601String(),
    );
    state = LastStudyResumeState(
      sentenceId: sentenceId,
      lastResumeAt: DateTime.now(),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySentenceId);
    await prefs.remove(_keyLastResumeAt);
    state = const LastStudyResumeState();
  }
}
