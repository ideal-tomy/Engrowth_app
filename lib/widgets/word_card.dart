import 'package:flutter/material.dart';
import '../models/word.dart';

class WordCard extends StatelessWidget {
  final Word word;
  final VoidCallback? onTap;

  const WordCard({
    super.key,
    required this.word,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    word.word,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (word.partOfSpeech != null)
                    Chip(
                      label: Text(
                        word.partOfSpeech!,
                        style: const TextStyle(fontSize: 12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                word.meaning,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              if (word.wordGroup != null) ...[
                const SizedBox(height: 8),
                Text(
                  'グループ: ${word.wordGroup}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
