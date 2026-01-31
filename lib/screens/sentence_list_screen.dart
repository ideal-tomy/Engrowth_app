import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/sentence_card.dart';
import '../providers/sentence_provider.dart';

class SentenceListScreen extends ConsumerWidget {
  const SentenceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentencesAsync = ref.watch(sentencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('例文リスト'),
      ),
      body: sentencesAsync.when(
        data: (sentences) {
          if (sentences.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '例文がまだ登録されていません',
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
    );
  }
}
