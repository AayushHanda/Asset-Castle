import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../domain/enums/user_role.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (result.user == null) throw Exception('Login failed');

      final userDoc = await _firestore.collection('users').doc(result.user!.uid).get();

      if (!userDoc.exists) {
        // Create user doc if first login
        final newUser = UserModel(
          uid: result.user!.uid,
          email: email.trim(),
          name: email.split('@').first,
          role: UserRole.admin,
          companyId: 'system', // System admin
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(result.user!.uid).set(newUser.toFirestore());
        return newUser;
      }

      return UserModel.fromFirestore(userDoc);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromFirestore(doc);
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    required String companyId,
    String? department,
    String? designation,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (result.user == null) throw Exception('Registration failed');

      final newUser = UserModel(
        uid: result.user!.uid,
        email: email.trim(),
        name: name,
        role: role,
        companyId: companyId,
        department: department,
        designation: designation,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(result.user!.uid).set(newUser.toFirestore());
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserModel> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    required String companyId,
    String? department,
    String? designation,
  }) async {
    // Use secondary app to avoid signing out current user
    final secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp_${DateTime.now().millisecondsSinceEpoch}',
      options: Firebase.app().options,
    );

    try {
      final result = await FirebaseAuth.instanceFor(app: secondaryApp).createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (result.user == null) throw Exception('User creation failed');

      final newUser = UserModel(
        uid: result.user!.uid,
        email: email.trim(),
        name: name,
        role: role,
        companyId: companyId,
        department: department,
        designation: designation,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(result.user!.uid).set(newUser.toFirestore());
      return newUser;
    } finally {
      await secondaryApp.delete();
    }
  }

  Future<void> updateUserRole(String uid, UserRole role) async {
    await _firestore.collection('users').doc(uid).update({
      'role': role.name,
      'updatedAt': Timestamp.now(),
    });
  }

  Stream<List<UserModel>> getAllUsers({String? companyId}) {
    Query<Map<String, dynamic>> query = _firestore.collection('users').orderBy('name');
    if (companyId != null && companyId != 'system') {
      query = query.where('companyId', isEqualTo: companyId);
    }
    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  Future<void> deleteUser(String uid) async {
    // Note: This only deletes the document, not the Auth user.
    // Full auth deletion requires admin SDK or Cloud Functions.
    await _firestore.collection('users').doc(uid).delete();
  }

  Exception _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email');
      case 'wrong-password':
        return Exception('Invalid password');
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'user-disabled':
        return Exception('This account has been disabled');
      case 'email-already-in-use':
        return Exception('Email already in use');
      case 'weak-password':
        return Exception('Password is too weak');
      default:
        return Exception(e.message ?? 'Authentication failed');
    }
  }
}
