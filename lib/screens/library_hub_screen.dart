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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LibraryCard(
              title: '例文集',
              subtitle: 'テキストで例文を確認',
              icon: Icons.article_outlined,
              onTap: () {
                HapticFeedback.selectionClick();
                context.push('/sentences');
              },
            ),
            const SizedBox(height: 12),
            _LibraryCard(
              title: '単語検索',
              subtitle: 'NGSL 1000語の検索・辞書',
              icon: Icons.search,
              onTap: () {
                HapticFeedback.selectionClick();
                context.push('/words');
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
