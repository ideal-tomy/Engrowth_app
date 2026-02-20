import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/sentence_card.dart';
import '../widgets/sentence_detail_sheet.dart';
import '../providers/sentence_provider.dart';
import '../providers/progress_provider.dart';
import '../theme/engrowth_theme.dart';

class SentenceListScreen extends ConsumerStatefulWidget {
  final String? initialWord;

  const SentenceListScreen({super.key, this.initialWord});

  @override
  ConsumerState<SentenceListScreen> createState() => _SentenceListScreenState();
}

class _SentenceListScreenState extends ConsumerState<SentenceListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    if (widget.initialWord != null && widget.initialWord!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchController.text = widget.initialWord!;
        ref.read(sentenceSearchProvider.notifier).state = widget.initialWord!;
        ref.read(debouncedSentenceSearchProvider.notifier).state =
            widget.initialWord!;
      });
    }
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
    ref.read(sentenceSearchProvider.notifier).state = query;

    // デバウンス処理（300ms）
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(debouncedSentenceSearchProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sentencesAsync = ref.watch(filteredSentencesProvider);
    final categories = ref.watch(categoryListProvider);
    final selectedCategories = ref.watch(selectedCategoriesProvider);
    final masteredIdsAsync = ref.watch(masteredSentenceIdsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('センテンス一覧'),
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
                '例文を検索・再生・学習開始',
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
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '例文、「道を尋ねる」「接客」などで検索',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(sentenceSearchProvider.notifier).state = '';
                          ref.read(debouncedSentenceSearchProvider.notifier).state = '';
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
          ),
          
          // カテゴリフィルタチップ
          categories.when(
            data: (categoryList) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    'カテゴリ:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  ...categoryList.map((category) {
                    final isSelected = selectedCategories.contains(category);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          final current = Set<String>.from(selectedCategories);
                          if (selected) {
                            current.add(category);
                          } else {
                            current.remove(category);
                          }
                          ref.read(selectedCategoriesProvider.notifier).state = current;
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          // 例文リスト
          Expanded(
            child: sentencesAsync.when(
              data: (sentences) {
                if (sentences.isEmpty) {
                  final hasSearch = ref.watch(debouncedSentenceSearchProvider).isNotEmpty;
                  final hasFilter = ref.watch(selectedCategoriesProvider).isNotEmpty;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            '例文が見つかりません',
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
                                ? '検索ワードを変えるか、カテゴリを外してみましょう'
                                : '例文データがありません',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                          if (hasSearch || hasFilter)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: OutlinedButton(
                                onPressed: () {
                                  ref.read(sentenceSearchProvider.notifier).state = '';
                                  ref.read(debouncedSentenceSearchProvider.notifier).state = '';
                                  ref.read(selectedCategoriesProvider.notifier).state = {};
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
                final masteredIds = masteredIdsAsync.valueOrNull ?? <String>{};
                return ListView.builder(
                  itemCount: sentences.length,
                  itemBuilder: (context, index) {
                    final sentence = sentences[index];
                    return SentenceCard(
                      sentence: sentence,
                      compact: true,
                      isMastered: masteredIds.contains(sentence.id),
                      onTap: () =>
                          SentenceDetailSheet.show(context, sentence),
                      onStudyTap: (id) =>
                          context.push('/study?sentenceId=$id'),
                    );
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
                      onPressed: () => ref.invalidate(filteredSentencesProvider),
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