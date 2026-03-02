import 'package:supabase_flutter/supabase_flutter.dart';

/// 監査ログ1件
class AccessAuditLog {
  final String id;
  final String viewerId;
  final String targetUserId;
  final String? resourceType;
  final String? resourceId;
  final DateTime accessedAt;
  final Map<String, dynamic> metadata;

  AccessAuditLog({
    required this.id,
    required this.viewerId,
    required this.targetUserId,
    this.resourceType,
    this.resourceId,
    required this.accessedAt,
    this.metadata = const {},
  });

  factory AccessAuditLog.fromJson(Map<String, dynamic> json) {
    return AccessAuditLog(
      id: json['id'] as String,
      viewerId: json['viewer_id'] as String,
      targetUserId: json['target_user_id'] as String,
      resourceType: json['resource_type'] as String?,
      resourceId: json['resource_id'] as String?,
      accessedAt: DateTime.parse(json['accessed_at'] as String),
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  String get actionLabel {
    final action = metadata['action'] as String?;
    if (action != null) {
      switch (action) {
        case 'permission_grant':
          return '権限付与';
        case 'permission_revoke':
          return '権限取り消し';
      }
    }
    return resourceType ?? '閲覧';
  }
}

/// 監査ログ記録・取得サービス
/// access_audit_logs への書き込み・読み取り
class AdminAuditService {
  final SupabaseClient _client = Supabase.instance.client;

  /// 権限変更を監査ログに記録
  Future<void> logPermissionChange({
    required String action,
    required String consultantId,
    required String clientId,
    String? permissionId,
    Map<String, dynamic>? details,
  }) async {
    final actorId = _client.auth.currentUser?.id;
    if (actorId == null) return;

    try {
      await _client.from('access_audit_logs').insert({
        'viewer_id': actorId,
        'target_user_id': consultantId,
        'resource_type': 'permission',
        'resource_id': permissionId,
        'metadata': {
          'client_id': clientId,
          'action': action,
          if (details != null) ...details,
        },
      });
    } catch (_) {
      // テーブル未作成や権限エラー時は無視
    }
  }

  /// 監査ログ一覧を取得（新着順）
  Future<List<AccessAuditLog>> getAuditLogs({
    int limit = 50,
    DateTime? from,
    DateTime? to,
    String? resourceType,
  }) async {
    try {
      var query = _client.from('access_audit_logs').select();

      if (from != null) {
        query = query.gte('accessed_at', from.toIso8601String());
      }
      if (to != null) {
        query = query.lte('accessed_at', to.toIso8601String());
      }
      if (resourceType != null && resourceType.isNotEmpty) {
        query = query.eq('resource_type', resourceType);
      }

      final res = await query
          .order('accessed_at', ascending: false)
          .limit(limit);
      return (res as List)
          .map((e) => AccessAuditLog.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
