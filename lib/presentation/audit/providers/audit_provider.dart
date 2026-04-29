import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/audit_log_model.dart';
import '../../../data/repositories/audit_log_repository.dart';

final auditRepoProvider = Provider((ref) => AuditLogRepository());

final auditLogsProvider = StreamProvider<List<AuditLogModel>>((ref) {
  return ref.watch(auditRepoProvider).getAuditLogs(limit: 100);
});

final auditFilterNotifierProvider = NotifierProvider<AuditFilterNotifier, String?>(() => AuditFilterNotifier());

class AuditFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? filter) => state = filter;
  void clear() => state = null;
}

final filteredAuditLogsProvider = Provider<AsyncValue<List<AuditLogModel>>>((ref) {
  final logs = ref.watch(auditLogsProvider);
  final filter = ref.watch(auditFilterNotifierProvider);

  return logs.whenData((list) {
    if (filter == null || filter.isEmpty) return list;
    return list.where((l) => l.entityType == filter).toList();
  });
});
