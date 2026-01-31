import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/sentence.dart';

class StudyCard extends StatefulWidget {
  final Sentence sentence;
  final VoidCallback? onMastered;
  final VoidCallback? onNext;

  const StudyCard({
    super.key,
    required this.sentence,
    this.onMastered,
    this.onNext,
  });

  @override
  State<StudyCard> createState() => _StudyCardState();
}

class _StudyCardState extends State<StudyCard> {
  bool _showJapanese = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 画像
          if (widget.sentence.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: widget.sentence.imageUrl!,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 300,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 300,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, size: 48),
                ),
              ),
            )
          else
            Container(
              height: 300,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.image, size: 64, color: Colors.grey),
              ),
            ),
          
          // 例文
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  widget.sentence.englishText,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_showJapanese)
                  Text(
                    widget.sentence.japaneseText,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  )
                else
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showJapanese = true;
                      });
                    },
                    child: const Text('日本語を表示'),
                  ),
              ],
            ),
          ),
          
          // ボタン
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: widget.onNext,
                  child: const Text('次へ'),
                ),
                ElevatedButton(
                  onPressed: widget.onMastered,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('覚えた！'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
