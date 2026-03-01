import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/sentence_categories.dart';
import '../models/sentence.dart';
import '../services/supabase_service.dart';
import 'progress_provider.dart';
import 'review_provider.dart';

final sentencesProvider = FutureProvider<List<Sentence>>((ref) async {
  return await SupabaseService.getSentences();
});

final sentenceByIdProvider = FutureProvider.family<Sentence?, String>((ref, id) async {
  return await SupabaseService.getSentenceById(id);
});

final studySentencesProvider = FutureProvider<List<Sentence>>((ref) async {
  return await SupabaseService.getSentences();
});

/// 学習開始時に指定例文から始めるためのプロバイダ。
/// [sentenceId] が null の場合は studySentencesProvider と同じ。
/// [sentenceId] 指定時: 全例文を取得し該当を先頭に並べ替え。見つからなければ
/// sentenceByIdProvider で取得し [sentence] を返す。それも見つからなければ全リストを返す。
final studySentencesFromProvider = FutureProvider.family<List<Sentence>, String?>((ref, sentenceId) async {
  if (sentenceId == null || sentenceId.isEmpty) {
    return ref.watch(studySentencesProvider.future);
  }
  final sentences = await ref.watch(sentencesProvider.future);
  final idx = sentences.indexWhere((s) => s.id == sentenceId);
  if (idx >= 0) {
    return [...sentences.sublist(idx), ...sentences.sublist(0, idx)];
  }
  final single = await ref.watch(sentenceByIdProvider(sentenceId).future);
  if (single != null) {
    return [single];
  }
  return sentences;
});

// 検索クエリ
final sentenceSearchProvider = StateProvider<String>((ref) => '');
final debouncedSentenceSearchProvider = StateProvider<String>((ref) => '');

// カテゴリフィルタ（複数選択可能）
final selectedCategoriesProvider = StateProvider<Set<String>>((ref) => {});

// フィルタリングと検索を適用した例文リスト
final filteredSentencesProvider = FutureProvider<List<Sentence>>((ref) async {
  final searchQuery = ref.watch(debouncedSentenceSearchProvider);
  final selectedCategories = ref.watch(selectedCategoriesProvider);
  
  // すべての例文を取得
  var sentences = await SupabaseService.getSentences();
  
  // 検索フィルタ
  if (searchQuery.isNotEmpty) {
    final lowerQuery = searchQuery.toLowerCase();
    sentences = sentences.where((sentence) {
      return sentence.englishText.toLowerCase().contains(lowerQuery) ||
             sentence.japaneseText.toLowerCase().contains(lowerQuery) ||
             (sentence.categoryTag != null && 
              sentence.categoryTag!.toLowerCase().contains(lowerQuery)) ||
             (sentence.sceneSetting != null && 
              sentence.sceneSetting!.toLowerCase().contains(lowerQuery)) ||
             (sentence.targetWords != null && 
              sentence.targetWords!.toLowerCase().contains(lowerQuery));
    }).toList();
  }
  
  // カテゴリフィルタ（日本語表示名で判定・自動振り分け結果を使用）
  if (selectedCategories.isNotEmpty) {
    sentences = sentences.where((sentence) {
      final displayName = resolveSentenceCategory(
        categoryTag: sentence.categoryTag,
        englishText: sentence.englishText,
        japaneseText: sentence.japaneseText,
      );
      return selectedCategories.contains(displayName);
    }).toList();
  }
  
  return sentences;
});

/// 本日の復習用例文リスト（優先度キュー順。取得失敗時は空でフォールバック）
final studySentencesForReviewProvider = FutureProvider<List<Sentence>>((ref) async {
  try {
    final reviewList = await ref.watch(todayReviewListProvider.future);
    if (reviewList.isEmpty) return [];
    final sentences = <Sentence>[];
    for (final p in reviewList) {
      final s = await SupabaseService.getSentenceById(p.sentenceId);
      if (s != null) sentences.add(s);
    }
    return sentences;
  } catch (_) {
    return [];
  }
});

/// 次推奨（今日の推奨）: 未習得の最初の例文、またはランダム未習得。全て習得済みなら先頭を返す。
final recommendedSentenceProvider = FutureProvider<Sentence?>((ref) async {
  final sentences = await ref.watch(sentencesProvider.future);
  if (sentences.isEmpty) return null;
  final masteredIds = await ref.watch(masteredSentenceIdsProvider.future);
  final unmastered = sentences.where((s) => !masteredIds.contains(s.id)).toList();
  if (unmastered.isEmpty) return sentences.first;
  return unmastered.first;
});

/// 瞬間英作文用: ランダムシャッフルしたセンテンス一覧
final instantCompositionSentencesProvider = FutureProvider<List<Sentence>>((ref) async {
  final sentences = await SupabaseService.getSentences();
  if (sentences.isEmpty) return [];
  final shuffled = List<Sentence>.from(sentences)..shuffle();
  return shuffled;
});

// カテゴリリスト（DB の raw タグ）
final categoryListProvider = FutureProvider<List<String>>((ref) async {
  final sentences = await ref.watch(sentencesProvider.future);
  final categories = sentences
      .where((s) => s.categoryTag != null && s.categoryTag!.isNotEmpty)
      .map((s) => s.categoryTag!)
      .toSet()
      .toList();
  categories.sort();
  return categories;
});

/// センテンス一覧用: 日本語カテゴリ表示名のリスト（英文・日本語訳の自動振り分け後、日本人が求めそうな順）
final sentenceCategoryDisplayListProvider = FutureProvider<List<String>>((ref) async {
  final sentences = await ref.watch(sentencesProvider.future);
  final displayNames = <String>{};
  for (final s in sentences) {
    final resolved = resolveSentenceCategory(
      categoryTag: s.categoryTag,
      englishText: s.englishText,
      japaneseText: s.japaneseText,
    );
    displayNames.add(resolved);
  }
  final list = displayNames.toList();
  list.sort((a, b) =>
      sentenceCategorySortIndex(a).compareTo(sentenceCategorySortIndex(b)));
  return list;
});

/// フィルタ済み例文を日本語カテゴリ（表示名）でグルーピング。英文・日本語訳から自動振り分け。
final filteredSentencesByCategoryProvider =
    FutureProvider<Map<String, List<Sentence>>>((ref) async {
  final sentences = await ref.watch(filteredSentencesProvider.future);
  final map = <String, List<Sentence>>{};
  for (final s in sentences) {
    final displayName = resolveSentenceCategory(
      categoryTag: s.categoryTag,
      englishText: s.englishText,
      japaneseText: s.japaneseText,
    );
    map.putIfAbsent(displayName, () => []).add(s);
  }
  final keys = map.keys.toList();
  keys.sort((a, b) =>
      sentenceCategorySortIndex(a).compareTo(sentenceCategorySortIndex(b)));
  return Map.fromEntries(keys.map((k) => MapEntry(k, map[k]!)));
});
