import '../../../../core/error/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<Result<User>> execute({
    required String email,
    required String password,
    bool rememberMe = false,
  }) {
    return repository.login(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
  }
}
