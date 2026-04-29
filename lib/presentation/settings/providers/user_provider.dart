import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/audit_log_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../domain/enums/user_role.dart';

final usersStreamProvider = StreamProvider<List<UserModel>>((ref) {
  final companyId = ref.watch(authNotifierProvider).user?.companyId;
  return ref.watch(authRepositoryProvider).getAllUsers(companyId: companyId);
});

final userNotifierProvider = NotifierProvider<UserNotifier, UserFormState>(() => UserNotifier());

class UserFormState {
  final bool isLoading;
  final String? error;
  final bool saved;

  const UserFormState({this.isLoading = false, this.error, this.saved = false});

  UserFormState copyWith({bool? isLoading, String? error, bool? saved}) {
    return UserFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      saved: saved ?? this.saved,
    );
  }
}

class UserNotifier extends Notifier<UserFormState> {
  @override
  UserFormState build() => const UserFormState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);
  AuditLogRepository get _auditRepo => ref.read(auditLogRepositoryProvider);

  String get _userId => ref.read(authNotifierProvider).user?.uid ?? '';
  String get _userName => ref.read(authNotifierProvider).user?.name ?? '';

  Future<bool> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    required String companyId,
    String? department,
    String? designation,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.createUser(
        email: email,
        password: password,
        name: name,
        role: role,
        companyId: companyId,
        department: department,
        designation: designation,
      );

      await _auditRepo.log(
        userId: _userId,
        userName: _userName,
        action: 'created',
        entityType: 'user',
        entityId: user.uid,
        entityName: user.name,
        details: 'User account created: ${user.name} (${user.role.label})',
      );

      state = state.copyWith(isLoading: false, saved: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteUser(String uid, String name) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.deleteUser(uid);
      await _auditRepo.log(
        userId: _userId,
        userName: _userName,
        action: 'deleted',
        entityType: 'user',
        entityId: uid,
        entityName: name,
        details: 'User document deleted: $name',
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() => state = const UserFormState();
}
