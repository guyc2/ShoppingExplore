import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/domain/repositories/storage_repository.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final StorageRepository storageRepository;
  final FirebaseFirestore firestore;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageRepository,
    required this.firestore,
  });

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      AppLogger.d('Login requested for email: $email (rememberMe: $rememberMe)', tag: 'AuthRepositoryImpl');
      final dto = await remoteDataSource.login(email, password);
      final user = dto.toDomain();
      AppLogger.i('User logged in successfully: ${user.email}', tag: 'AuthRepositoryImpl');
      return Success(user);
    } on Failure catch (failure) {
      AppLogger.w('Login failure for $email: ${failure.message}', tag: 'AuthRepositoryImpl');
      return Error(failure);
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected login error', tag: 'AuthRepositoryImpl', error: e, stackTrace: stackTrace);
      return Error(NetworkFailure('Authentication error: $e'));
    }
  }

  @override
  Future<Result<User>> register({
    required String email,
    required String password,
    required String displayName,
    bool rememberMe = false,
  }) async {
    try {
      AppLogger.d('Register requested for email: $email (rememberMe: $rememberMe)', tag: 'AuthRepositoryImpl');
      final dto = await remoteDataSource.register(email, password, displayName);
      
      await firestore.collection('users').doc(dto.id).set({
        'uid': dto.id,
        'email': dto.email,
        'displayName': dto.displayName,
        'avatarUrl': dto.avatarUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      final user = dto.toDomain();
      AppLogger.i('User registered successfully: ${user.email}', tag: 'AuthRepositoryImpl');
      return Success(user);
    } on Failure catch (failure) {
      AppLogger.w('Register failure for $email: ${failure.message}', tag: 'AuthRepositoryImpl');
      return Error(failure);
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected registration error', tag: 'AuthRepositoryImpl', error: e, stackTrace: stackTrace);
      return Error(NetworkFailure('Registration error: $e'));
    }
  }

  @override
  Future<Result<User>> signInWithGoogle({bool rememberMe = false}) async {
    try {
      AppLogger.d('Google Sign-In requested (rememberMe: $rememberMe)', tag: 'AuthRepositoryImpl');
      final dto = await remoteDataSource.signInWithGoogle();

      await firestore.collection('users').doc(dto.id).set({
        'uid': dto.id,
        'email': dto.email,
        'displayName': dto.displayName,
        'avatarUrl': dto.avatarUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final user = dto.toDomain();
      AppLogger.i('Google Sign-In successful for ${user.email}', tag: 'AuthRepositoryImpl');
      return Success(user);
    } on Failure catch (failure) {
      AppLogger.w('Google Sign-In failure: ${failure.message}', tag: 'AuthRepositoryImpl');
      return Error(failure);
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected Google Sign-In error', tag: 'AuthRepositoryImpl', error: e, stackTrace: stackTrace);
      return Error(NetworkFailure('Google Sign-In error: $e'));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      AppLogger.d('Logout requested', tag: 'AuthRepositoryImpl');
      await remoteDataSource.logout();
      AppLogger.i('User logged out successfully', tag: 'AuthRepositoryImpl');
      return const Success(null);
    } on Failure catch (failure) {
      AppLogger.w('Logout failure: ${failure.message}', tag: 'AuthRepositoryImpl');
      return Error(failure);
    } catch (e, stackTrace) {
      AppLogger.e('Logout error', tag: 'AuthRepositoryImpl', error: e, stackTrace: stackTrace);
      return Error(CacheFailure('Logout error: $e'));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final dto = await remoteDataSource.getCurrentUser();
      if (dto == null) {
        return const Success(null);
      }
      return Success(dto.toDomain());
    } on Failure catch (failure) {
      AppLogger.w('Get current user failure: ${failure.message}', tag: 'AuthRepositoryImpl');
      return Error(failure);
    } catch (e, stackTrace) {
      AppLogger.e('Get current user error', tag: 'AuthRepositoryImpl', error: e, stackTrace: stackTrace);
      return Error(CacheFailure('Failed to retrieve current user: $e'));
    }
  }

  @override
  Future<Result<User?>> restoreSession() async {
    try {
      AppLogger.d('Attempting to restore persistent session via Firebase Auth', tag: 'AuthRepositoryImpl');
      final dto = await remoteDataSource.getCurrentUser();
      if (dto == null) {
        return const Success(null);
      }
      final user = dto.toDomain();
      AppLogger.i('Persistent session restored successfully: ${user.email}', tag: 'AuthRepositoryImpl');
      return Success(user);
    } on Failure catch (failure) {
      AppLogger.w('Restore session failure: ${failure.message}', tag: 'AuthRepositoryImpl');
      return Error(failure);
    } catch (e, stackTrace) {
      AppLogger.e('Restore session error', tag: 'AuthRepositoryImpl', error: e, stackTrace: stackTrace);
      return Error(CacheFailure('Failed to restore session: $e'));
    }
  }

  @override
  Future<Result<User>> updateProfile({
    required String displayName,
    String? avatarUrl,
  }) async {
    try {
      AppLogger.d('Update profile requested: $displayName', tag: 'AuthRepositoryImpl');
      
      String? finalAvatarUrl = avatarUrl;
      final currentUserDto = await remoteDataSource.getCurrentUser();
      
      if (currentUserDto == null) {
        return const Error(CacheFailure('No user logged in'));
      }
      final userId = currentUserDto.id;

      if (avatarUrl != null && !avatarUrl.startsWith('http')) {
        final file = File(avatarUrl);
        final bytes = await file.readAsBytes();
        final ext = avatarUrl.split('.').last;
        final uploadResult = await storageRepository.uploadAvatar(
          userId: userId,
          imageBytes: bytes,
          extension: ext,
        );
        if (uploadResult is Success<String>) {
          finalAvatarUrl = uploadResult.value;
        } else if (uploadResult is Error<String>) {
          return Error(uploadResult.failure);
        }
      }

      final dto = await remoteDataSource.updateProfile(displayName, finalAvatarUrl);

      await firestore.collection('users').doc(userId).update({
        'displayName': displayName,
        'avatarUrl': finalAvatarUrl,
      });

      final user = dto.toDomain();
      AppLogger.i('User profile updated successfully: ${user.displayName}', tag: 'AuthRepositoryImpl');
      return Success(user);
    } on Failure catch (failure) {
      AppLogger.w('Update profile failure: ${failure.message}', tag: 'AuthRepositoryImpl');
      return Error(failure);
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected update profile error', tag: 'AuthRepositoryImpl', error: e, stackTrace: stackTrace);
      return Error(CacheFailure('Profile update error: $e'));
    }
  }
}
