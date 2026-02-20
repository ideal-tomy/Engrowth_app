import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/sort_menu.dart';
import '../widgets/filter_chips.dart';
import '../widgets/word_list_accordion.dart';
import '../providers/word_provider.dart';
import '../models/word.dart';
import '../theme/engrowth_theme.dart';

class WordListScreen extends ConsumerStatefulWidget {
  final bool initialFocusSearch;

  const WordListScreen({super.key, this.initialFocusSearch = false});

  @override
  ConsumerState<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends ConsumerState<WordListScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  late final ScrollController _listScrollController;
  Timer? _debounceTimer;
  List<Word> _searchSuggestions = [];
  bool _showSuggestions = false;
  final Set<String> _expandedLetters = {};
  Map<String, double> _letterOffsets = {};

  @override
  void initState() {
    super.initState();
    _listScrollController = ScrollController();
    _searchController.addListener(_onSearchChanged);
    if (widget.initialFocusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  void _scrollToLetter(String letter) {
    final offset = _letterOffsets[letter];
    if (offset == null) return;
    _listScrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () => context.go('/library'),
            tooltip: 'Library へ',
          ),
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
          // 現在地ヒント
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '単語を検索・タップで詳細',
                style: TextStyle(
                  fontSize: 12,
                  color: EngrowthColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
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
          
          // 頭文字タグ（常に上に表示・タップで該当セクションにスクロール）
          FilterChips(onLetterTap: _scrollToLetter),

          // 単語リスト（A–Z アコーディオン）
          Expanded(
            child: ref.watch(wordsGroupedByLetterProvider).when(
              data: (grouped) {
                if (grouped.isEmpty) {
                  final hasSearch = ref.watch(debouncedSearchProvider).isNotEmpty;
                  final hasFilter = ref.watch(selectedGroupProvider) != null;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            '単語が見つかりません',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            hasSearch || hasFilter
                                ? '検索ワードを変えるか、フィルタを外してみましょう'
                                : '単語データがありません',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                          if (hasSearch || hasFilter)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: OutlinedButton(
                                onPressed: () {
                                  ref.read(wordSearchProvider.notifier).state = '';
                                  ref.read(debouncedSearchProvider.notifier).state = '';
                                  ref.read(selectedGroupProvider.notifier).state = null;
                                  _searchController.clear();
                                },
                                child: const Text('フィルタを解除'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }
                return WordListAccordion(
                  grouped: grouped,
                  expandedLetters: _expandedLetters,
                  scrollController: _listScrollController,
                  onLetterOffsets: (offsets) {
                    if (mounted) setState(() => _letterOffsets = offsets);
                  },
                  onToggle: (letter) {
                    setState(() {
                      if (_expandedLetters.contains(letter)) {
                        _expandedLetters.remove(letter);
                      } else {
                        _expandedLetters.add(letter);
                      }
                    });
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
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(wordsGroupedByLetterProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: EngrowthColors.primary,
                      ),
                      child: const Text('再試行'),
                    ),
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