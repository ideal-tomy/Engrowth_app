import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'analytics_provider.dart';

/// B09: ホーム初見3秒で主要導線認識の検証
/// impression 送信時刻を保持し、3秒以内のタップを recognized として送信
class HomePrimaryCtaState {
  final DateTime? impressionAt;

  const HomePrimaryCtaState({this.impressionAt});
}

final homePrimaryCtaProvider =
    StateNotifierProvider<HomePrimaryCtaNotifier, HomePrimaryCtaState>(
        (ref) => HomePrimaryCtaNotifier(ref));

class HomePrimaryCtaNotifier extends StateNotifier<HomePrimaryCtaState> {
  HomePrimaryCtaNotifier(this._ref) : super(const HomePrimaryCtaState());

  final Ref _ref;

  static const _recognitionWindowSec = 3;
  bool _recognizedReported = false;

  void recordImpression() {
    if (state.impressionAt != null) return;
    final now = DateTime.now();
    state = HomePrimaryCtaState(impressionAt: now);
    _recognizedReported = false;
    _ref.read(analyticsServiceProvider).logEvent(
          eventType: 'home_primary_cta_impression',
          eventProperties: {'impression_at_ms': now.millisecondsSinceEpoch},
        );
  }

  void maybeRecordRecognized(String ctaSource) {
    final at = state.impressionAt;
    if (at == null || _recognizedReported) return;
    final elapsedSec = DateTime.now().difference(at).inSeconds;
    if (elapsedSec > _recognitionWindowSec) return;
    _recognizedReported = true;
    _ref.read(analyticsServiceProvider).logEvent(
          eventType: 'home_primary_cta_recognized',
          eventProperties: {
            'cta_source': ctaSource,
            'elapsed_sec': elapsedSec,
            'under_3s': true,
          },
        );
  }
}
