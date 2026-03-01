import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/sentence_categories.dart';
import '../models/sentence.dart';
import '../services/tts_service.dart';
import '../widgets/sentence_detail_sheet.dart';
import '../providers/sentence_provider.dart';

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
    final selectedCategories = ref.watch(selectedCategoriesProvider);

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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                hintText: '例文、「道案内」「接客」などで検索',
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
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          
          // カテゴリタブ（#接客, #道案内 等）。タップで同一ページ内絞り込み
          ref.watch(sentenceCategoryDisplayListProvider).when(
            data: (displayList) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    'カテゴリ:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  ...displayList.map((displayName) {
                    final isSelected = selectedCategories.contains(displayName);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text('#$displayName'),
                        selected: isSelected,
                        onSelected: (selected) {
                          // 単一選択: 2つ目をタップしたら1つ目を解除して切り替え
                          if (selected) {
                            ref.read(selectedCategoriesProvider.notifier).state = {displayName};
                          } else {
                            ref.read(selectedCategoriesProvider.notifier).state = {};
                          }
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

          // 例文リスト（phrase_title アコーディオン + シンプル行）
          Expanded(
            child: ref.watch(filteredSentencesByPhraseTitleProvider).when(
              data: (grouped) {
                if (grouped.isEmpty) {
                  final hasSearch = ref.watch(debouncedSentenceSearchProvider).isNotEmpty;
                  final hasFilter = ref.watch(selectedCategoriesProvider).isNotEmpty;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text(
                            '例文が見つかりません',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            hasSearch || hasFilter
                                ? '検索ワードを変えるか、カテゴリを外してみましょう'
                                : '例文データがありません',
                            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final title = grouped.keys.elementAt(index);
                    final list = grouped[title]!;
                    return _SentenceAccordionSection(
                      title: title,
                      sentences: list,
                      onTapSentence: (s) => SentenceDetailSheet.show(context, s),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 48, color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 16),
                    Text('エラー: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(filteredSentencesByPhraseTitleProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
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

/// アコーディオン1セクション（例: 「Can I have ...?」を開くと該当センテンス一覧）
class _SentenceAccordionSection extends StatelessWidget {
  final String title;
  final List<Sentence> sentences;
  final void Function(Sentence) onTapSentence;

  const _SentenceAccordionSection({
    required this.title,
    required this.sentences,
    required this.onTapSentence,
  });

  String _effectiveCategory(Sentence s) {
    if (s.categoryLabelJa != null && s.categoryLabelJa!.trim().isNotEmpty) {
      return canonicalCategoryForTabs(s.categoryLabelJa!.trim());
    }
    return canonicalCategoryForTabs(resolveSentenceCategory(
      categoryTag: s.categoryTag,
      englishText: s.englishText,
      japaneseText: s.japaneseText,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryTags = sentences.map(_effectiveCategory).toSet().toList();
    final tagLabel = categoryTags.isNotEmpty ? '#${categoryTags.first}' : '';
    return ExpansionTile(
      initiallyExpanded: false,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      childrenPadding: const EdgeInsets.only(left: 8, right: 16, bottom: 12),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          if (tagLabel.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tagLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      children: sentences
          .map((s) => _SentenceListRow(
                sentence: s,
                onTap: () => onTapSentence(s),
              ))
          .toList(),
    );
  }
}

/// シンプル行: 英文・日本語訳・右側に通常再生ボタンのみ（画像なし）
class _SentenceListRow extends StatefulWidget {
  final Sentence sentence;
  final VoidCallback onTap;

  const _SentenceListRow({
    required this.sentence,
    required this.onTap,
  });

  @override
  State<_SentenceListRow> createState() => _SentenceListRowState();
}

class _SentenceListRowState extends State<_SentenceListRow> {
  final TtsService _tts = TtsService();
  bool _isPlaying = false;
  String? _prefetchedUrl;

  @override
  void initState() {
    super.initState();
    _tts.initialize();
    _prefetchAudio();
  }

  void _prefetchAudio() {
    _tts.fetchAudioUrlForEnglish(widget.sentence.englishText).then((url) {
      if (mounted && url != null) {
        setState(() => _prefetchedUrl = url);
      }
    });
  }

  Future<void> _play() async {
    if (_isPlaying) {
      await _tts.stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }
    if (mounted) setState(() => _isPlaying = true);
    await _tts.speakEnglish(
      widget.sentence.englishText,
      prefetchedUrl: _prefetchedUrl,
    );
    if (mounted) setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.sentence.englishText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.sentence.japaneseText,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _play,
                icon: Icon(
                  _isPlaying ? Icons.stop_circle : Icons.volume_up,
                  size: 24,
                  color: colorScheme.primary,
                ),
                tooltip: '通常',
                style: IconButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}