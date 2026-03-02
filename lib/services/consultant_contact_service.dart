import 'package:supabase_flutter/supabase_flutter.dart';
import 'consultant_service.dart';

/// B15: クライアント→担当コンサルタントの連絡・報告
class ConsultantContactService {
  final SupabaseClient _client = Supabase.instance.client;
  final ConsultantService _consultantService = ConsultantService();

  /// 担当コンサルタントID一覧（先頭を優先）
  Future<List<String>> getAssignedConsultantIds() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    return _consultantService.getAssignedConsultantIds(uid);
  }

  /// アプリ内クイック報告を送信（提出コンテキスト付き）
  Future<void> sendReport({
    required String consultantId,
    required String reportType,
    required String message,
    String? relatedSubmissionId,
  }) async {
    final clientId = _client.auth.currentUser?.id;
    if (clientId == null) throw StateError('未ログイン');

    await _client.from('client_reports').insert({
      'client_id': clientId,
      'consultant_id': consultantId,
      'report_type': reportType,
      'message': message,
      if (relatedSubmissionId != null) 'related_submission_id': relatedSubmissionId,
    });
  }
}
