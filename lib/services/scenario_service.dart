import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/scenario.dart';
import '../models/sentence.dart';

/// シナリオサービス
class ScenarioService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 全シナリオを取得
  Future<List<Scenario>> getScenarios() async {
    try {
      final response = await _supabase
          .from('scenarios')
          .select()
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => Scenario.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting scenarios: $e');
      rethrow;
    }
  }

  /// シナリオのステップ（例文）を取得
  Future<List<ScenarioStep>> getScenarioSteps(String scenarioId) async {
    try {
      final response = await _supabase
          .from('scenario_steps')
          .select()
          .eq('scenario_id', scenarioId)
          .order('order_index', ascending: true);

      return (response as List)
          .map((json) => ScenarioStep.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting scenario steps: $e');
      rethrow;
    }
  }

  /// シナリオのステップに対応する例文を取得
  Future<List<Sentence>> getScenarioSentences(String scenarioId) async {
    try {
      final steps = await getScenarioSteps(scenarioId);
      if (steps.isEmpty) return [];

      final sentenceIds = steps.map((s) => s.sentenceId).toList();
      final response = await _supabase
          .from('sentences')
          .select()
          .inFilter('id', sentenceIds);

      final sentences = (response as List)
          .map((json) => Sentence.fromJson(json))
          .toList();

      // order_indexの順序でソート
      final sentenceMap = {for (var s in sentences) s.id: s};
      return steps
          .map((step) => sentenceMap[step.sentenceId])
          .whereType<Sentence>()
          .toList();
    } catch (e) {
      print('Error getting scenario sentences: $e');
      rethrow;
    }
  }

  /// ユーザーのシナリオ進捗を取得
  Future<UserScenarioProgress?> getUserProgress(String userId, String scenarioId) async {
    try {
      final response = await _supabase
          .from('user_scenario_progress')
          .select()
          .eq('user_id', userId)
          .eq('scenario_id', scenarioId)
          .maybeSingle();

      if (response == null) return null;
      return UserScenarioProgress.fromJson(response);
    } catch (e) {
      print('Error getting user scenario progress: $e');
      rethrow;
    }
  }

  /// シナリオ進捗を更新
  Future<UserScenarioProgress> updateProgress({
    required String userId,
    required String scenarioId,
    required int stepIndex,
    bool completed = false,
  }) async {
    try {
      final now = DateTime.now();
      
      final response = await _supabase
          .from('user_scenario_progress')
          .upsert({
            'user_id': userId,
            'scenario_id': scenarioId,
            'last_step_index': stepIndex,
            'completed_at': completed ? now.toIso8601String() : null,
          })
          .select()
          .single();

      return UserScenarioProgress.fromJson(response);
    } catch (e) {
      print('Error updating scenario progress: $e');
      rethrow;
    }
  }
}
