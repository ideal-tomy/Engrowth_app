import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/favorite_provider.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import '../services/conversation_service.dart';
import '../services/story_service.dart';
import '../services/favorite_service.dart';
import '../theme/engrowth_theme.dart';
import '../widgets/favorite_toggle_icon.dart';

/// お気に入り一覧画面
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    final favoritesAsync = ref.watch(userFavoritesProvider);

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('お気に入り')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  'アカウントを作成するとお気に入りを保存できます',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.push('/account'),
                  child: const Text('アカウント作成'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('お気に入り'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'すべて'),
            Tab(text: '単語'),
            Tab(text: '例文'),
            Tab(text: '会話'),
          ],
        ),
      ),
      body: favoritesAsync.when(
        data: (allFavs) {
          final byType = <String, List<UserFavorite>>{};
          for (final f in allFavs) {
            byType.putIfAbsent(f.targetType, () => []).add(f);
          }
          final words = byType['word'] ?? [];
          final sentences = byType['sentence'] ?? [];
          final conversations = byType['conversation'] ?? [];
          final stories = byType['story'] ?? [];

          return TabBarView(
            controller: _tabController,
            children: [
              _FavoritesList(favorites: allFavs),
              _FavoritesList(favorites: words),
              _FavoritesList(favorites: sentences),
              _FavoritesList(favorites: [...conversations, ...stories]),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
      ),
    );
  }
}

class _FavoritesList extends ConsumerStatefulWidget {
  final List<UserFavorite> favorites;

  const _FavoritesList({required this.favorites});

  @override
  ConsumerState<_FavoritesList> createState() => _FavoritesListState();
}

class _FavoritesListState extends ConsumerState<_FavoritesList> {
  Map<String, dynamic>? _resolved;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(_FavoritesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.favorites != widget.favorites) _resolve();
  }

  Future<void> _resolve() async {
    if (widget.favorites.isEmpty) {
      setState(() {
        _resolved = {};
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    final map = <String, dynamic>{};
    try {
      final convService = ConversationService();
      for (final f in widget.favorites) {
        final key = '${f.targetType}:${f.targetId}';
        switch (f.targetType) {
          case 'word':
            final w = await SupabaseService.getWordById(f.targetId);
            map[key] = w != null ? {'label': w.word, 'sublabel': w.meaning} : null;
            break;
          case 'sentence':
            final s = await SupabaseService.getSentenceById(f.targetId);
            map[key] = s != null
                ? {'label': s.englishText.length > 50 ? '${s.englishText.substring(0, 50)}...' : s.englishText}
                : null;
            break;
          case 'conversation':
            final c = await convService.getConversationById(f.targetId);
            map[key] = c != null ? {'label': c.title} : null;
            break;
          case 'story':
            final s = await StoryService().getStorySequenceById(f.targetId);
            map[key] = s != null ? {'label': s.title} : null;
            break;
          case 'pattern':
            map[key] = {'label': f.targetId, 'sublabel': 'パターンスプリント'};
            break;
          default:
            map[key] = null;
        }
      }
      if (mounted) setState(() { _resolved = map; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('読み込みエラー: $_error'));
    }
    if (widget.favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'お気に入りはありません',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.favorites.length,
      itemBuilder: (context, i) {
        final f = widget.favorites[i];
        final key = '${f.targetType}:${f.targetId}';
        final raw = _resolved?[key];
        final info = raw is Map<String, dynamic> ? raw : null;
        final label = info?['label'] as String? ?? f.targetId;
        final sublabel = info?['sublabel'] as String?;
        final icon = _iconForType(f.targetType);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
            title: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: sublabel != null ? Text(sublabel, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FavoriteToggleIcon(
                  targetType: f.targetType,
                  targetId: f.targetId,
                  size: 22,
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              HapticFeedback.selectionClick();
              _navigate(context, f);
            },
          ),
        );
      },
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'word': return Icons.book;
      case 'sentence': return Icons.article;
      case 'conversation': return Icons.chat_bubble_outline;
      case 'story': return Icons.auto_stories;
      case 'pattern': return Icons.repeat;
      default: return Icons.star;
    }
  }

  void _navigate(BuildContext context, UserFavorite f) {
    switch (f.targetType) {
      case 'word':
        context.push('/words');
        break;
      case 'sentence':
        context.push('/study?sentenceId=${f.targetId}');
        break;
      case 'conversation':
        context.push('/conversation/${f.targetId}');
        break;
      case 'story':
        context.push('/story/${f.targetId}');
        break;
      case 'pattern':
        context.push('/pattern-sprint');
        break;
      default:
        break;
    }
  }
}
