import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/engrowth_theme.dart';
import '../providers/user_stats_provider.dart';
import '../widgets/scenario_background.dart';

/// Dashboard（Home タブ）
/// ヘッダー／再開カード／2x2タイル／クイック検索をコンパクトに表示
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const _ResumeLearningCard(),
                    const SizedBox(height: 12),
                    _MainTilesGrid(),
                    const SizedBox(height: 12),
                    _QuickSearchBar(),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _MainTile(
            title: '会話学習',
            icon: Icons.chat_bubble_outline,
            accent: true,
            onTap: () {
              HapticFeedback.selectionClick();
              context.push('/scenario-learning');
            },
          ),
          _MainTile(
            title: '例文集',
            icon: Icons.article_outlined,
            onTap: () {
              HapticFeedback.selectionClick();
              context.push('/sentences');
            },
          ),
          _MainTile(
            title: '単語検索',
            icon: Icons.search,
            onTap: () {
              HapticFeedback.selectionClick();
              context.go('/words');
            },
          ),
          _MainTile(
            title: '進捗確認',
            icon: Icons.trending_up_outlined,
            onTap: () {
              HapticFeedback.selectionClick();
              context.go('/progress');
            },
          ),
        ],
      ),
    );
  }
}

class _MainTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool accent;
  final VoidCallback onTap;

  const _MainTile({
    required this.title,
    required this.icon,
    this.accent = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: EngrowthColors.primary.withOpacity(0.2),
        highlightColor: EngrowthColors.primary.withOpacity(0.08),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                color: EngrowthColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            if (accent)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        kScenarioBgAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const SizedBox.shrink(),
                      ),
                      Container(
                        color: EngrowthColors.surface.withOpacity(0.82),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: accent
                        ? EngrowthColors.primary
                        : EngrowthColors.onSurface,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: accent
                          ? EngrowthColors.primary
                          : EngrowthColors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: EngrowthColors.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
        child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.go('/words');
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: EngrowthColors.primary.withOpacity(0.2),
        highlightColor: EngrowthColors.primary.withOpacity(0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: EngrowthColors.onSurfaceVariant.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                size: 22,
                color: EngrowthColors.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                '単語を検索',
                style: TextStyle(
                  fontSize: 15,
                  color: EngrowthColors.onSurfaceVariant,
                ),
              ),
            ],
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
