import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:shopping_explore/core/storage/domain/repositories/storage_repository.dart';
import 'package:shopping_explore/core/services/image_storage_service.dart';
import 'package:shopping_explore/core/error/result.dart';

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
class FakeDocumentReference extends Fake implements DocumentReference<Map<String, dynamic>> {
  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {}
  
  @override
  Future<void> update(Map<Object, Object?> data) async {}
}

class FakeStorageRepository extends Fake implements StorageRepository {}

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  User? get currentUser => null;
  @override
  Stream<User?> authStateChanges() => const Stream.empty();
}

class FakeImageStorageService extends Fake implements ImageStorageService {
  @override
  Future<Result<String?>> pickAndCompressImage(ImagePickerSource source) async {
    return const Success('fake_image_path.jpg');
  }
}
