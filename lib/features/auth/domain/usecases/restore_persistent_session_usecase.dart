import '../../../../core/error/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RestorePersistentSessionUseCase {
  final AuthRepository repository;

  const RestorePersistentSessionUseCase(this.repository);

  Future<Result<User?>> execute() {
    return repository.restoreSession();
  }
}
