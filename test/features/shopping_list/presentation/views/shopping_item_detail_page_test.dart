import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/shopping_list/domain/entities/product_suggestion.dart';
import 'package:shopping_explore/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/presentation/controllers/shopping_list_controller.dart';
import 'package:shopping_explore/features/shopping_list/presentation/controllers/shopping_list_state.dart';
import 'package:shopping_explore/features/shopping_list/presentation/views/shopping_item_detail_page.dart';
import 'package:shopping_explore/features/shopping_list/presentation/widgets/product_suggestion_card.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';

class FakeShoppingListController extends ValueNotifier<ShoppingListState> implements ShoppingListController {
  FakeShoppingListController() : super(const ShoppingListInitial());

  @override
  ShoppingList? getList(String listId) {
    if (value is ShoppingListLoaded) {
      final lists = (value as ShoppingListLoaded).lists;
      final idx = lists.indexWhere((l) => l.id == listId);
      if (idx >= 0) return lists[idx];
    }
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ShoppingItemDetailPage UI', () {
    late FakeShoppingListController fakeController;

    final tItem = ShoppingItem(
      id: '1',
      title: 'Apples',
      priority: Priority.high,
      suggestions: [
        ProductSuggestion(id: 's1', name: 'Suggestion 1', pros: ['Good']),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      fakeController = FakeShoppingListController();
      fakeController.value = ShoppingListLoaded([
        ShoppingList(
          id: 'list-1',
          title: 'List 1',
          ownerId: 'owner',
          items: [tItem],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )
      ]);
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ShoppingItemDetailPage(
            initialItem: tItem,
            listId: 'list-1',
            controller: fakeController,
            availableEmails: const [],
          ),
        ),
      );
    }

    testWidgets('renders item title and existing suggestions', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Apples'), findsOneWidget);
      expect(find.text('HIGH'), findsOneWidget);
      
      expect(find.byType(ProductSuggestionCard), findsOneWidget);
      expect(find.text('Suggestion 1'), findsOneWidget);
    });

    testWidgets('Add Suggestion modal opens on FAB tap', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      
      await tester.tap(fab);
      await tester.pumpAndSettle();

      expect(find.text('Save Suggestion'), findsOneWidget);
    });
  });
}
