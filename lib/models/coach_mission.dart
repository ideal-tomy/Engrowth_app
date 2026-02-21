class CoachMission {
  final String id;
  final String clientId;
  final String? consultantId;
  final String missionText;
  final String? actionRoute;
  final DateTime missionDate;
  final DateTime createdAt;

  CoachMission({
    required this.id,
    required this.clientId,
    this.consultantId,
    required this.missionText,
    this.actionRoute,
    required this.missionDate,
    required this.createdAt,
  });

  factory CoachMission.fromJson(Map<String, dynamic> json) {
    return CoachMission(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      consultantId: json['consultant_id'] as String?,
      missionText: json['mission_text'] as String,
      actionRoute: json['action_route'] as String?,
      missionDate: DateTime.parse(json['mission_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
