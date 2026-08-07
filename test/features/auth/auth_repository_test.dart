import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shopping_explore/features/auth/data/models/user_dto.dart';
import 'package:shopping_explore/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shopping_explore/core/error/failure.dart';
import 'package:shopping_explore/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:shopping_explore/features/auth/domain/usecases/login_usecase.dart';
import 'package:shopping_explore/features/auth/domain/usecases/logout_usecase.dart';
import 'package:shopping_explore/features/auth/domain/usecases/register_usecase.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_explore/core/storage/domain/repositories/storage_repository.dart';

import 'auth_mocks.mocks.dart';

// ignore: subtype_of_sealed_class
class FakeFirebaseFirestore extends Fake implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return FakeCollectionReference();
  }
}

// ignore: subtype_of_sealed_class
class FakeCollectionReference extends Fake implements CollectionReference<Map<String, dynamic>> {
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    return FakeDocumentReference();
  }
}

// ignore: subtype_of_sealed_class
class FakeDocumentReference<T> extends Fake implements DocumentReference<T> {
  @override
  Future<void> set(Object? data, [SetOptions? options]) async {}
  @override
  Future<void> update(Map<Object, Object?> data) async {}
}

class FakeStorageRepository extends Fake implements StorageRepository {}

void main() {
  late MockAuthRemoteDataSource mockDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockDataSource,
      storageRepository: FakeStorageRepository(),
      firestore: FakeFirebaseFirestore(),
    );
  });

  group('AuthRepositoryImpl', () {
    const tEmail = 'user@shoppingexplore.com';
    const tPassword = 'password123';
    const tDisplayName = 'Alex User';
    const tUserDto = UserDto(
      id: 'user-1',
      email: tEmail,
      displayName: tDisplayName,
      createdAt: '2026-08-01T10:00:00.000Z',
    );

    test('login returns Success(User) when remote data source succeeds', () async {
      when(mockDataSource.login(tEmail, tPassword)).thenAnswer((_) async => tUserDto);

      final loginUseCase = LoginUseCase(repository);
      final result = await loginUseCase.execute(email: tEmail, password: tPassword);

      expect(result.isSuccess, isTrue);
      expect(result.value.email, equals(tEmail));
      expect(result.value.displayName, equals(tDisplayName));
      verify(mockDataSource.login(tEmail, tPassword));
      verifyNoMoreInteractions(mockDataSource);
    });

    test('login returns Error(Failure) when remote data source fails', () async {
      when(mockDataSource.login(tEmail, tPassword)).thenThrow(const ValidationFailure('Invalid credentials'));

      final loginUseCase = LoginUseCase(repository);
      final result = await loginUseCase.execute(email: tEmail, password: tPassword);

      expect(result.isSuccess, isFalse);
      expect(result.error, isA<ValidationFailure>());
      verify(mockDataSource.login(tEmail, tPassword));
      verifyNoMoreInteractions(mockDataSource);
    });

    test('register returns Success(User) when remote data source succeeds', () async {
      when(mockDataSource.register(tEmail, tPassword, tDisplayName)).thenAnswer((_) async => tUserDto);

      final registerUseCase = RegisterUseCase(repository);
      final result = await registerUseCase.execute(email: tEmail, password: tPassword, displayName: tDisplayName);

      expect(result.isSuccess, isTrue);
      expect(result.value.email, equals(tEmail));
      expect(result.value.displayName, equals(tDisplayName));
      verify(mockDataSource.register(tEmail, tPassword, tDisplayName));
      verifyNoMoreInteractions(mockDataSource);
    });

    test('getCurrentUser and logout work correctly', () async {
      when(mockDataSource.getCurrentUser()).thenAnswer((_) async => tUserDto);
      when(mockDataSource.logout()).thenAnswer((_) async => {});

      final getUseCase = GetCurrentUserUseCase(repository);
      final logoutUseCase = LogoutUseCase(repository);

      final initialUser = await getUseCase.execute();
      expect(initialUser.isSuccess, isTrue);
      expect(initialUser.value?.email, equals(tEmail));

      final logoutResult = await logoutUseCase.execute();
      expect(logoutResult.isSuccess, isTrue);

      verify(mockDataSource.getCurrentUser());
      verify(mockDataSource.logout());
    });

    test('restoreSession returns Success(User) when remote data source has user', () async {
      when(mockDataSource.getCurrentUser()).thenAnswer((_) async => tUserDto);

      final result = await repository.restoreSession();

      expect(result.isSuccess, isTrue);
      expect(result.value?.email, equals(tEmail));
      verify(mockDataSource.getCurrentUser());
      verifyNoMoreInteractions(mockDataSource);
    });

    test('updateProfile returns Success(User) on success', () async {
      when(mockDataSource.updateProfile(any, any)).thenAnswer((_) async => tUserDto);
      when(mockDataSource.getCurrentUser()).thenAnswer((_) async => tUserDto);

      final result = await repository.updateProfile(displayName: 'New Name', avatarUrl: null);

      expect(result.isSuccess, isTrue);
      expect(result.value.displayName, equals(tDisplayName));
      verify(mockDataSource.getCurrentUser());
      verify(mockDataSource.updateProfile('New Name', null));
      verifyNoMoreInteractions(mockDataSource);
    });
  });
}
