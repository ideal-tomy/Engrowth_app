import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/consultant_assignment.dart';
import '../models/coach_mission.dart';
import '../models/feedback_template.dart';
import '../models/daily_summary.dart';

class ConsultantService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<String>> getAssignedClientIds(String consultantId) async {
    try {
      final res = await _client
          .from('consultant_assignments')
          .select('client_id')
          .eq('consultant_id', consultantId)
          .eq('status', 'active');
      return (res as List)
          .map((e) => e['client_id'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<CoachMission?> getTodaysMission(String clientId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final res = await _client
          .from('coach_missions')
          .select()
          .eq('client_id', clientId)
          .eq('mission_date', today)
          .maybeSingle();
      if (res == null) return null;
      return CoachMission.fromJson(res as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> createMission({
    required String clientId,
    required String missionText,
    String? actionRoute,
    DateTime? missionDate,
  }) async {
    final date = missionDate ?? DateTime.now();
    final dateStr = date.toIso8601String().split('T')[0];
    await _client.from('coach_missions').upsert({
      'client_id': clientId,
      'consultant_id': _client.auth.currentUser?.id,
      'mission_text': missionText,
      'action_route': actionRoute,
      'mission_date': dateStr,
    }, onConflict: 'client_id,mission_date');
  }

  Future<List<FeedbackTemplate>> getFeedbackTemplates() async {
    try {
      final uid = _client.auth.currentUser?.id;
      final res = await _client
          .from('feedback_templates')
          .select()
          .or('consultant_id.is.null,consultant_id.eq.$uid');
      return (res as List)
          .map((e) => FeedbackTemplate.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> createFeedbackTemplate({
    required String name,
    required String content,
    String? category,
  }) async {
    await _client.from('feedback_templates').insert({
      'consultant_id': _client.auth.currentUser?.id,
      'name': name,
      'content': content,
      'category': category,
    });
  }

  Future<DailySummary?> getTodaysSummary(String clientId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final res = await _client
          .from('daily_summaries')
          .select()
          .eq('client_id', clientId)
          .eq('summary_date', today)
          .maybeSingle();
      if (res == null) return null;
      return DailySummary.fromJson(res as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> createDailySummary({
    required String clientId,
    required String content,
    Map<String, dynamic>? stats,
  }) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await _client.from('daily_summaries').upsert({
      'client_id': clientId,
      'consultant_id': _client.auth.currentUser?.id,
      'summary_date': today,
      'content': content,
      'stats': stats,
      'posted_at': DateTime.now().toIso8601String(),
    }, onConflict: 'client_id,summary_date');
  }
}
