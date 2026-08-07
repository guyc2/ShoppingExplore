import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:shopping_explore/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shopping_explore/features/auth/domain/usecases/login_usecase.dart';
import 'package:shopping_explore/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_explore/core/storage/domain/repositories/storage_repository.dart';

// ignore: subtype_of_sealed_class
class FakeQuery<T> extends Fake implements Query<T> {}

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
  Future<void> set(T? data, [SetOptions? options]) async {}
  @override
  Future<void> update(Map<Object, Object?> data) async {}
}

class FakeStorageRepository extends Fake implements StorageRepository {}

void main() {
  group('Guy C Debug User Auth Tests', () {
    late InMemoryAuthDataSource remoteDataSource;
    late AuthRepositoryImpl repository;
    late LoginUseCase loginUseCase;
    late GetCurrentUserUseCase getCurrentUserUseCase;

    setUp(() {
      remoteDataSource = InMemoryAuthDataSource(startAuthenticated: false);
      repository = AuthRepositoryImpl(
        remoteDataSource: remoteDataSource,
        storageRepository: FakeStorageRepository(),
        firestore: FakeFirebaseFirestore(),
      );
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
