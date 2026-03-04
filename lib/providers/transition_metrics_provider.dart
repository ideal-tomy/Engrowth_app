import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 遷移計測用: タップ時刻を保持し、遷移先で transition_complete_ms を算出
class TransitionTapContext {
  final int tapTimestampMs;
  final String routeType;
  final String? fromRoute;
  final String toRoute;

  const TransitionTapContext({
    required this.tapTimestampMs,
    required this.routeType,
    this.fromRoute,
    required this.toRoute,
  });

  int elapsedMs() => DateTime.now().millisecondsSinceEpoch - tapTimestampMs;
}

class TransitionMetricsNotifier extends StateNotifier<TransitionTapContext?> {
  TransitionMetricsNotifier() : super(null);

  void recordTap({
    required String routeType,
    String? fromRoute,
    required String toRoute,
  }) {
    state = TransitionTapContext(
      tapTimestampMs: DateTime.now().millisecondsSinceEpoch,
      routeType: routeType,
      fromRoute: fromRoute,
      toRoute: toRoute,
    );
  }

  TransitionTapContext? consume() {
    final ctx = state;
    state = null;
    return ctx;
  }

  /// 計測に使用するが consume しない（複数ログで再利用する場合）
  TransitionTapContext? peek() => state;
}

final transitionMetricsProvider =
    StateNotifierProvider<TransitionMetricsNotifier, TransitionTapContext?>(
  (ref) => TransitionMetricsNotifier(),
);
