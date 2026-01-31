import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/progress_indicator.dart';
import '../providers/progress_provider.dart';
import '../providers/sentence_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);
    final masteredCountAsync = ref.watch(masteredCountProvider);
    final sentencesAsync = ref.watch(sentencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('進捗確認'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 全体進捗
            masteredCountAsync.when(
              data: (mastered) {
                return sentencesAsync.when(
                  data: (sentences) {
                    return CustomProgressIndicator(
                      mastered: mastered,
                      total: sentences.length,
                      label: '全体進捗',
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            // 詳細リスト
            progressAsync.when(
              data: (progressList) {
                if (progressList.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.trending_up, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'まだ学習を開始していません',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final masteredList = progressList.where((p) => p.isMastered).toList();
                final studyingList = progressList.where((p) => !p.isMastered).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (masteredList.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          '覚えた例文',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...masteredList.map((progress) => ListTile(
                            leading: const Icon(Icons.check_circle, color: Colors.green),
                            title: Text('例文ID: ${progress.sentenceId.substring(0, 8)}...'),
                            subtitle: progress.lastStudiedAt != null
                                ? Text('学習日: ${progress.lastStudiedAt!.toString().split(' ')[0]}')
                                : null,
                          )),
                    ],
                    if (studyingList.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          '学習中',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...studyingList.map((progress) => ListTile(
                            leading: const Icon(Icons.school, color: Colors.orange),
                            title: Text('例文ID: ${progress.sentenceId.substring(0, 8)}...'),
                            subtitle: progress.lastStudiedAt != null
                                ? Text('学習日: ${progress.lastStudiedAt!.toString().split(' ')[0]}')
                                : null,
                          )),
                    ],
                  ],
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
          ],
        ),
      ),
    );
  }
}
