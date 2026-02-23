import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kCompletionCountKey = 'anon_conversion_completion_count';
const _kSkipNextPromptKey = 'anon_conversion_skip_next';
const _kEveryN = 3;

/// 匿名ユーザー向け：完了回数カウントとポップアップ表示判定
class AnonymousConversionNotifier extends StateNotifier<AnonymousConversionState> {
  AnonymousConversionNotifier() : super(const AnonymousConversionState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AnonymousConversionState(
      completionCount: prefs.getInt(_kCompletionCountKey) ?? 0,
      skipNextPrompt: prefs.getBool(_kSkipNextPromptKey) ?? false,
    );
  }

  /// 学習完了時に呼ぶ（匿名ユーザーのみ）
  Future<void> onCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    var count = prefs.getInt(_kCompletionCountKey) ?? 0;
    count += 1;
    await prefs.setInt(_kCompletionCountKey, count);
    state = state.copyWith(completionCount: count);
  }

  /// 3回ごとに表示すべきか。スキップ中は消費して false を返す
  Future<bool> shouldShowPrompt() async {
    final wouldShow =
        state.completionCount > 0 && state.completionCount % _kEveryN == 0;
    if (state.skipNextPrompt && wouldShow) {
      await _consumeSkip();
      return false;
    }
    if (state.skipNextPrompt) return false;
    return wouldShow;
  }

  Future<void> _consumeSkip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSkipNextPromptKey, false);
    state = state.copyWith(skipNextPrompt: false);
  }

  /// 「後で」選択時：次の1回の表示をスキップ
  Future<void> markDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSkipNextPromptKey, true);
    state = state.copyWith(skipNextPrompt: true);
  }

  /// 登録成功時：カウントをリセット（任意）
  Future<void> resetOnConversion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCompletionCountKey);
    await prefs.remove(_kSkipNextPromptKey);
    state = const AnonymousConversionState();
  }
}

class AnonymousConversionState {
  final int completionCount;
  final bool skipNextPrompt;

  const AnonymousConversionState({
    this.completionCount = 0,
    this.skipNextPrompt = false,
  });

  AnonymousConversionState copyWith({
    int? completionCount,
    bool? skipNextPrompt,
  }) {
    return AnonymousConversionState(
      completionCount: completionCount ?? this.completionCount,
      skipNextPrompt: skipNextPrompt ?? this.skipNextPrompt,
    );
  }
}

final anonymousConversionProvider =
    StateNotifierProvider<AnonymousConversionNotifier, AnonymousConversionState>(
  (ref) => AnonymousConversionNotifier(),
);
