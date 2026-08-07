import 'dart:typed_data';

import '../../../error/result.dart';

/// Pure Dart interface for uploading and deleting media files.
/// Zero Firebase imports are allowed in the domain layer.
abstract class StorageRepository {
  /// Uploads a user's avatar image and returns the public download URL.
  Future<Result<String>> uploadAvatar({
    required String userId,
    required Uint8List imageBytes,
    required String extension,
  });

  /// Uploads a product image for a shopping list item and returns the public download URL.
  Future<Result<String>> uploadItemImage({
    required String listId,
    required String itemId,
    required Uint8List imageBytes,
    required String extension,
  });

  /// Deletes a file by its public download URL.
  Future<Result<void>> deleteFile(String downloadUrl);
}
