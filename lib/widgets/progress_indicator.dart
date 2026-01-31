import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  final int mastered;
  final int total;
  final String label;

  const CustomProgressIndicator({
    super.key,
    required this.mastered,
    required this.total,
    this.label = '進捗',
  });

  double get progress => total > 0 ? mastered / total : 0.0;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$mastered / $total (${(progress * 100).toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
