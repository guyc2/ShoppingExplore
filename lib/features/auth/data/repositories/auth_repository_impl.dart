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
  Future<Result<User>> login({required String email, required String password}) async {
    try {
      AppLogger.d('Login requested for email: $email', tag: 'AuthRepositoryImpl');
      final dto = await localDataSource.login(email, password);
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
  }) async {
    try {
      AppLogger.d('Register requested for email: $email', tag: 'AuthRepositoryImpl');
      final dto = await localDataSource.register(email, password, displayName);
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
}
