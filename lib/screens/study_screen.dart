import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/study_card.dart';
import '../providers/sentence_provider.dart';
import '../providers/progress_provider.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final sentencesAsync = ref.watch(studySentencesProvider);
    final progressNotifier = ref.read(progressNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('学習モード'),
        actions: [
          sentencesAsync.when(
            data: (sentences) => Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text('${_currentIndex + 1} / ${sentences.length}'),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: sentencesAsync.when(
        data: (sentences) {
          if (sentences.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '例文がまだ登録されていません',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (_currentIndex >= sentences.length) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'すべての例文を学習しました！',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          final currentSentence = sentences[_currentIndex];

          return StudyCard(
            sentence: currentSentence,
            onMastered: () {
              progressNotifier.updateProgress(
                sentenceId: currentSentence.id,
                isMastered: true,
              );
              _showSnackBar(context, '覚えた！');
              _nextSentence(sentences.length);
            },
            onNext: () {
              _nextSentence(sentences.length);
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

  void _nextSentence(int total) {
    if (_currentIndex < total - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      setState(() {
        _currentIndex = total;
      });
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
