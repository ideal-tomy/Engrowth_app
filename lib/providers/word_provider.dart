import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/word.dart';
import '../services/supabase_service.dart';

final wordsProvider = FutureProvider<List<Word>>((ref) async {
  return await SupabaseService.getWords();
});

final wordSearchProvider = StateProvider<String>((ref) => '');

final filteredWordsProvider = FutureProvider<List<Word>>((ref) async {
  final searchQuery = ref.watch(wordSearchProvider);
  return await SupabaseService.getWords(searchQuery: searchQuery);
});

final wordGroupsProvider = FutureProvider<List<String>>((ref) async {
  final words = await ref.watch(wordsProvider.future);
  final groups = words
      .where((w) => w.wordGroup != null && w.wordGroup!.isNotEmpty)
      .map((w) => w.wordGroup!)
      .toSet()
      .toList();
  groups.sort();
  return groups;
});

final wordsByGroupProvider = FutureProvider.family<List<Word>, String>((ref, group) async {
  return await SupabaseService.getWords(wordGroup: group);
});
