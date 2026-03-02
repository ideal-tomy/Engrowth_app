/// コンサルタント-クライアント権限（期間外閲覧等）
class ConsultantClientPermission {
  final String id;
  final String consultantId;
  final String clientId;
  final bool canViewHistorical;
  final DateTime? validFrom;
  final DateTime? validTo;
  final String? grantedBy;
  final DateTime createdAt;

  ConsultantClientPermission({
    required this.id,
    required this.consultantId,
    required this.clientId,
    this.canViewHistorical = false,
    this.validFrom,
    this.validTo,
    this.grantedBy,
    required this.createdAt,
  });

  factory ConsultantClientPermission.fromJson(Map<String, dynamic> json) {
    return ConsultantClientPermission(
      id: json['id'] as String,
      consultantId: json['consultant_id'] as String,
      clientId: json['client_id'] as String,
      canViewHistorical: json['can_view_historical'] as bool? ?? false,
      validFrom: json['valid_from'] != null
          ? DateTime.parse(json['valid_from'] as String)
          : null,
      validTo: json['valid_to'] != null
          ? DateTime.parse(json['valid_to'] as String)
          : null,
      grantedBy: json['granted_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
