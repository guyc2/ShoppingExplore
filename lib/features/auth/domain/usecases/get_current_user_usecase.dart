import '../../../../core/error/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  const GetCurrentUserUseCase(this.repository);

  Future<Result<User?>> execute() {
    return repository.getCurrentUser();
  }
}
