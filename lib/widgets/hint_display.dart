import 'package:flutter/material.dart';
import '../models/hint_phase.dart';
import '../models/sentence.dart';

class HintDisplay extends StatelessWidget {
  final String fullText;
  final HintPhase phase;
  final double opacity;
  final List<String>? targetWords;

  const HintDisplay({
    super.key,
    required this.fullText,
    required this.phase,
    required this.opacity,
    this.targetWords,
  });

  @override
  Widget build(BuildContext context) {
    if (phase == HintPhase.none) {
      return const SizedBox.shrink();
    }

    final hintText = _getHintText(fullText, phase, targetWords);

    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
      child: AnimatedSlide(
        offset: Offset(0, phase == HintPhase.none ? -10 : 0),
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: _buildHintContent(hintText, phase),
        ),
      ),
    );
  }

  Widget _buildHintContent(String hintText, HintPhase phase) {
    if (phase == HintPhase.keywords && targetWords != null && targetWords!.isNotEmpty) {
      // 重要単語をハイライト表示
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: targetWords!.map((word) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blue.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Text(
              word,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          );
        }).toList(),
      );
    }

    return Text(
      hintText,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.blue.shade700,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  String _getHintText(String fullText, HintPhase phase, List<String>? targetWords) {
    final words = fullText.split(' ');
    
    switch (phase) {
      case HintPhase.initial:
        if (words.isNotEmpty) {
          final firstWord = words[0];
          if (firstWord.isNotEmpty) {
            return '${firstWord[0]}...';
          }
        }
        return '';
        
      case HintPhase.extended:
        if (words.length >= 3) {
          return '${words.take(3).join(' ')}...';
        } else if (words.isNotEmpty) {
          return words.join(' ');
        }
        return '';
        
      case HintPhase.keywords:
        if (targetWords != null && targetWords!.isNotEmpty) {
          return targetWords!.join(', ');
        }
        // ターゲット単語がない場合は、最初の3単語を表示
        if (words.length >= 3) {
          return words.take(3).join(' ');
        }
        return fullText;
        
      default:
        return '';
    }
  }
}
