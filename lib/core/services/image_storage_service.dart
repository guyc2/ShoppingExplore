import '../error/failure.dart';
import '../error/result.dart';

enum ImagePickerSource { camera, gallery }

abstract class ImageStorageService {
  /// Picks an image from the given [source], compresses it, and saves it locally.
  /// Returns the local file path on success, or a [Failure] on error.
  /// If the user cancels the picker, it should return a [Success] with a null path.
  Future<Result<String?>> pickAndCompressImage(ImagePickerSource source);
}
