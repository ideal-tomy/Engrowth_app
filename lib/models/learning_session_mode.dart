/// 学習セッションの長さ・目標時間
/// Quick30: 30〜60秒（1〜2問、即時達成）
/// Focus3: 約3分（5〜10問、小さな完了）
enum LearningSessionMode {
  quick30,
  focus3,
  unlimited,
}

extension LearningSessionModeExtension on LearningSessionMode {
  String get displayName {
    switch (this) {
      case LearningSessionMode.quick30:
        return '30秒';
      case LearningSessionMode.focus3:
        return '3分';
      case LearningSessionMode.unlimited:
        return '続ける';
    }
  }

  String get shortLabel {
    switch (this) {
      case LearningSessionMode.quick30:
        return 'Quick30';
      case LearningSessionMode.focus3:
        return 'Focus3';
      case LearningSessionMode.unlimited:
        return 'Unlimited';
    }
  }

  /// 瞬間英作文での最大例文数
  int get maxSentenceCount {
    switch (this) {
      case LearningSessionMode.quick30:
        return 2;
      case LearningSessionMode.focus3:
        return 8;
      case LearningSessionMode.unlimited:
        return 999;
    }
  }

  /// 推定所要時間（秒）
  int get estimatedSeconds {
    switch (this) {
      case LearningSessionMode.quick30:
        return 60;
      case LearningSessionMode.focus3:
        return 180;
      case LearningSessionMode.unlimited:
        return 0;
    }
  }
}
