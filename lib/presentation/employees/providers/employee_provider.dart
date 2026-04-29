import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/repositories/employee_repository.dart';
import '../../../data/repositories/audit_log_repository.dart';
import '../../auth/providers/auth_provider.dart';

final employeeRepositoryProvider = Provider((ref) => EmployeeRepository());

final employeesStreamProvider = StreamProvider<List<EmployeeModel>>((ref) {
  final companyId = ref.watch(authNotifierProvider).user?.companyId;
  return ref.watch(employeeRepositoryProvider).getAllEmployees(companyId: companyId);
});

final employeeSearchProvider = Provider<_SearchState>((_) => _SearchState());
final employeeDepartmentFilterProvider = Provider<_FilterState>((_) => _FilterState());

class _SearchState {
  final String _value = '';
  String get value => _value;
  final List<void Function()> _listeners = [];
  void addListener(void Function() listener) => _listeners.add(listener);
}

class _FilterState {
  String? _value;
  String? get value => _value;
}

// Use simple providers with a notifier approach
final employeeSearchQueryProvider = NotifierProvider<EmployeeSearchNotifier, String>(() => EmployeeSearchNotifier());

class EmployeeSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
  void clear() => state = '';
}

final employeeDeptFilterNotifierProvider = NotifierProvider<EmployeeDeptFilterNotifier, String?>(() => EmployeeDeptFilterNotifier());

class EmployeeDeptFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void update(String? dept) => state = dept;
  void clear() => state = null;
}

final filteredEmployeesProvider = Provider<AsyncValue<List<EmployeeModel>>>((ref) {
  final employees = ref.watch(employeesStreamProvider);
  final search = ref.watch(employeeSearchQueryProvider).toLowerCase();
  final departmentFilter = ref.watch(employeeDeptFilterNotifierProvider);

  return employees.whenData((list) {
    var filtered = list;

    if (search.isNotEmpty) {
      filtered = filtered
          .where((e) =>
              e.name.toLowerCase().contains(search) ||
              e.email.toLowerCase().contains(search) ||
              e.department.toLowerCase().contains(search) ||
              e.designation.toLowerCase().contains(search))
          .toList();
    }

    if (departmentFilter != null && departmentFilter.isNotEmpty) {
      filtered = filtered.where((e) => e.department == departmentFilter).toList();
    }

    return filtered;
  });
});

final employeeNotifierProvider =
    NotifierProvider<EmployeeNotifier, EmployeeFormState>(() => EmployeeNotifier());

class EmployeeFormState {
  final bool isLoading;
  final String? error;
  final bool saved;

  const EmployeeFormState({
    this.isLoading = false,
    this.error,
    this.saved = false,
  });

  EmployeeFormState copyWith({bool? isLoading, String? error, bool? saved}) {
    return EmployeeFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      saved: saved ?? this.saved,
    );
  }
}

class EmployeeNotifier extends Notifier<EmployeeFormState> {
  @override
  EmployeeFormState build() => const EmployeeFormState();

  EmployeeRepository get _repo => ref.read(employeeRepositoryProvider);
  AuditLogRepository get _auditRepo => ref.read(auditLogRepositoryProvider);

  String get _userId => ref.read(authNotifierProvider).user?.uid ?? '';
  String get _userName => ref.read(authNotifierProvider).user?.name ?? '';

  Future<bool> addEmployee(EmployeeModel employee) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final id = await _repo.addEmployee(employee);
      await _auditRepo.log(
        userId: _userId,
        userName: _userName,
        action: 'created',
        entityType: 'employee',
        entityId: id,
        entityName: employee.name,
        details: 'Employee added: ${employee.name}',
      );
      state = state.copyWith(isLoading: false, saved: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateEmployee(EmployeeModel employee) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.updateEmployee(employee);
      await _auditRepo.log(
        userId: _userId,
        userName: _userName,
        action: 'updated',
        entityType: 'employee',
        entityId: employee.id,
        entityName: employee.name,
        details: 'Employee updated: ${employee.name}',
      );
      state = state.copyWith(isLoading: false, saved: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteEmployee(String id, String name) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.deleteEmployee(id);
      await _auditRepo.log(
        userId: _userId,
        userName: _userName,
        action: 'deleted',
        entityType: 'employee',
        entityId: id,
        entityName: name,
        details: 'Employee deleted: $name',
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = const EmployeeFormState();
  }
}
