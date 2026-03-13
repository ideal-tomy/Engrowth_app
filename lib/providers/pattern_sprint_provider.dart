import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pattern_sprint_category.dart';
import '../services/pattern_category_resolver.dart';
import '../services/pattern_sprint_service.dart';

final patternSprintServiceProvider = Provider<PatternSprintService>((ref) {
  return PatternSprintService();
});

final patternCategoryResolverProvider = Provider<PatternCategoryResolver>((ref) {
  return PatternCategoryResolver();
});

/// パターン一覧（従来互換）
final patternListProvider = Provider<List<PatternDefinition>>((ref) {
  final service = ref.watch(patternSprintServiceProvider);
  return service.getPatterns();
});

/// カテゴリ一覧（集中トレーニング用）
final patternCategoriesProvider = Provider<List<PatternSprintCategory>>((ref) {
  final resolver = ref.watch(patternCategoryResolverProvider);
  return resolver.getCategories();
});

/// カテゴリ別パターン（UI用）
final patternByCategoryProvider = Provider<Map<String, List<PatternDefinition>>>((ref) {
  final resolver = ref.watch(patternCategoryResolverProvider);
  return resolver.groupPatternsByCategory();
});

/// 指定パターン・秒数でセッション用アイテムを取得
/// [minPhrases] オンボーディング時など、最小フレーズ数を保証したい場合に指定
final patternSprintSessionItemsProvider = FutureProvider.family<
    List<PatternSprintItem>,
    ({String prefix, int durationSec, int? minPhrases})>((ref, params) async {
  final service = ref.watch(patternSprintServiceProvider);
  var limit =
      PatternSprintService.estimatePhraseCountForDuration(params.durationSec);
  if (params.minPhrases != null && limit < params.minPhrases!) {
    limit = params.minPhrases!;
  }
  return service.fetchItemsForPattern(
    prefix: params.prefix,
    limit: limit,
    shuffle: true,
  );
});
