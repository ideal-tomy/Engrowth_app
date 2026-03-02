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

  /// 提出に対する詳細ログ（session_uuid で user_sessions を取得）
  /// session_uuid がない場合は reason 付きで未連携を返す（UIで判別可能）
  Future<Map<String, dynamic>?> getSubmissionDetail(VoiceSubmission s) async {
    if (s.sessionUuid == null || s.sessionUuid!.isEmpty) {
      return {
        'reason': 'no_session_uuid',
        'reason_label': '提出時セッション未連携（古い提出または計測前）',
      };
    }

    try {
      final sessionRes = await _client
          .from('user_sessions')
          .select()
          .eq('id', s.sessionUuid!)
          .maybeSingle();

      if (sessionRes == null) {
        return {
          'reason': 'session_not_found',
          'reason_label': 'セッションが見つかりません（削除済みの可能性）',
        };
      }

      final ses = sessionRes as Map<String, dynamic>;

      // 直近7日の傾向（同一userのuser_sessionsから算出）
      Map<String, dynamic>? trend7d;
      try {
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        final trendRes = await _client
            .from('user_sessions')
            .select('duration_sec, retry_count')
            .eq('user_id', s.userId)
            .gte('session_timestamp', sevenDaysAgo.toIso8601String());

        final rows = trendRes as List;
        if (rows.isNotEmpty) {
          int totalDuration = 0;
          int totalRetry = 0;
          for (final r in rows) {
            final m = r as Map<String, dynamic>;
            totalDuration += m['duration_sec'] as int? ?? 0;
            totalRetry += m['retry_count'] as int? ?? 0;
          }
          trend7d = {
            'session_count': rows.length,
            'avg_duration_sec': rows.length > 0 ? (totalDuration / rows.length).round() : 0,
            'avg_retry_count': rows.length > 0 ? (totalRetry / rows.length).toStringAsFixed(1) : '0',
          };
        }
      } catch (_) {
        trend7d = null;
      }

      return {
        'device_os': ses['device_os'] as String?,
        'device_model': ses['device_model'] as String?,
        'device_type': ses['device_type'] as String?,
        'duration_sec': ses['duration_sec'] as int? ?? 0,
        'attempt_count': ses['attempt_count'] as int? ?? 0,
        'retry_count': ses['retry_count'] as int? ?? 0,
        'track': ses['track'] as String?,
        'trend_7d': trend7d,
      };
    } catch (e) {
      return {
        'reason': 'fetch_error',
        'reason_label': '取得エラー: $e',
      };
    }
  }

  /// 担当クライアントID一覧
  Future<List<String>> getAssignedClientIds() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    return _consultantService.getAssignedClientIds(uid);
  }

  /// 音声再生URL取得
  Future<String?> getPlaybackUrl(String audioUrl) async {
    return _submissionService.getSignedPlaybackUrl(audioUrl);
  }

  /// B15: 担当クライアントからの報告一覧
  Future<List<Map<String, dynamic>>> getClientReports() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];

    try {
      final clientIds = await _consultantService.getAssignedClientIds(uid);
      if (clientIds.isEmpty) return [];

      final res = await _client
          .from('client_reports')
          .select()
          .eq('consultant_id', uid)
          .inFilter('client_id', clientIds)
          .order('created_at', ascending: false)
          .limit(20);
      return (res as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('ConsultantDashboardService.getClientReports: $e');
      return [];
    }
  }
}
