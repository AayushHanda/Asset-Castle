import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/asset_log_model.dart';
import '../../domain/enums/log_action.dart';

class AssetLogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'asset_logs';

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(_collection);

  Future<void> addLog(AssetLogModel log) async {
    await _ref.add(log.toFirestore());
  }

  Stream<List<AssetLogModel>> getLogsByAsset(String assetId) {
    return _ref
        .where('assetId', isEqualTo: assetId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
      (snapshot) => snapshot.docs.map((doc) => AssetLogModel.fromFirestore(doc)).toList(),
    );
  }

  Stream<List<AssetLogModel>> getRecentLogs({int limit = 20}) {
    return _ref
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
      (snapshot) => snapshot.docs.map((doc) => AssetLogModel.fromFirestore(doc)).toList(),
    );
  }

  Future<void> logAction({
    required String assetId,
    required String assetName,
    required LogAction action,
    required String performedBy,
    required String performedByName,
    String? employeeId,
    String? employeeName,
    String? notes,
  }) async {
    final log = AssetLogModel(
      id: '',
      assetId: assetId,
      assetName: assetName,
      action: action,
      employeeId: employeeId,
      employeeName: employeeName,
      performedBy: performedBy,
      performedByName: performedByName,
      notes: notes,
      timestamp: DateTime.now(),
    );
    await _ref.add(log.toFirestore());
  }
}
