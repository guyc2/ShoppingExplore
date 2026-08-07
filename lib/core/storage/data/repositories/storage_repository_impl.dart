import 'dart:typed_data';

import '../../../error/failure.dart';
import '../../../error/result.dart';
import '../../../utils/logger.dart';
import '../../domain/repositories/storage_repository.dart';
import '../datasources/firebase_storage_datasource.dart';

class StorageRepositoryImpl implements StorageRepository {
  final StorageDataSource remoteDataSource;

  StorageRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<String>> uploadAvatar({
    required String userId,
    required Uint8List imageBytes,
    required String extension,
  }) async {
    try {
      AppLogger.d('Uploading avatar for user: $userId', tag: 'StorageRepositoryImpl');
      final downloadUrl = await remoteDataSource.uploadAvatar(
        userId: userId,
        imageBytes: imageBytes,
        extension: extension,
      );
      return Success(downloadUrl);
    } on Failure catch (failure) {
      AppLogger.w('Failed to upload avatar: ${failure.message}', tag: 'StorageRepositoryImpl');
      return Error(failure);
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected error uploading avatar', tag: 'StorageRepositoryImpl', error: e, stackTrace: stackTrace);
      return Error(NetworkFailure('Unexpected error uploading avatar: $e'));
    }
  }

  @override
  Future<Result<String>> uploadItemImage({
    required String listId,
    required String itemId,
    required Uint8List imageBytes,
    required String extension,
  }) async {
    try {
      AppLogger.d('Uploading image for item: $itemId in list: $listId', tag: 'StorageRepositoryImpl');
      final downloadUrl = await remoteDataSource.uploadItemImage(
        listId: listId,
        itemId: itemId,
        imageBytes: imageBytes,
        extension: extension,
      );
      return Success(downloadUrl);
    } on Failure catch (failure) {
      AppLogger.w('Failed to upload item image: ${failure.message}', tag: 'StorageRepositoryImpl');
      return Error(failure);
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected error uploading item image', tag: 'StorageRepositoryImpl', error: e, stackTrace: stackTrace);
      return Error(NetworkFailure('Unexpected error uploading item image: $e'));
    }
  }

  @override
  Future<Result<void>> deleteFile(String downloadUrl) async {
    try {
      AppLogger.d('Deleting file: $downloadUrl', tag: 'StorageRepositoryImpl');
      await remoteDataSource.deleteFile(downloadUrl);
      return const Success(null);
    } on Failure catch (failure) {
      AppLogger.w('Failed to delete file: ${failure.message}', tag: 'StorageRepositoryImpl');
      return Error(failure);
    } catch (e, stackTrace) {
      AppLogger.e('Unexpected error deleting file', tag: 'StorageRepositoryImpl', error: e, stackTrace: stackTrace);
      return Error(NetworkFailure('Unexpected error deleting file: $e'));
    }
  }
}
