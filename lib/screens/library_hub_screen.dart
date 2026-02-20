import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/engrowth_theme.dart';

/// Library タブ: 例文集・単語検索へのハブ
class LibraryHubScreen extends StatelessWidget {
  const LibraryHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EngrowthColors.background,
      appBar: AppBar(
        title: const Text('Library'),
        backgroundColor: EngrowthColors.surface,
        foregroundColor: EngrowthColors.onSurface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '現在地: Library — ここから単語・例文・会話・進捗へ',
                style: TextStyle(
                  fontSize: 12,
                  color: EngrowthColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LibraryCard(
              title: 'センテンス一覧',
              subtitle: '例文検索・学習開始',
              icon: Icons.article_outlined,
              onTap: () {
                HapticFeedback.selectionClick();
                context.push('/sentences');
              },
            ),
            const SizedBox(height: 12),
            _LibraryCard(
              title: '単語検索',
              subtitle: 'NGSL単語を検索',
              icon: Icons.search,
              onTap: () {
                HapticFeedback.selectionClick();
                context.go('/words');
              },
            ),
            const SizedBox(height: 12),
            _LibraryCard(
              title: '会話学習',
              subtitle: '役割練習・リスニング',
              icon: Icons.chat_bubble_outline,
              onTap: () {
                HapticFeedback.selectionClick();
                context.push('/conversations');
              },
            ),
            const SizedBox(height: 12),
            _LibraryCard(
              title: '進捗',
              subtitle: '学習履歴・習得状況',
              icon: Icons.trending_up_outlined,
              onTap: () {
                HapticFeedback.selectionClick();
                context.go('/progress');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _LibraryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EngrowthColors.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: EngrowthColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: EngrowthColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: EngrowthColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: EngrowthColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: EngrowthColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
