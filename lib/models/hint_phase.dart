enum HintPhase {
  none('none'),
  initial('initial'),
  extended('extended'),
  keywords('keywords');

  final String value;
  const HintPhase(this.value);

  static HintPhase fromString(String value) {
    return HintPhase.values.firstWhere(
      (phase) => phase.value == value,
      orElse: () => HintPhase.none,
    );
  }

  String get displayName {
    switch (this) {
      case HintPhase.none:
        return 'ヒントなし';
      case HintPhase.initial:
        return '初期ヒント';
      case HintPhase.extended:
        return '拡張ヒント';
      case HintPhase.keywords:
        return '重要単語';
    }
  }

  int get delaySeconds {
    switch (this) {
      case HintPhase.none:
        return 0;
      case HintPhase.initial:
        return 2;
      case HintPhase.extended:
        return 6;
      case HintPhase.keywords:
        return 10;
    }
  }
}
