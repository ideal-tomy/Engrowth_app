/// パターンスプリントの3段階練習フェーズ
enum PatternSprintPhase {
  /// 1回目: 英日同時表示（理解）
  phase1,
  /// 2回目: 日本語のみ表示（定着）
  phase2,
  /// 3回目: テキスト非表示・ボタンのみ（自動化）
  phase3,
}

extension PatternSprintPhaseX on PatternSprintPhase {
  int get index => PatternSprintPhase.values.indexOf(this) + 1;

  /// phase1: 英日表示, phase2: 日本語のみ, phase3: ボタンのみ
  bool get showJapanese =>
      this == PatternSprintPhase.phase1 || this == PatternSprintPhase.phase2;
  bool get showEnglish => this == PatternSprintPhase.phase1;
}
