import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/enums/asset_status.dart';

class AssetModel {
  final String id;
  final String name;
  final String category;
  final String serialNumber;
  final DateTime purchaseDate;
  final AssetStatus status;
  final String companyId;
  final String? assignedEmployeeId;
  final String? assignedEmployeeName;
  final String? imageUrl;
  final String? notes;
  final double? purchasePrice;
  final GeoPoint? lastScannedLocation;
  final DateTime? lastScannedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AssetModel({
    required this.id,
    required this.name,
    required this.category,
    required this.serialNumber,
    required this.purchaseDate,
    required this.status,
    required this.companyId,
    this.assignedEmployeeId,
    this.assignedEmployeeName,
    this.imageUrl,
    this.notes,
    this.purchasePrice,
    this.lastScannedLocation,
    this.lastScannedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAssigned => assignedEmployeeId != null && assignedEmployeeId!.isNotEmpty;

  factory AssetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AssetModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      serialNumber: data['serialNumber'] ?? '',
      purchaseDate: (data['purchaseDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: AssetStatus.fromString(data['status'] ?? 'active'),
      companyId: data['companyId'] ?? 'default',
      assignedEmployeeId: data['assignedEmployeeId'],
      assignedEmployeeName: data['assignedEmployeeName'],
      imageUrl: data['imageUrl'],
      notes: data['notes'],
      purchasePrice: (data['purchasePrice'] as num?)?.toDouble(),
      lastScannedLocation: data['lastScannedLocation'] as GeoPoint?,
      lastScannedAt: (data['lastScannedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'serialNumber': serialNumber,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'status': status.name,
      'companyId': companyId,
      'assignedEmployeeId': assignedEmployeeId,
      'assignedEmployeeName': assignedEmployeeName,
      'imageUrl': imageUrl,
      'notes': notes,
      'purchasePrice': purchasePrice,
      'lastScannedLocation': lastScannedLocation,
      'lastScannedAt': lastScannedAt != null ? Timestamp.fromDate(lastScannedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AssetModel copyWith({
    String? id,
    String? name,
    String? category,
    String? serialNumber,
    DateTime? purchaseDate,
    AssetStatus? status,
    String? companyId,
    String? assignedEmployeeId,
    String? assignedEmployeeName,
    String? imageUrl,
    String? notes,
    double? purchasePrice,
    GeoPoint? lastScannedLocation,
    DateTime? lastScannedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      serialNumber: serialNumber ?? this.serialNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      status: status ?? this.status,
      companyId: companyId ?? this.companyId,
      assignedEmployeeId: assignedEmployeeId ?? this.assignedEmployeeId,
      assignedEmployeeName: assignedEmployeeName ?? this.assignedEmployeeName,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      lastScannedLocation: lastScannedLocation ?? this.lastScannedLocation,
      lastScannedAt: lastScannedAt ?? this.lastScannedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
