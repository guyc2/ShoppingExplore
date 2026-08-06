import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/shopping_list/presentation/widgets/add_suggestion_modal.dart';
import 'package:shopping_explore/core/services/image_storage_service.dart';
import 'package:shopping_explore/core/error/result.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';

class FakeImageStorageService implements ImageStorageService {
  final Result<String?> pickResult;

  FakeImageStorageService(this.pickResult);

  @override
  Future<Result<String?>> pickAndCompressImage(ImagePickerSource source) async {
    return pickResult;
  }
}

void main() {
  Widget createWidgetUnderTest(FakeImageStorageService service) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: AddSuggestionModal(
          onSave: (suggestion) {},
          imageStorageService: service,
        ),
      ),
    );
  }

  testWidgets('shows image picker buttons when no image URL', (tester) async {
    final service = FakeImageStorageService(const Success(null));
    await tester.pumpWidget(createWidgetUnderTest(service));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
  });

  testWidgets('shows image preview and cancel button when image URL is provided by picking', (tester) async {
    final service = FakeImageStorageService(const Success('fake_image_path.jpg'));
    await tester.pumpWidget(createWidgetUnderTest(service));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.photo_library_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.cancel), findsOneWidget);
  });

  testWidgets('removes preview when cancel is tapped', (tester) async {
    final service = FakeImageStorageService(const Success('fake_image_path.jpg'));
    await tester.pumpWidget(createWidgetUnderTest(service));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.photo_library_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    
    await tester.tap(find.byIcon(Icons.cancel));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
  });
}
