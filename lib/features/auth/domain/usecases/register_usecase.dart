import '../../../../core/error/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  Future<Result<User>> execute({
    required String email,
    required String password,
    required String displayName,
  }) {
    return repository.register(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
