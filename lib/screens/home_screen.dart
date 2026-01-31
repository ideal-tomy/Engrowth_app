import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/main_bottom_nav.dart';
import '../providers/progress_provider.dart';
import '../providers/sentence_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentencesAsync = ref.watch(sentencesProvider);
    final masteredCountAsync = ref.watch(masteredCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engrowth - 英会話学習'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/account'),
            tooltip: 'アカウント',
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNav(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 進捗表示
            masteredCountAsync.when(
              data: (mastered) {
                return sentencesAsync.when(
                  data: (sentences) {
                    return CustomProgressIndicator(
                      mastered: mastered,
                      total: sentences.length,
                      label: '学習進捗',
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            // 機能カード
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildFeatureCard(
                    context,
                    title: '単語リスト',
                    icon: Icons.book,
                    color: Colors.blue,
                    onTap: () => context.go('/words'),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context,
                    title: '例文リスト',
                    icon: Icons.article,
                    color: Colors.green,
                    onTap: () => context.go('/sentences'),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context,
                    title: '学習モード',
                    icon: Icons.school,
                    color: Colors.orange,
                    onTap: () => context.go('/study'),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context,
                    title: '進捗確認',
                    icon: Icons.trending_up,
                    color: Colors.purple,
                    onTap: () => context.go('/progress'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
