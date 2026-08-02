import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  Future<Result<void>> execute() {
    return repository.logout();
  }
}
