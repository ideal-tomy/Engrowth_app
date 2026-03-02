import 'package:flutter/material.dart';

/// Engrowthが選ばれる理由・コンセプトページ
/// ヘルプではなくストーリー（想い）として配置
class ConceptScreen extends StatelessWidget {
  const ConceptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engrowthが選ばれる理由'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '音で覚えて、慣れる。',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '従来の学習法（読み書き中心）で挫折したあなたへ。',
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _Block(
            title: 'なぜ「音」なのか',
            body:
                '英語は耳で覚える言語です。文字から入ると、発音と意味がつながりにくく、'
                '「読めるのに話せない」状態になりがちです。\n\n'
                'Engrowthは「聞く→まねする→使う」の順番を徹底します。'
                '短い会話を何度も聞き、自分の声で録音し、先生に送る。'
                'この繰り返しで、会話感覚が自然に身につきます。',
          ),
          const SizedBox(height: 24),
          _Block(
            title: '30秒と3分の意味',
            body:
                '隙間時間に「30秒会話」で負担なく始められます。'
                '慣れてきたら「3分会話」でまとまったロールプレイ。'
                '無理のない区切りで、続けやすい設計です。',
          ),
          const SizedBox(height: 24),
          _Block(
            title: '録音とフィードバック',
            body:
                '自分の声を録音して聴き直すことで、改善点に気づけます。'
                '担当コンサルタントへの提出で、的確なアドバイスを受けられます。'
                '一人で練習する孤独感を減らし、モチベーションを保ちます。',
          ),
          const SizedBox(height: 24),
          _Block(
            title: 'Engrowthのこだわり',
            body:
                '説明書を読ませず、体験で伝える。'
                '最初の一歩は「挨拶体験」で体感してもらいます。'
                '理論より実践。音で覚えて、慣れる。それが私たちの信念です。',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final String title;
  final String body;

  const _Block({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: TextStyle(
            fontSize: 15,
            height: 1.7,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
