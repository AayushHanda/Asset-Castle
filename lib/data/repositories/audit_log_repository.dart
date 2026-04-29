import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/audit_log_model.dart';

class AuditLogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'audit_logs';

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(_collection);

  Future<void> log({
    required String userId,
    required String userName,
    required String action,
    required String entityType,
    required String entityId,
    required String entityName,
    String? details,
  }) async {
    final auditLog = AuditLogModel(
      id: '',
      userId: userId,
      userName: userName,
      action: action,
      entityType: entityType,
      entityId: entityId,
      entityName: entityName,
      details: details,
      timestamp: DateTime.now(),
    );
    await _ref.add(auditLog.toFirestore());
  }

  Stream<List<AuditLogModel>> getAuditLogs({int limit = 50}) {
    return _ref
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
      (snapshot) => snapshot.docs.map((doc) => AuditLogModel.fromFirestore(doc)).toList(),
    );
  }

  Stream<List<AuditLogModel>> getLogsByEntity(String entityId) {
    return _ref
        .where('entityId', isEqualTo: entityId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
      (snapshot) => snapshot.docs.map((doc) => AuditLogModel.fromFirestore(doc)).toList(),
    );
  }

  Stream<List<AuditLogModel>> getLogsByUser(String userId) {
    return _ref
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
      (snapshot) => snapshot.docs.map((doc) => AuditLogModel.fromFirestore(doc)).toList(),
    );
  }
}
