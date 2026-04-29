import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/asset_model.dart';
import '../../../data/repositories/asset_repository.dart';
import '../../../data/repositories/asset_log_repository.dart';
import '../../../data/repositories/employee_repository.dart';
import '../../../data/repositories/audit_log_repository.dart';
import '../../../domain/enums/log_action.dart';
import '../../auth/providers/auth_provider.dart';

final assetRepositoryProvider = Provider((ref) => AssetRepository());
final assetLogRepositoryProvider = Provider((ref) => AssetLogRepository());

final assetsStreamProvider = StreamProvider<List<AssetModel>>((ref) {
  final companyId = ref.watch(authNotifierProvider).user?.companyId;
  return ref.watch(assetRepositoryProvider).getAllAssets(companyId: companyId);
});

// Search & filter notifiers
final assetSearchNotifierProvider = NotifierProvider<AssetSearchNotifier, String>(() => AssetSearchNotifier());

class AssetSearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String query) => state = query;
  void clear() => state = '';
}

final assetCategoryFilterNotifierProvider = NotifierProvider<AssetCategoryFilterNotifier, String?>(() => AssetCategoryFilterNotifier());

class AssetCategoryFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? category) => state = category;
  void clear() => state = null;
}

final assetStatusFilterNotifierProvider = NotifierProvider<AssetStatusFilterNotifier, String?>(() => AssetStatusFilterNotifier());

class AssetStatusFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? status) => state = status;
  void clear() => state = null;
}

final filteredAssetsProvider = Provider<AsyncValue<List<AssetModel>>>((ref) {
  final assets = ref.watch(assetsStreamProvider);
  final search = ref.watch(assetSearchNotifierProvider).toLowerCase();
  final categoryFilter = ref.watch(assetCategoryFilterNotifierProvider);
  final statusFilter = ref.watch(assetStatusFilterNotifierProvider);

  return assets.whenData((list) {
    var filtered = list;

    if (search.isNotEmpty) {
      filtered = filtered
          .where((a) =>
              a.name.toLowerCase().contains(search) ||
              a.serialNumber.toLowerCase().contains(search) ||
              a.category.toLowerCase().contains(search) ||
              (a.assignedEmployeeName?.toLowerCase().contains(search) ?? false))
          .toList();
    }

    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      filtered = filtered.where((a) => a.category == categoryFilter).toList();
    }

    if (statusFilter != null && statusFilter.isNotEmpty) {
      filtered = filtered.where((a) => a.status.name == statusFilter).toList();
    }

    return filtered;
  });
});

final assetsByEmployeeProvider = StreamProvider.family<List<AssetModel>, String>((ref, employeeId) {
  return ref.watch(assetRepositoryProvider).getAssetsByEmployee(employeeId);
});

final assetDetailProvider = FutureProvider.family<AssetModel, String>((ref, assetId) {
  return ref.watch(assetRepositoryProvider).getAsset(assetId);
});

final assetLogsProvider = StreamProvider.family<List<dynamic>, String>((ref, assetId) {
  return ref.watch(assetLogRepositoryProvider).getLogsByAsset(assetId);
});

final assetNotifierProvider =
    NotifierProvider<AssetNotifier, AssetFormState>(() => AssetNotifier());

class AssetFormState {
  final bool isLoading;
  final String? error;
  final bool saved;

  const AssetFormState({
    this.isLoading = false,
    this.error,
    this.saved = false,
  });

  AssetFormState copyWith({bool? isLoading, String? error, bool? saved}) {
    return AssetFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      saved: saved ?? this.saved,
    );
  }
}

class AssetNotifier extends Notifier<AssetFormState> {
  @override
  AssetFormState build() => const AssetFormState();

  AssetRepository get _assetRepo => ref.read(assetRepositoryProvider);
  AssetLogRepository get _logRepo => ref.read(assetLogRepositoryProvider);
  EmployeeRepository get _empRepo => EmployeeRepository();
  AuditLogRepository get _auditRepo => ref.read(auditLogRepositoryProvider);

  String get _userId => ref.read(authNotifierProvider).user?.uid ?? '';
  String get _userName => ref.read(authNotifierProvider).user?.name ?? '';

  Future<bool> addAsset(AssetModel asset) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final id = await _assetRepo.addAsset(asset);

      await _logRepo.logAction(
        assetId: id,
        assetName: asset.name,
        action: LogAction.created,
        performedBy: _userId,
        performedByName: _userName,
        notes: 'Asset created',
      );

      await _auditRepo.log(
        userId: _userId,
        userName: _userName,
        action: 'created',
        entityType: 'asset',
        entityId: id,
        entityName: asset.name,
        details: 'Asset created: ${asset.name} (${asset.serialNumber})',
      );

      state = state.copyWith(isLoading: false, saved: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateAsset(AssetModel asset) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _assetRepo.updateAsset(asset);

      await _logRepo.logAction(
        assetId: asset.id,
        assetName: asset.name,
        action: LogAction.updated,
        performedBy: _userId,
        performedByName: _userName,
        notes: 'Asset updated',
      );

      await _auditRepo.log(
        userId: _userId,
        userName: _userName,
        action: 'updated',
        entityType: 'asset',
        entityId: asset.id,
        entityName: asset.name,
      );

      state = state.copyWith(isLoading: false, saved: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteAsset(String id, String name) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _assetRepo.deleteAsset(id);

      await _auditRepo.log(
        userId: _userId,
        userName: _userName,
        action: 'deleted',
        entityType: 'asset',
        entityId: id,
        entityName: name,
      );

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> assignAsset(String assetId, String assetName, String employeeId, String employeeName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _assetRepo.assignAsset(
        assetId: assetId,
        employeeId: employeeId,
        employeeName: employeeName,
      );
      await _empRepo.updateAssetCount(employeeId, 1);

      await _logRepo.logAction(
        assetId: assetId,
        assetName: assetName,
        action: LogAction.assigned,
        performedBy: _userId,
        performedByName: _userName,
        employeeId: employeeId,
        employeeName: employeeName,
        notes: 'Assigned to $employeeName',
      );

      await _auditRepo.log(
        userId: _userId,
        userName: _userName,
        action: 'assigned',
        entityType: 'asset',
        entityId: assetId,
        entityName: assetName,
        details: 'Assigned to $employeeName',
      );

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> unassignAsset(String assetId, String assetName, String employeeId, String employeeName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _assetRepo.unassignAsset(assetId);
      await _empRepo.updateAssetCount(employeeId, -1);

      await _logRepo.logAction(
        assetId: assetId,
        assetName: assetName,
        action: LogAction.unassigned,
        performedBy: _userId,
        performedByName: _userName,
        employeeId: employeeId,
        employeeName: employeeName,
        notes: 'Unassigned from $employeeName',
      );

      await _auditRepo.log(
        userId: _userId,
        userName: _userName,
        action: 'unassigned',
        entityType: 'asset',
        entityId: assetId,
        entityName: assetName,
        details: 'Unassigned from $employeeName',
      );

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = const AssetFormState();
  }
}
