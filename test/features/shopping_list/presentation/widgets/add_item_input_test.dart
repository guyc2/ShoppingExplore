import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/presentation/widgets/add_item_input.dart';

void main() {
  group('AddItemInput Widget Test', () {
    testWidgets('submits text and clears input on floating action button tap', (tester) async {
      String? addedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddItemInput(
              onAdd: (text) => addedText = text,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Avocados');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(addedText, equals('Avocados'));
      expect(find.text('Avocados'), findsNothing);
    });

    testWidgets('shows checked item suggestion when input starts with completed item title', (tester) async {
      ShoppingItem? selectedItem;
      final now = DateTime.now();
      final completedItem = ShoppingItem(
        id: '1',
        title: 'Milk Almond',
        isCompleted: true,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddItemInput(
              onAdd: (_) {},
              completedItems: [completedItem],
              onSelectSuggestion: (item) => selectedItem = item,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Mil');
      await tester.pumpAndSettle();

      expect(find.text('Milk Almond'), findsOneWidget);

      await tester.tap(find.text('Milk Almond'));
      await tester.pumpAndSettle();

      expect(selectedItem, equals(completedItem));
    });
  });
}
