/// 起動性能計測用: main() 開始時刻を保持し、
/// app_boot_started / first_frame_rendered / home_critical_ready / home_full_ready の経過 ms を算出する。
class BootMetrics {
  BootMetrics._();

  static DateTime? _startedAt;

  /// main() の先頭で呼ぶ。二重呼び出しは無視する。
  static void setStarted() {
    _startedAt ??= DateTime.now();
  }

  /// 起動開始からの経過ミリ秒。未設定時は null。
  static int? get elapsedMs =>
      _startedAt != null ? DateTime.now().difference(_startedAt!).inMilliseconds : null;
}
