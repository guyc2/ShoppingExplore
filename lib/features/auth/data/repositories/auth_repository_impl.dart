import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      AppLogger.d('Login requested for email: $email (rememberMe: $rememberMe)', tag: 'AuthRepositoryImpl');
      final dto = await localDataSource.login(email, password);
      if (rememberMe) {
        await localDataSource.savePersistentSession(email);
      }
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
      final dto = await localDataSource.register(email, password, displayName);
      if (rememberMe) {
        await localDataSource.savePersistentSession(email);
      }
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
  Future<Result<void>> logout() async {
    try {
      AppLogger.d('Logout requested', tag: 'AuthRepositoryImpl');
      await localDataSource.logout();
      AppLogger.i('User logged out successfully', tag: 'AuthRepositoryImpl');
      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.e('Logout error', tag: 'AuthRepositoryImpl', error: e, stackTrace: stackTrace);
      return Error(CacheFailure('Logout error: $e'));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final dto = await localDataSource.getCurrentUser();
      if (dto == null) {
        return const Success(null);
      }
      return Success(dto.toDomain());
    } catch (e, stackTrace) {
      AppLogger.e('Get current user error', tag: 'AuthRepositoryImpl', error: e, stackTrace: stackTrace);
      return Error(CacheFailure('Failed to retrieve current user: $e'));
    }
  }

  @override
  Future<Result<User?>> restoreSession() async {
    try {
      AppLogger.d('Attempting to restore persistent session', tag: 'AuthRepositoryImpl');
      final dto = await localDataSource.restorePersistentSession();
      if (dto == null) {
        return const Success(null);
      }
      final user = dto.toDomain();
      AppLogger.i('Persistent session restored successfully: ${user.email}', tag: 'AuthRepositoryImpl');
      return Success(user);
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
      final dto = await localDataSource.updateProfile(displayName, avatarUrl);
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
