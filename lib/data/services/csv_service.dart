import 'dart:io';
import 'package:csv/csv.dart' show CsvToListConverter, ListToCsvConverter;
import '../models/asset_model.dart';
import '../models/employee_model.dart';
import '../../domain/enums/asset_status.dart';

class CsvService {
  Future<List<AssetModel>> importAssets(File file, String companyId) async {
    final content = await file.readAsString();
    final rows = const CsvToListConverter().convert(content);

    if (rows.isEmpty) throw Exception('CSV file is empty');

    // Skip header row
    final assets = <AssetModel>[];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 5) continue;

      assets.add(AssetModel(
        id: '',
        name: row[0].toString(),
        category: row[1].toString(),
        serialNumber: row[2].toString(),
        purchaseDate: DateTime.tryParse(row[3].toString()) ?? DateTime.now(),
        status: AssetStatus.fromString(row[4].toString()),
        companyId: companyId,
        notes: row.length > 5 ? row[5].toString() : null,
        purchasePrice: row.length > 6 ? double.tryParse(row[6].toString()) : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    return assets;
  }

  Future<List<EmployeeModel>> importEmployees(File file, String companyId) async {
    final content = await file.readAsString();
    final rows = const CsvToListConverter().convert(content);

    if (rows.isEmpty) throw Exception('CSV file is empty');

    final employees = <EmployeeModel>[];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 4) continue;

      employees.add(EmployeeModel(
        id: '',
        name: row[0].toString(),
        email: row[1].toString(),
        department: row[2].toString(),
        designation: row[3].toString(),
        companyId: companyId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    return employees;
  }

  String exportAssetsCsv(List<AssetModel> assets) {
    final rows = <List<dynamic>>[
      ['Name', 'Category', 'Serial Number', 'Purchase Date', 'Status', 'Assigned To', 'Notes', 'Price'],
    ];

    for (final asset in assets) {
      rows.add([
        asset.name,
        asset.category,
        asset.serialNumber,
        asset.purchaseDate.toIso8601String().split('T').first,
        asset.status.name,
        asset.assignedEmployeeName ?? '',
        asset.notes ?? '',
        asset.purchasePrice ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  String exportEmployeesCsv(List<EmployeeModel> employees) {
    final rows = <List<dynamic>>[
      ['Name', 'Email', 'Department', 'Designation', 'Assigned Assets'],
    ];

    for (final emp in employees) {
      rows.add([
        emp.name,
        emp.email,
        emp.department,
        emp.designation,
        emp.assignedAssetCount,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}
