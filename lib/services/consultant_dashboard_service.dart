import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/voice_submission.dart';
import 'voice_submission_service.dart';
import 'consultant_service.dart';

/// コンサルタントダッシュボード用サービス
/// 提出キュー・KPI・詳細ログ取得
class ConsultantDashboardService {
  final SupabaseClient _client = Supabase.instance.client;
  final VoiceSubmissionService _submissionService = VoiceSubmissionService();
  final ConsultantService _consultantService = ConsultantService();

  /// メイン提出キュー（submission_type=submitted、担当クライアントのみ）
  Future<List<VoiceSubmission>> getSubmittedQueue() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];

    final clientIds = await _consultantService.getAssignedClientIds(uid);

    try {
      final response = await _client
          .from('voice_submissions')
          .select()
          .eq('submission_type', 'submitted')
          .order('created_at', ascending: false);

      var list = (response as List)
          .map((e) => VoiceSubmission.fromJson(e as Map<String, dynamic>))
          .toList();

      // 担当割当ありの場合は担当クライアントのみに絞る
      if (clientIds.isNotEmpty) {
        final idSet = clientIds.toSet();
        list = list.where((s) => idSet.contains(s.userId)).toList();
      }

      return list;
    } catch (e) {
      print('ConsultantDashboardService.getSubmittedQueue: $e');
      return [];
    }
  }

  /// KPI: 未対応件数, 本日対応数, 担当クライアント数
  Future<Map<String, int>> getKpis() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      return {'pending': 0, 'today_reviewed': 0, 'assigned_clients': 0};
    }

    final clientIds = await _consultantService.getAssignedClientIds(uid);

    try {
      final response = await _client
          .from('voice_submissions')
          .select('id, user_id, review_status, reviewed_at')
          .eq('submission_type', 'submitted');

      var rows = response as List;

      // 担当割当ありの場合は担当クライアントのみに絞る
      if (clientIds.isNotEmpty) {
        final idSet = clientIds.toSet();
        rows = rows
            .where((r) => idSet.contains((r as Map<String, dynamic>)['user_id']))
            .toList();
      }
      int pending = 0;
      int todayReviewed = 0;
      final today = DateTime.now().toIso8601String().split('T')[0];

      for (final r in rows) {
        final map = r as Map<String, dynamic>;
        if (map['review_status'] == 'pending') pending++;
        final reviewedAt = map['reviewed_at'] as String?;
        if (reviewedAt != null && reviewedAt.startsWith(today)) {
          todayReviewed++;
        }
      }

      return {
        'pending': pending,
        'today_reviewed': todayReviewed,
        'assigned_clients': clientIds.length,
      };
    } catch (e) {
      return {'pending': 0, 'today_reviewed': 0, 'assigned_clients': 0};
    }
  }

  /// 提出に対する詳細ログ（user_sessions があれば取得、なければ空）
  /// Phase A 適用後は session_uuid で user_sessions を取得
  Future<Map<String, dynamic>?> getSubmissionDetail(VoiceSubmission s) async {
    // TODO: user_sessions 導入後に session_uuid で紐づけ
    return null;
  }

  /// 音声再生URL取得
  Future<String?> getPlaybackUrl(String audioUrl) async {
    return _submissionService.getSignedPlaybackUrl(audioUrl);
  }
}
