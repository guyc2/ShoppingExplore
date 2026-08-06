import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopping_explore/core/error/failure.dart';
import 'package:shopping_explore/core/services/image_storage_service.dart';
import 'package:shopping_explore/core/services/local_image_storage_service_impl.dart';
import 'package:uuid/uuid.dart';

class FakeImagePicker extends ImagePicker {
  XFile? fileToReturn;
  Exception? exceptionToThrow;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return fileToReturn;
  }
}

class FakeUuid implements Uuid {
  final String uuidToReturn;

  const FakeUuid(this.uuidToReturn);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #v4) return uuidToReturn;
    return super.noSuchMethod(invocation);
  }
}

void main() {
  late LocalImageStorageServiceImpl service;
  late FakeImagePicker mockPicker;
  late FakeUuid mockUuid;
  late Directory tempAppDir;
  late File sourceTempFile;

  setUp(() async {
    tempAppDir = await Directory.systemTemp.createTemp('app_dir');
    sourceTempFile = await File('${tempAppDir.path}/source_image.jpg').create();
    await sourceTempFile.writeAsBytes([1, 2, 3]);

    mockPicker = FakeImagePicker();
    mockUuid = const FakeUuid('test-uuid-1234');
    
    service = LocalImageStorageServiceImpl(
      picker: mockPicker,
      uuid: mockUuid,
      getDirectory: () async => tempAppDir,
    );
  });

  tearDown(() async {
    if (tempAppDir.existsSync()) {
      tempAppDir.deleteSync(recursive: true);
    }
  });

  test('pickAndCompressImage returns null when user cancels', () async {
    mockPicker.fileToReturn = null;
    final result = await service.pickAndCompressImage(ImagePickerSource.gallery);
    
    expect(result.isSuccess, true);
    expect(result.value, null);
  });

  test('pickAndCompressImage returns saved local file path on success', () async {
    mockPicker.fileToReturn = XFile(sourceTempFile.path);
    final result = await service.pickAndCompressImage(ImagePickerSource.camera);
    
    expect(result.isSuccess, true);
    
    final expectedPath = '${tempAppDir.path}/suggestion_images/test-uuid-1234.jpg';
    expect(result.value, expectedPath);
    
    final savedFile = File(expectedPath);
    expect(savedFile.existsSync(), true);
  });

  test('pickAndCompressImage returns StorageFailure on Exception', () async {
    mockPicker.exceptionToThrow = Exception('Picker failed');
    final result = await service.pickAndCompressImage(ImagePickerSource.camera);
    
    expect(result.isFailure, true);
    expect(result.error, isA<StorageFailure>());
    expect(result.error.message, contains('Picker failed'));
  });
}
