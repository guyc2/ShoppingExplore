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

  testWidgets('displays Image.network for http URLs', (tester) async {
    final suggestion = const ProductSuggestion(
      id: '1',
      name: 'Test Network Product',
      imageUrl: 'http://example.com/image.jpg',
      pros: [],
      cons: [],
    );

    await tester.pumpWidget(createWidgetUnderTest(suggestion));
    await tester.pump();

    final imageFinder = find.byType(Image);
    expect(imageFinder, findsOneWidget);
    
    final imageWidget = tester.widget<Image>(imageFinder);
    expect(imageWidget.image, isA<NetworkImage>());
  });

  testWidgets('displays Image.file for local paths', (tester) async {
    final suggestion = const ProductSuggestion(
      id: '2',
      name: 'Test Local Product',
      imageUrl: '/path/to/local/image.jpg',
      pros: [],
      cons: [],
    );

    await tester.pumpWidget(createWidgetUnderTest(suggestion));
    await tester.pump();

    final imageFinder = find.byType(Image);
    expect(imageFinder, findsOneWidget);

    final imageWidget = tester.widget<Image>(imageFinder);
    expect(imageWidget.image, isA<FileImage>());
  });

  testWidgets('does not display image if imageUrl is null', (tester) async {
    final suggestion = const ProductSuggestion(
      id: '3',
      name: 'No Image Product',
      imageUrl: null,
      pros: [],
      cons: [],
    );

    await tester.pumpWidget(createWidgetUnderTest(suggestion));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNothing);
  });
}
