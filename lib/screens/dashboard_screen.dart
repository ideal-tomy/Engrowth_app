import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/engrowth_theme.dart';
import '../providers/user_stats_provider.dart';
import '../providers/sentence_provider.dart';
import '../widgets/scenario_background.dart';

/// Dashboard（Home タブ）
/// ヘッダー／再開カード／4x2アイコングリッドをコンパクトに表示
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: EngrowthColors.background,
      drawer: const _SettingsDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _DashboardHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    const _ResumeLearningCard(),
                    const SizedBox(height: 6),
                    const _RecommendedCard(),
                    const SizedBox(height: 6),
                    _MainTilesGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              HapticFeedback.selectionClick();
              Scaffold.of(context).openDrawer();
            },
            tooltip: '設定',
            color: EngrowthColors.onBackground,
          ),
          const Spacer(),
          Text(
            'Engrowth',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: EngrowthColors.onBackground,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          statsAsync.when(
            data: (stats) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\u{1F525}',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${stats.streakCount}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: EngrowthColors.onBackground,
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox(width: 40, height: 24),
            error: (_, __) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('\u{1F525}', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 4),
                  Text(
                    '0',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: EngrowthColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendedCard extends ConsumerWidget {
  const _RecommendedCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendedAsync = ref.watch(recommendedSentenceProvider);
    return recommendedAsync.when(
      data: (sentence) {
        if (sentence == null) return const SizedBox.shrink();
        final preview = sentence.englishText.length > 30
            ? '${sentence.englishText.substring(0, 30)}...'
            : sentence.englishText;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              context.push('/study?sentenceId=${sentence.id}');
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: EngrowthColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 20, color: Colors.amber[700]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '次に学習: $preview',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: EngrowthColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      context.push('/study?sentenceId=${sentence.id}');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '学習を始める',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: EngrowthColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ResumeLearningCard extends StatelessWidget {
  const _ResumeLearningCard();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('/study');
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: EngrowthColors.primary.withOpacity(0.2),
          highlightColor: EngrowthColors.primary.withOpacity(0.08),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    kScenarioBgAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: EngrowthColors.surface),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '前回の学習を再開',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '1タップで続きから',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MainTilesGrid extends StatelessWidget {
  static const _items = [
    _GridItem('会話トレーニング', Icons.record_voice_over, '/scenario-learning'),
    _GridItem('単語検索', Icons.search, '/words'),
    _GridItem('瞬間英作文', Icons.bolt, '/study'),
    _GridItem('センテンス一覧', Icons.format_list_bulleted, '/sentences'),
    _GridItem('学習進捗', Icons.bar_chart, '/progress'),
    _GridItem('お気に入り', Icons.favorite_border, '/favorites'),
    _GridItem('本日の復習', Icons.history, '/study'),
    _GridItem('設定', Icons.settings, 'drawer'),
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 0.9,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return _MainTile(
            title: item.title,
            icon: item.icon,
            onTap: () {
              HapticFeedback.selectionClick();
              if (item.route == 'drawer') {
                Scaffold.of(context).openDrawer();
              } else if (item.route == '/progress' || item.route == '/words') {
                context.go(item.route);
              } else if (item.route == '/sentences') {
                context.push(item.route);
              } else if (item.route == '/favorites') {
                context.push('/words'); // お気に入りは単語一覧へ
              } else {
                context.push(item.route);
              }
            },
          );
        },
      ),
    );
  }
}

class _GridItem {
  final String title;
  final IconData icon;
  final String route;

  const _GridItem(this.title, this.icon, this.route);
}

class _MainTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MainTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: EngrowthColors.primary.withOpacity(0.2),
        highlightColor: EngrowthColors.primary.withOpacity(0.08),
        child: Container(
          decoration: BoxDecoration(
            color: EngrowthColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: EngrowthColors.primary,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: EngrowthColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsDrawer extends StatelessWidget {
  const _SettingsDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                '設定',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('2秒ヒントの秒数設定'),
              onTap: () {
                Navigator.pop(context);
                context.push('/hint-settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('音声再生速度'),
              onTap: () {
                Navigator.pop(context);
                context.push('/playback-speed-settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_support_outlined),
              title: const Text('担当コンサルタントへ連絡'),
              onTap: () {
                Navigator.pop(context);
                // プレースホルダー
              },
            ),
            ListTile(
              leading: const Icon(Icons.record_voice_over),
              title: const Text('講師用ダッシュボード'),
              onTap: () {
                Navigator.pop(context);
                context.push('/consultant');
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: EngrowthColors.error),
              title: Text(
                'ログアウト',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: EngrowthColors.error,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _handleLogout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        // 必要であればログイン画面へ
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ログアウトに失敗しました: $e')),
        );
      }
    }
  }
}
