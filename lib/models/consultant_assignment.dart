class ConsultantAssignment {
  final String id;
  final String consultantId;
  final String clientId;
  final DateTime assignedAt;
  final String status;
  final String? notes;

  ConsultantAssignment({
    required this.id,
    required this.consultantId,
    required this.clientId,
    required this.assignedAt,
    this.status = 'active',
    this.notes,
  });

  factory ConsultantAssignment.fromJson(Map<String, dynamic> json) {
    return ConsultantAssignment(
      id: json['id'] as String,
      consultantId: json['consultant_id'] as String,
      clientId: json['client_id'] as String,
      assignedAt: DateTime.parse(json['assigned_at'] as String),
      status: json['status'] as String? ?? 'active',
      notes: json['notes'] as String?,
    );
  }
}
