import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'progress_provider.dart';

/// 学習セッション分析結果
class ProgressAnalysis {
  final int totalCount;
  final int masteredCount;
  final int hintDependentCount; // ヒントで習得した数
  final double masteredRate;
  final double hintDependentRate; // 習得済みのうちヒント依存の割合

  ProgressAnalysis({
    required this.totalCount,
    required this.masteredCount,
    required this.hintDependentCount,
    required this.masteredRate,
    required this.hintDependentRate,
  });

  static ProgressAnalysis empty() => ProgressAnalysis(
    totalCount: 0,
    masteredCount: 0,
    hintDependentCount: 0,
    masteredRate: 0.0,
    hintDependentRate: 0.0,
  );
}

/// 学習セッション分析プロバイダー
/// user_progress から習得率・ヒント依存度を算出
final progressAnalysisProvider = FutureProvider<ProgressAnalysis>((ref) async {
  final list = await ref.read(userProgressProvider.future);
  if (list.isEmpty) return ProgressAnalysis.empty();

  final total = list.length;
  final mastered = list.where((p) => p.isMastered).toList();
  final hintDependent = mastered.where((p) => p.usedHintToMaster).length;

  return ProgressAnalysis(
    totalCount: total,
    masteredCount: mastered.length,
    hintDependentCount: hintDependent,
    masteredRate: total > 0 ? mastered.length / total : 0.0,
    hintDependentRate: mastered.isNotEmpty ? hintDependent / mastered.length : 0.0,
  );
});
