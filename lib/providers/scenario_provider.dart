import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/scenario.dart';
import '../models/sentence.dart';
import '../services/scenario_service.dart';

/// シナリオサービスプロバイダ
final scenarioServiceProvider = Provider<ScenarioService>((ref) {
  return ScenarioService();
});

/// 全シナリオプロバイダ
final scenariosProvider = FutureProvider<List<Scenario>>((ref) async {
  final service = ref.read(scenarioServiceProvider);
  return await service.getScenarios();
});

/// シナリオのステッププロバイダ
final scenarioStepsProvider = FutureProvider.family<List<ScenarioStep>, String>((ref, scenarioId) async {
  final service = ref.read(scenarioServiceProvider);
  return await service.getScenarioSteps(scenarioId);
});

/// シナリオの例文プロバイダ
final scenarioSentencesProvider = FutureProvider.family<List<Sentence>, String>((ref, scenarioId) async {
  final service = ref.read(scenarioServiceProvider);
  return await service.getScenarioSentences(scenarioId);
});

/// ユーザーのシナリオ進捗プロバイダ
final userScenarioProgressProvider = FutureProvider.family<UserScenarioProgress?, String>((ref, scenarioId) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return null;

  final service = ref.read(scenarioServiceProvider);
  return await service.getUserProgress(userId, scenarioId);
});
