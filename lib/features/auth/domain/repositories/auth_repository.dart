import '../../../../core/error/result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Result<User>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });
  Future<Result<User>> register({
    required String email,
    required String password,
    required String displayName,
    bool rememberMe = false,
  });
  Future<Result<User>> signInWithGoogle({bool rememberMe = false});
  Future<Result<void>> logout();
  Future<Result<User?>> getCurrentUser();
  Future<Result<User?>> restoreSession();
  Future<Result<User>> updateProfile({
    required String displayName,
    String? avatarUrl,
  });
}
