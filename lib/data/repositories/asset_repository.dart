import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/asset_model.dart';
import '../../domain/enums/asset_status.dart';

class AssetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'assets';

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(_collection);

  Stream<List<AssetModel>> getAllAssets({String? companyId}) {
    Query<Map<String, dynamic>> query = _ref.orderBy('createdAt', descending: true);
    if (companyId != null && companyId != 'system') {
      query = query.where('companyId', isEqualTo: companyId);
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => AssetModel.fromFirestore(doc)).toList(),
    );
  }

  Future<AssetModel> getAsset(String id) async {
    final doc = await _ref.doc(id).get();
    if (!doc.exists) throw Exception('Asset not found');
    return AssetModel.fromFirestore(doc);
  }

  Future<String> addAsset(AssetModel asset) async {
    final doc = await _ref.add(asset.toFirestore());
    return doc.id;
  }

  Future<void> updateAsset(AssetModel asset) async {
    await _ref.doc(asset.id).update(asset.toFirestore());
  }

  Future<void> deleteAsset(String id) async {
    await _ref.doc(id).delete();
  }

  Future<void> assignAsset({
    required String assetId,
    required String employeeId,
    required String employeeName,
  }) async {
    await _ref.doc(assetId).update({
      'assignedEmployeeId': employeeId,
      'assignedEmployeeName': employeeName,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> unassignAsset(String assetId) async {
    await _ref.doc(assetId).update({
      'assignedEmployeeId': null,
      'assignedEmployeeName': null,
      'updatedAt': Timestamp.now(),
    });
  }

  Stream<List<AssetModel>> getAssetsByEmployee(String employeeId) {
    return _ref
        .where('assignedEmployeeId', isEqualTo: employeeId)
        .snapshots()
        .map(
      (snapshot) => snapshot.docs.map((doc) => AssetModel.fromFirestore(doc)).toList(),
    );
  }

  Stream<List<AssetModel>> getAssetsByStatus(AssetStatus status, {String? companyId}) {
    Query<Map<String, dynamic>> query = _ref.where('status', isEqualTo: status.name).orderBy('createdAt', descending: true);
    if (companyId != null && companyId != 'system') {
      query = query.where('companyId', isEqualTo: companyId);
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => AssetModel.fromFirestore(doc)).toList(),
    );
  }

  Stream<List<AssetModel>> getAssetsByCategory(String category) {
    return _ref
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
      (snapshot) => snapshot.docs.map((doc) => AssetModel.fromFirestore(doc)).toList(),
    );
  }

  Stream<List<AssetModel>> searchAssets(String queryText, {String? companyId}) {
    final lowerQuery = queryText.toLowerCase();
    Query<Map<String, dynamic>> query = _ref.orderBy('name');
    if (companyId != null && companyId != 'system') {
      query = query.where('companyId', isEqualTo: companyId);
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => AssetModel.fromFirestore(doc))
          .where((asset) =>
              asset.name.toLowerCase().contains(lowerQuery) ||
              asset.serialNumber.toLowerCase().contains(lowerQuery) ||
              asset.category.toLowerCase().contains(lowerQuery))
          .toList(),
    );
  }

  Future<void> updateLastScanned(String assetId, GeoPoint? location) async {
    await _ref.doc(assetId).update({
      'lastScannedAt': Timestamp.now(),
      'lastScannedLocation': location,
    });
  }

  // Analytics
  Future<Map<String, int>> getStatusCounts({String? companyId}) async {
    Query<Map<String, dynamic>> query = _ref;
    if (companyId != null && companyId != 'system') {
      query = query.where('companyId', isEqualTo: companyId);
    }
    
    final snapshot = await query.get();
    final Map<String, int> counts = {
      'total': snapshot.docs.length,
      'active': 0,
      'repair': 0,
      'retired': 0,
      'assigned': 0,
      'unassigned': 0,
    };
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final status = data['status'] as String? ?? 'active';
      counts[status] = (counts[status] ?? 0) + 1;
      if (data['assignedEmployeeId'] != null && (data['assignedEmployeeId'] as String).isNotEmpty) {
        counts['assigned'] = (counts['assigned'] ?? 0) + 1;
      } else {
        counts['unassigned'] = (counts['unassigned'] ?? 0) + 1;
      }
    }
    return counts;
  }

  Future<Map<String, int>> getCategoryDistribution({String? companyId}) async {
    Query<Map<String, dynamic>> query = _ref;
    if (companyId != null && companyId != 'system') {
      query = query.where('companyId', isEqualTo: companyId);
    }
    
    final snapshot = await query.get();
    final Map<String, int> distribution = {};
    for (final doc in snapshot.docs) {
      final category = (doc.data())['category'] as String? ?? 'Other';
      distribution[category] = (distribution[category] ?? 0) + 1;
    }
    return distribution;
  }

  Future<int> getAssetCount({String? companyId}) async {
    Query<Map<String, dynamic>> query = _ref;
    if (companyId != null && companyId != 'system') {
      query = query.where('companyId', isEqualTo: companyId);
    }
    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  Stream<Map<String, int>> watchStatusCounts({String? companyId}) {
    Query<Map<String, dynamic>> query = _ref;
    if (companyId != null && companyId != 'system') {
      query = query.where('companyId', isEqualTo: companyId);
    }
    return query.snapshots().map((snapshot) {
      final Map<String, int> counts = {
        'total': snapshot.docs.length,
        'active': 0,
        'repair': 0,
        'retired': 0,
        'assigned': 0,
        'unassigned': 0,
      };
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? 'active';
        counts[status] = (counts[status] ?? 0) + 1;
        if (data['assignedEmployeeId'] != null && (data['assignedEmployeeId'] as String).isNotEmpty) {
          counts['assigned'] = (counts['assigned'] ?? 0) + 1;
        } else {
          counts['unassigned'] = (counts['unassigned'] ?? 0) + 1;
        }
      }
      return counts;
    });
  }

  Stream<Map<String, int>> watchCategoryDistribution({String? companyId}) {
    Query<Map<String, dynamic>> query = _ref;
    if (companyId != null && companyId != 'system') {
      query = query.where('companyId', isEqualTo: companyId);
    }
    return query.snapshots().map((snapshot) {
      final Map<String, int> distribution = {};
      for (final doc in snapshot.docs) {
        final category = (doc.data())['category'] as String? ?? 'Other';
        distribution[category] = (distribution[category] ?? 0) + 1;
      }
      return distribution;
    });
  }
}
