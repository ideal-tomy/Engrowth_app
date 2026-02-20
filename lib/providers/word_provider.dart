import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/word.dart';
import '../services/supabase_service.dart';

final wordsProvider = FutureProvider<List<Word>>((ref) async {
  return await SupabaseService.getWords();
});

final wordSearchProvider = StateProvider<String>((ref) => '');

// デバウンスされた検索クエリ
final debouncedSearchProvider = StateProvider<String>((ref) => '');

// デバウンス処理（300ms）
final debounceTimerProvider = StateProvider<Timer?>((ref) => null);

final filteredWordsProvider = FutureProvider<List<Word>>((ref) async {
  final searchQuery = ref.watch(debouncedSearchProvider);
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

// フィルタ状態
enum WordFilterType {
  all,
  mastered,
  studying,
}

final wordFilterProvider = StateProvider<WordFilterType>((ref) => WordFilterType.all);
/// アルファベット頭文字で絞り込み（'a'～'z'、null で全件）
final selectedLetterProvider = StateProvider<String?>((ref) => null);
final selectedGroupProvider = StateProvider<String?>((ref) => null);

// ソート順
enum WordSortOrder {
  alphabeticalAsc,
  alphabeticalDesc,
  dateAsc,
  dateDesc,
  studyCountAsc,
  studyCountDesc,
}

final wordSortOrderProvider = StateProvider<WordSortOrder>((ref) => WordSortOrder.alphabeticalAsc);

// フィルタリングとソートを適用した単語リスト
final filteredAndSortedWordsProvider = FutureProvider<List<Word>>((ref) async {
  final searchQuery = ref.watch(debouncedSearchProvider);
  final letter = ref.watch(selectedLetterProvider);
  final group = ref.watch(selectedGroupProvider);
  final sortOrder = ref.watch(wordSortOrderProvider);

  var words = await SupabaseService.getWords(
    searchQuery: searchQuery,
    wordGroup: group,
  );

  // アルファベット頭文字フィルタ
  if (letter != null && letter.isNotEmpty) {
    final lower = letter.toLowerCase();
    words = words.where((w) => w.word.isNotEmpty && w.word[0].toLowerCase() == lower).toList();
  }

  // 学習状況フィルタ（将来的に実装）
  // 現時点では、user_progressテーブルとの連携が必要

  // ソート
  switch (sortOrder) {
    case WordSortOrder.alphabeticalAsc:
      words.sort((a, b) => a.word.compareTo(b.word));
      break;
    case WordSortOrder.alphabeticalDesc:
      words.sort((a, b) => b.word.compareTo(a.word));
      break;
    case WordSortOrder.dateAsc:
      words.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case WordSortOrder.dateDesc:
      words.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case WordSortOrder.studyCountAsc:
    case WordSortOrder.studyCountDesc:
      // 学習回数でのソートは将来的に実装
      break;
  }

  return words;
});

/// 頭文字でフィルタ可能なアルファベット一覧（単語に存在する頭文字のみ）
final availableLettersProvider = FutureProvider<List<String>>((ref) async {
  final words = await ref.watch(wordsProvider.future);
  final letters = words
      .where((w) => w.word.isNotEmpty)
      .map((w) => w.word[0].toLowerCase())
      .toSet()
      .toList();
  letters.sort();
  return letters;
});

/// フィルタ・ソート済み単語を頭文字でグループ化（アコーディオン用）
final wordsGroupedByLetterProvider = FutureProvider<Map<String, List<Word>>>((ref) async {
  final words = await ref.watch(filteredAndSortedWordsProvider.future);
  final map = <String, List<Word>>{};
  for (final w in words) {
    if (w.word.isEmpty) continue;
    final letter = w.word[0].toLowerCase();
    map.putIfAbsent(letter, () => []).add(w);
  }
  for (final list in map.values) {
    list.sort((a, b) => a.word.compareTo(b.word));
  }
  return map;
});
