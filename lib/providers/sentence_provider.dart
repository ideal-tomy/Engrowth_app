import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sentence.dart';
import '../services/supabase_service.dart';

final sentencesProvider = FutureProvider<List<Sentence>>((ref) async {
  return await SupabaseService.getSentences();
});

final sentenceByIdProvider = FutureProvider.family<Sentence?, String>((ref, id) async {
  return await SupabaseService.getSentenceById(id);
});

final studySentencesProvider = FutureProvider<List<Sentence>>((ref) async {
  return await SupabaseService.getSentences();
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
  
  // カテゴリフィルタ
  if (selectedCategories.isNotEmpty) {
    sentences = sentences.where((sentence) {
      return sentence.categoryTag != null &&
             selectedCategories.contains(sentence.categoryTag);
    }).toList();
  }
  
  return sentences;
});

// カテゴリリスト
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
