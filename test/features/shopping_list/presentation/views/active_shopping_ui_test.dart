import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/entities/shopping_session.dart';
import 'package:shopping_explore/features/shopping_list/presentation/widgets/active_shoppers_banner.dart';
import 'package:shopping_explore/features/shopping_list/presentation/widgets/shopping_item_editor_modal.dart';
import 'package:shopping_explore/features/shopping_list/presentation/widgets/shopping_item_tile.dart';
import 'package:shopping_explore/features/shopping_list/presentation/widgets/start_shopping_modal.dart';

void main() {
  group('Sprint 3: Active Shopping Mode UI & Assignment Tests', () {
    testWidgets('ActiveShoppersBanner renders shopper badge and location when activeSessions present',
        (tester) async {
      final session = ShoppingSession(
        userEmail: 'guy@shoppingexplore.com',
        locationName: 'Shufersal Market',
        startedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveShoppersBanner(
              activeSessions: [session],
              currentUserEmail: 'guy@shoppingexplore.com',
            ),
          ),
        ),
      );

      expect(find.text('Active Shoppers (1)'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('Shufersal Market'),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('You'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('ActiveShoppersBanner is hidden when activeSessions is empty',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ActiveShoppersBanner(
              activeSessions: [],
            ),
          ),
        ),
      );

      expect(find.textContaining('Active Shoppers'), findsNothing);
    });

    testWidgets('StartShoppingModal renders location chips and triggers onStart with location',
        (tester) async {
      String? selectedLocation;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  StartShoppingModal.show(
                    context,
                    listTitle: 'Weekly Groceries',
                    onStart: (loc) => selectedLocation = loc,
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Start Shopping'), findsOneWidget);
      expect(find.text('Supermarket'), findsOneWidget);

      await tester.tap(find.text('Supermarket'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Active Shopping'));
      await tester.pumpAndSettle();

      expect(selectedLocation, equals('Supermarket'));
    });

    testWidgets('ShoppingItemTile renders assignee badge when assignedToEmail is set',
        (tester) async {
      final item = ShoppingItem(
        id: 'item-1',
        title: 'Organic Milk',
        assignedToEmail: 'guy@shoppingexplore.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingItemTile(
              item: item,
              onToggle: () {},
              onDelete: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Guy C'), findsOneWidget); // Display name badge
      expect(find.text('Organic Milk'), findsOneWidget);
    });

    testWidgets('ShoppingItemEditorModal displays availableEmails chips and assigns user',
        (tester) async {
      final item = ShoppingItem(
        id: 'item-2',
        title: 'Apples',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      ShoppingItem? savedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => ShoppingItemEditorModal(
                      item: item,
                      availableEmails: const ['friend@shoppingexplore.com'],
                      onSave: (updated) => savedItem = updated,
                    ),
                  );
                },
                child: const Text('Edit Item'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Edit Item'));
      await tester.pumpAndSettle();

      expect(find.text('Taylor Friend'), findsOneWidget);

      // Scroll into view before tapping
      await tester.ensureVisible(find.text('Taylor Friend'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Taylor Friend'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Save Changes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(savedItem, isNotNull);
      expect(savedItem!.assignedToEmail, equals('friend@shoppingexplore.com'));
    });
  });
}
