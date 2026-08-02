import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:shopping_explore/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shopping_explore/features/auth/domain/usecases/login_usecase.dart';
import 'package:shopping_explore/features/auth/domain/usecases/get_current_user_usecase.dart';

void main() {
  group('Guy C Debug User Auth Tests', () {
    late InMemoryAuthDataSource localDataSource;
    late AuthRepositoryImpl repository;
    late LoginUseCase loginUseCase;
    late GetCurrentUserUseCase getCurrentUserUseCase;

    setUp(() {
      localDataSource = InMemoryAuthDataSource(startAuthenticated: false);
      repository = AuthRepositoryImpl(localDataSource: localDataSource);
      loginUseCase = LoginUseCase(repository);
      getCurrentUserUseCase = GetCurrentUserUseCase(repository);
    });

    test('guy@shoppingexplore.com logs in successfully as Guy C', () async {
      final loginResult = await loginUseCase.execute(email: 'guy@shoppingexplore.com', password: 'password123');
      expect(loginResult.isSuccess, isTrue);
      expect(loginResult.value.email, equals('guy@shoppingexplore.com'));
      expect(loginResult.value.displayName, equals('Guy C'));

      final currentUserResult = await getCurrentUserUseCase.execute();
      expect(currentUserResult.isSuccess, isTrue);
      expect(currentUserResult.value?.email, equals('guy@shoppingexplore.com'));
      expect(currentUserResult.value?.displayName, equals('Guy C'));
    });

    test('guyc2@shoppingexplore.com logs in successfully as Guy C', () async {
      final loginResult = await loginUseCase.execute(email: 'guyc2@shoppingexplore.com', password: 'password123');
      expect(loginResult.isSuccess, isTrue);
      expect(loginResult.value.displayName, equals('Guy C'));
    });
  });
}
