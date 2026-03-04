/// 学習完了時のハンドオフ結果
/// オンボーディング導線で「完了した」と判定し、次章へ自動進行するために使用
class LearningHandoffResult {
  /// 学習を完了したか
  final bool completed;

  /// 学習モード（quick30 / pattern_sprint / focus3）
  final String? learningMode;

  const LearningHandoffResult({
    required this.completed,
    this.learningMode,
  });

  /// 完了を表す結果
  static const LearningHandoffResult completedResult = LearningHandoffResult(
    completed: true,
  );

  /// 未完了（スキップ等）
  static const LearningHandoffResult notCompleted = LearningHandoffResult(
    completed: false,
  );

  /// 完了結果を学習モード付きで作成
  static LearningHandoffResult completedWithMode(String mode) =>
      LearningHandoffResult(completed: true, learningMode: mode);
}
