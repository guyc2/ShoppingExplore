import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/presentation/widgets/shopping_item_tile.dart';

void main() {
  group('ShoppingItemTile Widget Test', () {
    final now = DateTime(2026, 1, 1);
    final testItem = ShoppingItem(
      id: '1',
      title: 'Organic Bananas',
      quantity: 2.0,
      priority: Priority.high,
      notes: 'Ripe ones',
      createdAt: now,
      updatedAt: now,
    );

    testWidgets('renders title, priority badge, and inline quantity control', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingItemTile(
              item: testItem,
              onToggle: () {},
              onDelete: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Organic Bananas'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // quantity text
      expect(find.text('High'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('triggers callbacks on tap and toggle', (tester) async {
      bool toggled = false;
      bool deleted = false;
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingItemTile(
              item: testItem,
              onToggle: () => toggled = true,
              onDelete: () => deleted = true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      expect(toggled, isTrue);

      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deleted, isTrue);

      await tester.tap(find.text('Organic Bananas'));
      expect(tapped, isTrue);
    });
  });
}
