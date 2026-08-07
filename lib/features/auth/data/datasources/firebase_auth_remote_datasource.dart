import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../core/error/failure.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_dto.dart';
import 'auth_remote_datasource.dart';

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthRemoteDataSource({
    required firebase_auth.FirebaseAuth firebaseAuth,
  })  : _firebaseAuth = firebaseAuth;

  @override
  Future<UserDto> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (userCredential.user == null) {
        throw const AuthFailure('Failed to retrieve user after login.');
      }
      return UserDto.fromFirebaseUser(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.e('FirebaseAuthException during login: ${e.code}', tag: 'FirebaseAuthRemoteDataSource');
      throw _mapFirebaseAuthException(e);
    } catch (e, stack) {
      AppLogger.e('Unknown error during login', tag: 'FirebaseAuthRemoteDataSource', error: e, stackTrace: stack);
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserDto> register(String email, String password, String displayName) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = userCredential.user;
      if (user == null) {
        throw const AuthFailure('Failed to retrieve user after registration.');
      }
      await user.updateDisplayName(displayName.trim());
      await user.reload();
      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser == null) {
        throw const AuthFailure('Failed to retrieve updated user.');
      }
      return UserDto.fromFirebaseUser(updatedUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.e('FirebaseAuthException during register: ${e.code}', tag: 'FirebaseAuthRemoteDataSource');
      throw _mapFirebaseAuthException(e);
    } catch (e, stack) {
      AppLogger.e('Unknown error during register', tag: 'FirebaseAuthRemoteDataSource', error: e, stackTrace: stack);
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e, stack) {
      AppLogger.e('Unknown error during logout', tag: 'FirebaseAuthRemoteDataSource', error: e, stackTrace: stack);
      throw AuthFailure('Failed to logout: $e');
    }
  }

  @override
  Future<UserDto?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return UserDto.fromFirebaseUser(user);
      }
      return null;
    } catch (e, stack) {
      AppLogger.e('Unknown error during getCurrentUser', tag: 'FirebaseAuthRemoteDataSource', error: e, stackTrace: stack);
      throw AuthFailure('Failed to get current user: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.e('FirebaseAuthException during password reset: ${e.code}', tag: 'FirebaseAuthRemoteDataSource');
      throw _mapFirebaseAuthException(e);
    } catch (e, stack) {
      AppLogger.e('Unknown error during password reset', tag: 'FirebaseAuthRemoteDataSource', error: e, stackTrace: stack);
      throw AuthFailure('Failed to send password reset email: $e');
    }
  }

  @override
  Future<UserDto> updateProfile(String displayName, String? avatarUrl) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthFailure('No authenticated user to update profile.');
      }
      await user.updateDisplayName(displayName.trim());
      if (avatarUrl != null) {
        await user.updatePhotoURL(avatarUrl);
      }
      await user.reload();
      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser == null) {
        throw const AuthFailure('Failed to retrieve updated user.');
      }
      return UserDto.fromFirebaseUser(updatedUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.e('FirebaseAuthException during updateProfile: ${e.code}', tag: 'FirebaseAuthRemoteDataSource');
      throw _mapFirebaseAuthException(e);
    } catch (e, stack) {
      AppLogger.e('Unknown error during updateProfile', tag: 'FirebaseAuthRemoteDataSource', error: e, stackTrace: stack);
      throw AuthFailure('Failed to update profile: $e');
    }
  }

  Failure _mapFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return const ValidationFailure('The email address is badly formatted.');
      case 'user-disabled':
        return const AuthFailure('This user account has been disabled.');
      case 'user-not-found':
        return const AuthFailure('No user found for that email.');
      case 'wrong-password':
        return const AuthFailure('Wrong password provided for that user.');
      case 'email-already-in-use':
        return const ValidationFailure('The email address is already in use by another account.');
      case 'operation-not-allowed':
      case 'configuration-not-found':
        return const AuthFailure('Email/password accounts are not enabled in Firebase Console.');
      case 'weak-password':
        return const ValidationFailure('The password is not strong enough.');
      case 'network-request-failed':
        return const NetworkFailure('A network error occurred. Please check your connection.');
      case 'invalid-credential':
        return const ValidationFailure('Invalid login credentials.');
      default:
        if (e.message != null && e.message!.contains('CONFIGURATION_NOT_FOUND')) {
          return const AuthFailure('Email/password auth is not enabled in Firebase Console.');
        }
        return AuthFailure(e.message ?? 'Authentication failed.');
    }
  }
}
