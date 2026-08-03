import '../../../../core/error/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateUserProfileUseCase {
  final AuthRepository repository;

  const UpdateUserProfileUseCase(this.repository);

  Future<Result<User>> execute({
    required String displayName,
    String? avatarUrl,
  }) {
    return repository.updateProfile(
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }
}
