import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_audit_service.dart';
import '../services/admin_permission_service.dart';
import '../services/mission_delivery_demo_service.dart';

final adminPermissionServiceProvider = Provider<AdminPermissionService>((ref) {
  return AdminPermissionService();
});

final adminAuditServiceProvider = Provider<AdminAuditService>((ref) {
  return AdminAuditService();
});

final consultantSummariesProvider =
    FutureProvider<Map<String, ConsultantAssignmentSummary>>((ref) async {
  final service = ref.watch(adminPermissionServiceProvider);
  return service.getConsultantSummaries();
});

typedef AuditLogFilters = ({DateTime? from, DateTime? to, String? resourceType});

final auditLogFiltersProvider = StateProvider<AuditLogFilters?>((ref) => null);

final auditLogsProvider = FutureProvider<List<AccessAuditLog>>((ref) async {
  final filters = ref.watch(auditLogFiltersProvider);
  final service = ref.watch(adminAuditServiceProvider);
  return service.getAuditLogs(
    from: filters?.from,
    to: filters?.to,
    resourceType: filters?.resourceType,
  );
});

final missionDeliveryDemoServiceProvider = Provider<MissionDeliveryDemoService>((ref) {
  return MissionDeliveryDemoService();
});

final missionDeliveryDemosProvider = FutureProvider<List<MissionDeliveryDemo>>((ref) async {
  final service = ref.watch(missionDeliveryDemoServiceProvider);
  return service.getRecentMissionsWithDemoStatus();
});
