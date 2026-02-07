import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/word_card.dart';
import '../widgets/sort_menu.dart';
import '../widgets/filter_chips.dart';
import '../providers/word_provider.dart';
import '../models/word.dart';

class WordListScreen extends ConsumerStatefulWidget {
  const WordListScreen({super.key});

  @override
  ConsumerState<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends ConsumerState<WordListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<Word> _searchSuggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    ref.read(wordSearchProvider.notifier).state = query;

    // デバウンス処理（300ms）
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(debouncedSearchProvider.notifier).state = query;
      _updateSearchSuggestions(query);
    });

    setState(() {
      _showSuggestions = query.isNotEmpty;
    });
  }

  void _updateSearchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchSuggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    final allWords = await ref.read(wordsProvider.future);
    final lowerQuery = query.toLowerCase();
    final suggestions = allWords
        .where((word) {
          return word.word.toLowerCase().contains(lowerQuery) ||
                 word.meaning.toLowerCase().contains(lowerQuery);
        })
        .take(5)
        .toList();

    if (mounted) {
      setState(() {
        _searchSuggestions = suggestions;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('単語リスト'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/account'),
            tooltip: 'アカウント',
          ),
          const SortMenu(),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '単語や意味で検索',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(wordSearchProvider.notifier).state = '';
                              ref.read(debouncedSearchProvider.notifier).state = '';
                              setState(() {
                                _showSuggestions = false;
                                _searchSuggestions = [];
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                // 検索候補表示
                if (_showSuggestions && _searchSuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchSuggestions.length,
                      itemBuilder: (context, index) {
                        final word = _searchSuggestions[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.search, size: 20),
                          title: Text(
                            word.word,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(word.meaning),
                          onTap: () {
                            _searchController.text = word.word;
                            ref.read(wordSearchProvider.notifier).state = word.word;
                            ref.read(debouncedSearchProvider.notifier).state = word.word;
                            setState(() {
                              _showSuggestions = false;
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          
          // フィルタチップ
          const FilterChips(),
          
          // 単語リスト
          Expanded(
            child: ref.watch(filteredAndSortedWordsProvider).when(
              data: (words) {
                if (words.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          '単語が見つかりません',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    return WordCard(word: words[index]);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('エラー: $error'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
