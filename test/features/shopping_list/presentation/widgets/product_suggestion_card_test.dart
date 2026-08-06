import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/shopping_list/presentation/widgets/product_suggestion_card.dart';
import 'package:shopping_explore/features/shopping_list/domain/entities/product_suggestion.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest(ProductSuggestion suggestion) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ProductSuggestionCard(
          suggestion: suggestion,
        ),
      ),
    );
  }

  testWidgets('image is collapsed by default and expands when toggle icon is tapped', (tester) async {
    const suggestion = ProductSuggestion(
      id: '1',
      name: 'Test Network Product',
      imageUrl: 'http://example.com/image.jpg',
      pros: [],
      cons: [],
    );

    await tester.pumpWidget(createWidgetUnderTest(suggestion));
    await tester.pump();

    // Default state: collapsed (image not visible)
    expect(find.byType(Image), findsNothing);
    final toggleIcon = find.byIcon(Icons.image_outlined);
    expect(toggleIcon, findsOneWidget);

    // Tap to expand
    await tester.tap(toggleIcon);
    await tester.pumpAndSettle();

    // Expanded state: image visible
    final imageFinder = find.byType(Image);
    expect(imageFinder, findsOneWidget);
    final imageWidget = tester.widget<Image>(imageFinder);
    expect(imageWidget.image, isA<NetworkImage>());

    // Tap to collapse again
    final collapseIcon = find.byIcon(Icons.image);
    await tester.tap(collapseIcon);
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNothing);
  });

  testWidgets('displays Image.file for local paths when expanded', (tester) async {
    const suggestion = ProductSuggestion(
      id: '2',
      name: 'Test Local Product',
      imageUrl: '/path/to/local/image.jpg',
      pros: [],
      cons: [],
    );

    await tester.pumpWidget(createWidgetUnderTest(suggestion));
    await tester.pump();

    // Default state: collapsed
    expect(find.byType(Image), findsNothing);

    // Tap to expand
    await tester.tap(find.byIcon(Icons.image_outlined));
    await tester.pumpAndSettle();

    final imageFinder = find.byType(Image);
    expect(imageFinder, findsOneWidget);

    final imageWidget = tester.widget<Image>(imageFinder);
    expect(imageWidget.image, isA<FileImage>());
  });

  testWidgets('does not display image toggle if imageUrl is null', (tester) async {
    const suggestion = ProductSuggestion(
      id: '3',
      name: 'No Image Product',
      imageUrl: null,
      pros: [],
      cons: [],
    );

    await tester.pumpWidget(createWidgetUnderTest(suggestion));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.image_outlined), findsNothing);
    expect(find.byIcon(Icons.image), findsNothing);
  });
}
