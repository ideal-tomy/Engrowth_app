import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// 使い方・困った時に見るページ
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('使い方'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Section(
            icon: Icons.record_voice_over,
            title: 'アプリでできること',
            children: [
              _Item(
                subtitle: '30秒会話',
                body: '隙間時間に短い会話を聞いて練習します。まずは聞くだけでOK。',
              ),
              _Item(
                subtitle: 'パターンスクリプト',
                body: 'お手本を聞いたら録音。聴き直して「先生に送る」で提出できます。',
              ),
              _Item(
                subtitle: '3分会話',
                body: '約3分の会話を聞いて、役になりきって練習。',
              ),
              _Item(
                subtitle: '会話トレーニング',
                body: 'AIと会話のやり取りを体験。聞いて→話して→返答を繰り返します。',
              ),
              _Item(
                subtitle: '今日の報告',
                body: '日課の録音を担当コンサルタントに提出。フィードバックが届きます。',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Section(
            icon: Icons.touch_app,
            title: '基本操作',
            children: [
              _Item(
                subtitle: '音声を聴く',
                body: '英語・ゆっくり・日本語ボタンでお手本を再生できます。',
              ),
              _Item(
                subtitle: '録音する',
                body: 'マイクボタンを押して話し、もう一度押して停止。',
              ),
              _Item(
                subtitle: '提出する',
                body: '録音を保存後、「今日の報告を送る」で担当に共有。',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Section(
            icon: Icons.refresh,
            title: '再開・導線',
            children: [
              _Item(
                subtitle: '初回体験をもう一度',
                body: '設定 > 開発: 初回体験をリセット（デバッグ時のみ表示）',
              ),
              _Item(
                subtitle: '挨拶体験',
                body: '初回体験フロー内の「挨拶体験」から、聞く→話す→返答を体験できます。',
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                context.push('/onboarding');
              },
              icon: const Icon(Icons.school_outlined, size: 20),
              label: const Text('初回体験をやり直す'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _Section({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _Item extends StatelessWidget {
  final String subtitle;
  final String body;

  const _Item({required this.subtitle, required this.body});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
