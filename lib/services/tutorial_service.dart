import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tutorial.dart';

/// チュートリアル用サービス（事前生成音声で低遅延体験）
class TutorialService {
  final _client = Supabase.instance.client;

  /// 最初のチュートリアルを1件取得（display_order 昇順）
  Future<Tutorial?> getFirstTutorial() async {
    try {
      final res = await _client
          .from('tutorials')
          .select()
          .order('display_order', ascending: true)
          .limit(1)
          .maybeSingle();
      return res == null ? null : Tutorial.fromJson(res as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// 1セッション分のチュートリアルを取得（ステップ＋返答を含む）
  Future<TutorialSession?> getTutorialSession(String tutorialId) async {
    try {
      final tutorialRes = await _client
          .from('tutorials')
          .select()
          .eq('id', tutorialId)
          .maybeSingle();
      if (tutorialRes == null) return null;
      final tutorial = Tutorial.fromJson(tutorialRes as Map<String, dynamic>);

      final stepsRes = await _client
          .from('tutorial_steps')
          .select()
          .eq('tutorial_id', tutorialId)
          .order('step_order', ascending: true);
      final steps = (stepsRes as List)
          .map((e) => TutorialStep.fromJson(e as Map<String, dynamic>))
          .toList();
      if (steps.isEmpty) return null;

      final stepIds = steps.map((s) => s.id).toList();
      final responsesRes = await _client
          .from('tutorial_step_responses')
          .select()
          .inFilter('tutorial_step_id', stepIds);

      final byStepId = <String, List<TutorialStepResponse>>{};
      for (final row in responsesRes as List) {
        final r = TutorialStepResponse.fromJson(row as Map<String, dynamic>);
        byStepId.putIfAbsent(r.tutorialStepId, () => []).add(r);
      }

      return TutorialSession(
        tutorial: tutorial,
        steps: steps,
        responsesByStepId: byStepId,
      );
    } catch (_) {
      return null;
    }
  }
}
