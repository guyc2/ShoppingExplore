import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import '../../../error/failure.dart';
import '../../../utils/logger.dart';

abstract class StorageDataSource {
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List imageBytes,
    required String extension,
  });

  Future<String> uploadItemImage({
    required String listId,
    required String itemId,
    required Uint8List imageBytes,
    required String extension,
  });

  Future<void> deleteFile(String downloadUrl);
}

class FirebaseStorageDataSource implements StorageDataSource {
  final FirebaseStorage _storage;

  FirebaseStorageDataSource({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List imageBytes,
    required String extension,
  }) async {
    try {
      final path = 'avatars/$userId/avatar.$extension';
      AppLogger.d('Uploading avatar to $path', tag: 'FirebaseStorageDataSource');
      
      final ref = _storage.ref().child(path);
      
      final metadata = SettableMetadata(
        contentType: 'image/$extension',
        customMetadata: {'userId': userId},
      );

      final uploadTask = await ref.putData(imageBytes, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      AppLogger.i('Avatar uploaded successfully. URL: $downloadUrl', tag: 'FirebaseStorageDataSource');
      return downloadUrl;
    } on FirebaseException catch (e) {
      AppLogger.e('FirebaseStorage error during uploadAvatar', tag: 'FirebaseStorageDataSource', error: e);
      throw _mapFirebaseException(e);
    } catch (e) {
      AppLogger.e('Unknown error during uploadAvatar', tag: 'FirebaseStorageDataSource', error: e);
      throw NetworkFailure('Failed to upload avatar: $e');
    }
  }

  @override
  Future<String> uploadItemImage({
    required String listId,
    required String itemId,
    required Uint8List imageBytes,
    required String extension,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'lists/$listId/items/$itemId/$timestamp.$extension';
      AppLogger.d('Uploading item image to $path', tag: 'FirebaseStorageDataSource');
      
      final ref = _storage.ref().child(path);
      
      final metadata = SettableMetadata(
        contentType: 'image/$extension',
        customMetadata: {'listId': listId, 'itemId': itemId},
      );

      final uploadTask = await ref.putData(imageBytes, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      AppLogger.i('Item image uploaded successfully. URL: $downloadUrl', tag: 'FirebaseStorageDataSource');
      return downloadUrl;
    } on FirebaseException catch (e) {
      AppLogger.e('FirebaseStorage error during uploadItemImage', tag: 'FirebaseStorageDataSource', error: e);
      throw _mapFirebaseException(e);
    } catch (e) {
      AppLogger.e('Unknown error during uploadItemImage', tag: 'FirebaseStorageDataSource', error: e);
      throw NetworkFailure('Failed to upload item image: $e');
    }
  }

  @override
  Future<void> deleteFile(String downloadUrl) async {
    try {
      AppLogger.d('Deleting file from Storage: $downloadUrl', tag: 'FirebaseStorageDataSource');
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      AppLogger.i('File deleted successfully', tag: 'FirebaseStorageDataSource');
    } on FirebaseException catch (e) {
      // If the object does not exist, consider it already deleted.
      if (e.code == 'object-not-found') {
        AppLogger.w('File not found, treating as deleted', tag: 'FirebaseStorageDataSource');
        return;
      }
      AppLogger.e('FirebaseStorage error during deleteFile', tag: 'FirebaseStorageDataSource', error: e);
      throw _mapFirebaseException(e);
    } catch (e) {
      AppLogger.e('Unknown error during deleteFile', tag: 'FirebaseStorageDataSource', error: e);
      throw NetworkFailure('Failed to delete file: $e');
    }
  }

  Failure _mapFirebaseException(FirebaseException exception) {
    switch (exception.code) {
      case 'unauthorized':
        return const AuthFailure('User is not authorized to perform the desired action.');
      case 'object-not-found':
        return const NetworkFailure('No object exists at the desired reference.');
      case 'quota-exceeded':
        return const NetworkFailure('Quota on your Firebase bucket has been exceeded.');
      case 'retry-limit-exceeded':
        return const NetworkFailure('The maximum time limit on an operation has been exceeded. Please try again.');
      case 'invalid-checksum':
      case 'canceled':
      case 'invalid-event-name':
      case 'invalid-url':
      case 'invalid-argument':
      case 'no-default-bucket':
      case 'cannot-slice-blob':
      case 'server-file-wrong-size':
        return NetworkFailure('Storage operation failed: ${exception.message}');
      default:
        return const NetworkFailure('An unknown storage error occurred.');
    }
  }
}
