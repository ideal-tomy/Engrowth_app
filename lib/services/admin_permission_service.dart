import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/consultant_assignment.dart';
import 'admin_audit_service.dart';

/// 管理者向け権限付与サービス
/// consultant_assignments / consultant_client_permissions の CRUD
class AdminPermissionService {
  final SupabaseClient _client = Supabase.instance.client;
  final AdminAuditService _auditService = AdminAuditService();

  /// コンサルタントごとの担当クライアント数を取得
  /// 戻り値: { consultantId: { clientCount, clientIds, assignments } }
  Future<Map<String, ConsultantAssignmentSummary>> getConsultantSummaries() async {
    try {
      final res = await _client
          .from('consultant_assignments')
          .select()
          .eq('status', 'active')
          .order('assigned_at', ascending: false);

      final rows = res as List;
      final map = <String, ConsultantAssignmentSummary>{};

      for (final r in rows) {
        final m = r as Map<String, dynamic>;
        final consultantId = m['consultant_id'] as String;
        final clientId = m['client_id'] as String;

        map.putIfAbsent(consultantId, () => ConsultantAssignmentSummary(
          consultantId: consultantId,
          clientIds: [],
          assignments: [],
        ));

        final a = ConsultantAssignment.fromJson(m);
        map[consultantId]!.clientIds.add(clientId);
        map[consultantId]!.assignments.add(a);
      }

      return map;
    } catch (_) {
      return {};
    }
  }

  /// 権限を付与（consultant_assignments に追加）
  Future<void> grantAssignment({
    required String consultantId,
    required String clientId,
  }) async {
    await _client.from('consultant_assignments').upsert({
      'consultant_id': consultantId,
      'client_id': clientId,
      'status': 'active',
    }, onConflict: 'consultant_id,client_id');

    await _auditService.logPermissionChange(
      action: 'permission_grant',
      consultantId: consultantId,
      clientId: clientId,
      details: {'status': 'active'},
    );
  }

  /// 権限を取り消し（status を inactive に）
  Future<void> revokeAssignment(String assignmentId, String consultantId, String clientId) async {
    await _client
        .from('consultant_assignments')
        .update({'status': 'inactive'})
        .eq('id', assignmentId);

    await _auditService.logPermissionChange(
      action: 'permission_revoke',
      consultantId: consultantId,
      clientId: clientId,
      permissionId: assignmentId,
    );
  }
}

/// コンサルタントごとのサマリ
class ConsultantAssignmentSummary {
  final String consultantId;
  final List<String> clientIds;
  final List<ConsultantAssignment> assignments;

  ConsultantAssignmentSummary({
    required this.consultantId,
    required this.clientIds,
    required this.assignments,
  });

  int get clientCount => clientIds.length;
}
