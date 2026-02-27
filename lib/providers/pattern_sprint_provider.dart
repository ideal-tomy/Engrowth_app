import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/pattern_sprint_service.dart';

final patternSprintServiceProvider = Provider<PatternSprintService>((ref) {
  return PatternSprintService();
});

/// パターン一覧
final patternListProvider = Provider<List<PatternDefinition>>((ref) {
  final service = ref.watch(patternSprintServiceProvider);
  return service.getPatterns();
});

/// 指定パターン・秒数でセッション用アイテムを取得
final patternSprintSessionItemsProvider = FutureProvider.family<
    List<PatternSprintItem>,
    ({String prefix, int durationSec})>((ref, params) async {
  final service = ref.watch(patternSprintServiceProvider);
  final limit =
      PatternSprintService.estimatePhraseCountForDuration(params.durationSec);
  return service.fetchItemsForPattern(
    prefix: params.prefix,
    limit: limit,
    shuffle: true,
  );
});
