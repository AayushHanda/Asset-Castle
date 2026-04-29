import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/enums/log_action.dart';

class AssetLogModel {
  final String id;
  final String assetId;
  final String assetName;
  final LogAction action;
  final String? employeeId;
  final String? employeeName;
  final String performedBy;
  final String performedByName;
  final String? notes;
  final DateTime timestamp;

  const AssetLogModel({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.action,
    this.employeeId,
    this.employeeName,
    required this.performedBy,
    required this.performedByName,
    this.notes,
    required this.timestamp,
  });

  factory AssetLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AssetLogModel(
      id: doc.id,
      assetId: data['assetId'] ?? '',
      assetName: data['assetName'] ?? '',
      action: LogAction.fromString(data['action'] ?? 'updated'),
      employeeId: data['employeeId'],
      employeeName: data['employeeName'],
      performedBy: data['performedBy'] ?? '',
      performedByName: data['performedByName'] ?? '',
      notes: data['notes'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'assetId': assetId,
      'assetName': assetName,
      'action': action.name,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'performedBy': performedBy,
      'performedByName': performedByName,
      'notes': notes,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
