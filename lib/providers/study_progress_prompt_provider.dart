import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kScenarioLastShownKey = 'study_progress_prompt_scenario_last';
const _kScenarioTotalShownKey = 'study_progress_prompt_scenario_total';
const _kStoryLastShownKey = 'study_progress_prompt_story_last';
const _kStoryTotalShownKey = 'study_progress_prompt_story_total';

/// 控えめ表示ルール: 初回 / 節目(3,5,10回目) / 5回ごと
bool _shouldShow(int totalCompletions, int lastShownAt) {
  if (totalCompletions <= 0) return false;
  if (lastShownAt >= totalCompletions) return false;

  if (totalCompletions == 1) return true; // 初回
  if ([3, 5, 10].contains(totalCompletions)) return true; // 節目
  if (totalCompletions % 5 == 0 && totalCompletions > lastShownAt) return true; // 5回ごと

  return false;
}

/// 学習完了後に進捗ミニポップアップを表示すべきか判定
/// track: 'scenario' | 'story'
class StudyProgressPromptNotifier extends StateNotifier<_StudyProgressPromptState> {
  StudyProgressPromptNotifier() : super(const _StudyProgressPromptState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = _StudyProgressPromptState(
      scenarioLastShownAt: prefs.getInt(_kScenarioLastShownKey) ?? 0,
      scenarioTotalCompletions: prefs.getInt(_kScenarioTotalShownKey) ?? 0,
      storyLastShownAt: prefs.getInt(_kStoryLastShownKey) ?? 0,
      storyTotalCompletions: prefs.getInt(_kStoryTotalShownKey) ?? 0,
    );
  }

  /// 完了時に呼ぶ。表示すべきなら true
  Future<bool> onCompleted(String track) async {
    final prefs = await SharedPreferences.getInstance();
    final isScenario = track == 'scenario';

    int total;
    int lastShown;

    if (isScenario) {
      total = (prefs.getInt(_kScenarioTotalShownKey) ?? 0) + 1;
      lastShown = prefs.getInt(_kScenarioLastShownKey) ?? 0;
    } else {
      total = (prefs.getInt(_kStoryTotalShownKey) ?? 0) + 1;
      lastShown = prefs.getInt(_kStoryLastShownKey) ?? 0;
    }

    if (isScenario) {
      await prefs.setInt(_kScenarioTotalShownKey, total);
      state = state.copyWith(scenarioTotalCompletions: total);
    } else {
      await prefs.setInt(_kStoryTotalShownKey, total);
      state = state.copyWith(storyTotalCompletions: total);
    }

    final shouldShow = _shouldShow(total, lastShown);
    return shouldShow;
  }

  /// 表示済み時に呼ぶ
  Future<void> markShown(String track) async {
    final prefs = await SharedPreferences.getInstance();
    final isScenario = track == 'scenario';

    int total;
    if (isScenario) {
      total = prefs.getInt(_kScenarioTotalShownKey) ?? 0;
      await prefs.setInt(_kScenarioLastShownKey, total);
      state = state.copyWith(scenarioLastShownAt: total);
    } else {
      total = prefs.getInt(_kStoryTotalShownKey) ?? 0;
      await prefs.setInt(_kStoryLastShownKey, total);
      state = state.copyWith(storyLastShownAt: total);
    }
  }
}

class _StudyProgressPromptState {
  final int scenarioLastShownAt;
  final int scenarioTotalCompletions;
  final int storyLastShownAt;
  final int storyTotalCompletions;

  const _StudyProgressPromptState({
    this.scenarioLastShownAt = 0,
    this.scenarioTotalCompletions = 0,
    this.storyLastShownAt = 0,
    this.storyTotalCompletions = 0,
  });

  _StudyProgressPromptState copyWith({
    int? scenarioLastShownAt,
    int? scenarioTotalCompletions,
    int? storyLastShownAt,
    int? storyTotalCompletions,
  }) {
    return _StudyProgressPromptState(
      scenarioLastShownAt: scenarioLastShownAt ?? this.scenarioLastShownAt,
      scenarioTotalCompletions:
          scenarioTotalCompletions ?? this.scenarioTotalCompletions,
      storyLastShownAt: storyLastShownAt ?? this.storyLastShownAt,
      storyTotalCompletions:
          storyTotalCompletions ?? this.storyTotalCompletions,
    );
  }
}

final studyProgressPromptProvider =
    StateNotifierProvider<StudyProgressPromptNotifier, _StudyProgressPromptState>(
  (ref) => StudyProgressPromptNotifier(),
);
