import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ガイドフロー体感デモ用: アニメーション速度の倍率
/// 1.0 = 通常, 5.0 = 5倍遅く（体感しやすい）, 10.0 = 10倍遅く
/// デモ画面でのみ使用。本番フローには影響しない。
final guidedFlowDemoSpeedProvider = StateProvider<double>((ref) => 5.0);
