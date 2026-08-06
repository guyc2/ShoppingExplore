import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../error/failure.dart';
import '../error/result.dart';
import '../utils/logger.dart';
import 'image_storage_service.dart';

class LocalImageStorageServiceImpl implements ImageStorageService {
  final ImagePicker _picker;
  final Uuid _uuid;

  LocalImageStorageServiceImpl({
    ImagePicker? picker,
    Uuid? uuid,
    Future<Directory> Function()? getDirectory,
  })  : _picker = picker ?? ImagePicker(),
        _uuid = uuid ?? const Uuid(),
        _getDirectory = getDirectory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _getDirectory;

  @override
  Future<Result<String?>> pickAndCompressImage(ImagePickerSource source) async {
    try {
      AppLogger.d('pickAndCompressImage requested from ${source.name}', tag: 'LocalImageStorageServiceImpl');

      final imageSource = source == ImagePickerSource.camera
          ? ImageSource.camera
          : ImageSource.gallery;

      final XFile? pickedFile = await _picker.pickImage(
        source: imageSource,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        AppLogger.i('User canceled image picking', tag: 'LocalImageStorageServiceImpl');
        return const Success(null);
      }

      AppLogger.d('Image picked successfully, saving to local storage...', tag: 'LocalImageStorageServiceImpl');

      final appDir = await _getDirectory();
      final suggestionsDir = Directory('${appDir.path}/suggestion_images');

      if (!await suggestionsDir.exists()) {
        await suggestionsDir.create(recursive: true);
      }

      final extension = pickedFile.path.split('.').last;
      final fileName = '${_uuid.v4()}.$extension';
      final localFilePath = '${suggestionsDir.path}/$fileName';

      await pickedFile.saveTo(localFilePath);
      
      AppLogger.i('Image saved to $localFilePath', tag: 'LocalImageStorageServiceImpl');
      
      return Success(localFilePath);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to pick and save image', error: e, stackTrace: stackTrace, tag: 'LocalImageStorageServiceImpl');
      return Error(StorageFailure('Failed to pick and save image: ${e.toString()}'));
    }
  }
}
