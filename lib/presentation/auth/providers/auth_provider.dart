import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/audit_log_repository.dart';
import '../../../domain/enums/user_role.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());
final auditLogRepositoryProvider = Provider((ref) => AuditLogRepository());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return ref.read(authRepositoryProvider).getCurrentUserModel();
    },
    loading: () => null,
    error: (_, _) => null,
  );
});

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthState {
  final bool isLoading;
  final String? error;
  final UserModel? user;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    UserModel? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);
  AuditLogRepository get _auditRepo => ref.read(auditLogRepositoryProvider);

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.signIn(email, password);
      state = state.copyWith(isLoading: false, user: user);

      await _auditRepo.log(
        userId: user.uid,
        userName: user.name,
        action: 'login',
        entityType: 'user',
        entityId: user.uid,
        entityName: user.name,
        details: 'User logged in',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> signUp({
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
      final user = await _repo.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
        companyId: companyId,
        department: department,
        designation: designation,
      );
      state = state.copyWith(isLoading: false, user: user);

      await _auditRepo.log(
        userId: user.uid,
        userName: user.name,
        action: 'register',
        entityType: 'user',
        entityId: user.uid,
        entityName: user.name,
        details: 'User registered: ${user.role.label}',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      final user = state.user;
      if (user != null) {
        await _auditRepo.log(
          userId: user.uid,
          userName: user.name,
          action: 'logout',
          entityType: 'user',
          entityId: user.uid,
          entityName: user.name,
        );
      }
      await _repo.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadCurrentUser() async {
    try {
      final user = await _repo.getCurrentUserModel();
      if (user != null) {
        state = state.copyWith(user: user);
      }
    } catch (_) {}
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
