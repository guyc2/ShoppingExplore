import '../../../../core/error/result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  final AuthRepository repository;

  const SignInWithGoogleUseCase(this.repository);

  Future<Result<User>> execute({bool rememberMe = false}) {
    return repository.signInWithGoogle(rememberMe: rememberMe);
  }
}
