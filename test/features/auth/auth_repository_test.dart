import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:shopping_explore/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shopping_explore/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:shopping_explore/features/auth/domain/usecases/login_usecase.dart';
import 'package:shopping_explore/features/auth/domain/usecases/logout_usecase.dart';
import 'package:shopping_explore/features/auth/domain/usecases/register_usecase.dart';

void main() {
  late InMemoryAuthDataSource dataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    dataSource = InMemoryAuthDataSource();
    repository = AuthRepositoryImpl(localDataSource: dataSource);
  });

  group('Authentication Flow Tests', () {
    test('login returns User on valid credentials', () async {
      final loginUseCase = LoginUseCase(repository);
      final result = await loginUseCase.execute(
        email: 'user@shoppingexplore.com',
        password: 'password123',
      );

      expect(result.isSuccess, isTrue);
      expect(result.value.email, equals('user@shoppingexplore.com'));
      expect(result.value.displayName, equals('Alex User'));
    });

    test('login returns Failure on invalid credentials', () async {
      final loginUseCase = LoginUseCase(repository);
      final result = await loginUseCase.execute(
        email: 'user@shoppingexplore.com',
        password: 'wrongpassword',
      );

      expect(result.isSuccess, isFalse);
      expect(result.error.message, contains('Invalid email or password'));
    });

    test('register creates and logs in new user', () async {
      final registerUseCase = RegisterUseCase(repository);
      final result = await registerUseCase.execute(
        email: 'newuser@shoppingexplore.com',
        password: 'secretpassword',
        displayName: 'New Tester',
      );

      expect(result.isSuccess, isTrue);
      expect(result.value.email, equals('newuser@shoppingexplore.com'));
      expect(result.value.displayName, equals('New Tester'));
    });

    test('getCurrentUser and logout work correctly', () async {
      final getUseCase = GetCurrentUserUseCase(repository);
      final logoutUseCase = LogoutUseCase(repository);

      final initialUser = await getUseCase.execute();
      expect(initialUser.isSuccess, isTrue);
      expect(initialUser.value?.email, equals('user@shoppingexplore.com'));

      final logoutResult = await logoutUseCase.execute();
      expect(logoutResult.isSuccess, isTrue);

      final postLogoutUser = await getUseCase.execute();
      expect(postLogoutUser.isSuccess, isTrue);
      expect(postLogoutUser.value, isNull);
    });
  });
}
