import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/sentence_card.dart';
import '../widgets/main_bottom_nav.dart';
import '../providers/sentence_provider.dart';

class SentenceListScreen extends ConsumerStatefulWidget {
  const SentenceListScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('例文リスト'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/account'),
            tooltip: 'アカウント',
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNav(),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '例文、タグ、シーンで検索',
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
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          '例文が見つかりません',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: sentences.length,
                  itemBuilder: (context, index) {
                    return SentenceCard(sentence: sentences[index]);
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
