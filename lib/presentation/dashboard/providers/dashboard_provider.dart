import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/asset_repository.dart';
import '../../../data/repositories/employee_repository.dart';
import '../../../data/repositories/asset_log_repository.dart';
import '../../../data/models/asset_log_model.dart';
import '../../auth/providers/auth_provider.dart';

final dashboardAssetRepoProvider = Provider((ref) => AssetRepository());
final dashboardEmployeeRepoProvider = Provider((ref) => EmployeeRepository());
final dashboardLogRepoProvider = Provider((ref) => AssetLogRepository());

final assetStatsProvider = StreamProvider<Map<String, int>>((ref) {
  final companyId = ref.watch(authNotifierProvider).user?.companyId;
  return ref.watch(dashboardAssetRepoProvider).watchStatusCounts(companyId: companyId);
});

final categoryDistributionProvider = StreamProvider<Map<String, int>>((ref) {
  final companyId = ref.watch(authNotifierProvider).user?.companyId;
  return ref.watch(dashboardAssetRepoProvider).watchCategoryDistribution(companyId: companyId);
});

final departmentDistributionProvider = StreamProvider<Map<String, int>>((ref) {
  final companyId = ref.watch(authNotifierProvider).user?.companyId;
  return ref.watch(dashboardEmployeeRepoProvider).watchDepartmentDistribution(companyId: companyId);
});

final recentActivityProvider = StreamProvider<List<AssetLogModel>>((ref) {
  // Logs should probably also be filtered by company, 
  // but AssetLog model might need companyId field if it doesn't have it.
  return ref.watch(dashboardLogRepoProvider).getRecentLogs(limit: 10);
});

final employeeCountProvider = StreamProvider<int>((ref) {
  final companyId = ref.watch(authNotifierProvider).user?.companyId;
  return ref.watch(dashboardEmployeeRepoProvider).watchEmployeeCount(companyId: companyId);
});
