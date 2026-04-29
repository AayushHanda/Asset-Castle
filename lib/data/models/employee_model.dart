import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/enums/user_role.dart';

class EmployeeModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String companyId;
  final String department;
  final String designation;
  final String? photoUrl;
  final int assignedAssetCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.employee,
    this.companyId = 'default',
    required this.department,
    required this.designation,
    this.photoUrl,
    this.assignedAssetCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmployeeModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.fromString(data['role'] ?? 'employee'),
      companyId: data['companyId'] ?? 'default',
      department: data['department'] ?? '',
      designation: data['designation'] ?? '',
      photoUrl: data['photoUrl'],
      assignedAssetCount: data['assignedAssetCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'companyId': companyId,
      'department': department,
      'designation': designation,
      'photoUrl': photoUrl,
      'assignedAssetCount': assignedAssetCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  EmployeeModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? companyId,
    String? department,
    String? designation,
    String? photoUrl,
    int? assignedAssetCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      companyId: companyId ?? this.companyId,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      photoUrl: photoUrl ?? this.photoUrl,
      assignedAssetCount: assignedAssetCount ?? this.assignedAssetCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
