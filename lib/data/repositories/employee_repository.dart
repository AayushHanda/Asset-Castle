import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee_model.dart';

class EmployeeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'employees';

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(_collection);

  Stream<List<EmployeeModel>> getAllEmployees({String? companyId}) {
    Query<Map<String, dynamic>> query = _ref.orderBy('name');
    if (companyId != null && companyId != 'system') {
      query = query.where('companyId', isEqualTo: companyId);
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => EmployeeModel.fromFirestore(doc)).toList(),
    );
  }

  Future<EmployeeModel> getEmployee(String id) async {
    final doc = await _ref.doc(id).get();
    if (!doc.exists) throw Exception('Employee not found');
    return EmployeeModel.fromFirestore(doc);
  }

  Future<String> addEmployee(EmployeeModel employee) async {
    final doc = await _ref.add(employee.toFirestore());
    return doc.id;
  }

  Future<void> updateEmployee(EmployeeModel employee) async {
    await _ref.doc(employee.id).update(employee.toFirestore());
  }

  Future<void> deleteEmployee(String id) async {
    // Check if employee has assigned assets
    final assets = await _firestore
        .collection('assets')
        .where('assignedEmployeeId', isEqualTo: id)
        .get();

    if (assets.docs.isNotEmpty) {
      throw Exception('Cannot delete: Employee has ${assets.docs.length} assigned assets');
    }

    await _ref.doc(id).delete();
  }

  Stream<List<EmployeeModel>> searchEmployees(String queryText, {String? companyId}) {
    final lowerQuery = queryText.toLowerCase();
    Query<Map<String, dynamic>> query = _ref.orderBy('name');
    if (companyId != null && companyId != 'system') {
      query = query.where('companyId', isEqualTo: companyId);
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => EmployeeModel.fromFirestore(doc))
          .where((emp) =>
              emp.name.toLowerCase().contains(lowerQuery) ||
              emp.email.toLowerCase().contains(lowerQuery) ||
              emp.department.toLowerCase().contains(lowerQuery) ||
              emp.designation.toLowerCase().contains(lowerQuery))
          .toList(),
    );
  }

  Stream<List<EmployeeModel>> filterByDepartment(String department) {
    return _ref
        .where('department', isEqualTo: department)
        .orderBy('name')
        .snapshots()
        .map(
      (snapshot) => snapshot.docs.map((doc) => EmployeeModel.fromFirestore(doc)).toList(),
    );
  }

  Future<void> updateAssetCount(String employeeId, int delta) async {
    await _ref.doc(employeeId).update({
      'assignedAssetCount': FieldValue.increment(delta),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<int> getEmployeeCount({String? companyId}) async {
    Query<Map<String, dynamic>> query = _ref;
    if (companyId != null && companyId != 'system') {
      query = query.where('companyId', isEqualTo: companyId);
    }
    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  Future<Map<String, int>> getDepartmentDistribution({String? companyId}) async {
    Query<Map<String, dynamic>> query = _ref;
    if (companyId != null && companyId != 'system') {
      query = query.where('companyId', isEqualTo: companyId);
    }
    final snapshot = await query.get();
    final Map<String, int> distribution = {};
    for (final doc in snapshot.docs) {
      final dept = (doc.data())['department'] as String? ?? 'Other';
      distribution[dept] = (distribution[dept] ?? 0) + 1;
    }
    return distribution;
  }

  Stream<int> watchEmployeeCount({String? companyId}) {
    Query<Map<String, dynamic>> query = _ref;
    if (companyId != null && companyId != 'system') {
      query = query.where('companyId', isEqualTo: companyId);
    }
    return query.snapshots().map((snapshot) => snapshot.docs.length);
  }

  Stream<Map<String, int>> watchDepartmentDistribution({String? companyId}) {
    Query<Map<String, dynamic>> query = _ref;
    if (companyId != null && companyId != 'system') {
      query = query.where('companyId', isEqualTo: companyId);
    }
    return query.snapshots().map((snapshot) {
      final Map<String, int> distribution = {};
      for (final doc in snapshot.docs) {
        final dept = (doc.data())['department'] as String? ?? 'Other';
        distribution[dept] = (distribution[dept] ?? 0) + 1;
      }
      return distribution;
    });
  }
}
