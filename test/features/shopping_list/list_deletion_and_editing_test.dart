import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/shopping_list/data/datasources/shopping_list_remote_datasource.dart';
import 'package:shopping_explore/features/shopping_list/data/repositories/shopping_list_repository_impl.dart';
import 'package:shopping_explore/features/shopping_list/domain/entities/product_suggestion.dart';
import 'package:shopping_explore/features/shopping_list/domain/entities/shopping_item.dart';

import 'package:shopping_explore/features/shopping_list/domain/usecases/create_shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/create_shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/delete_shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/delete_shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/toggle_item_completion.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/update_item_properties.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/update_shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/get_shopping_lists.dart';
import 'package:shopping_explore/features/shopping_list/presentation/controllers/shopping_list_controller.dart';
import 'package:shopping_explore/features/shopping_list/presentation/controllers/shopping_list_state.dart';
import 'package:shopping_explore/features/shopping_list/presentation/widgets/shopping_list_card.dart';
import 'package:shopping_explore/features/shopping_list/presentation/views/shopping_item_detail_page.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';
import '../../shared_fakes.dart';

void main() {
  group('List Deletion, Editing & Suggestions Instant UI Tests', () {
    late InMemoryShoppingListRemoteDataSource remoteDataSource;
    late ShoppingListRepositoryImpl repository;
    late ShoppingListController controller;

    setUp(() {
      remoteDataSource = InMemoryShoppingListRemoteDataSource.withDefaultData();
      repository = ShoppingListRepositoryImpl(
        remoteDataSource: remoteDataSource,
        storageRepository: FakeStorageRepository(),
      );
      controller = ShoppingListController(
        getShoppingLists: GetShoppingLists(repository),
        createShoppingList: CreateShoppingList(repository),
        updateShoppingList: UpdateShoppingList(repository),
        deleteShoppingList: DeleteShoppingList(repository),
        createShoppingItem: CreateShoppingItem(repository),
        toggleItemCompletion: ToggleItemCompletion(repository),
        updateItemProperties: UpdateItemProperties(repository),
        deleteShoppingItem: DeleteShoppingItem(repository),
      );
    });

    test('Optimistic deleteList instantly removes list from controller state', () async {
      await controller.loadShoppingLists();
      expect(controller.value, isA<ShoppingListLoaded>());
      final initialLists = (controller.value as ShoppingListLoaded).lists;
      final targetId = initialLists.first.id;

      // Invoking deleteList immediately updates local state
      final deleteFuture = controller.deleteList(targetId);
      final currentLists = (controller.value as ShoppingListLoaded).lists;
      expect(currentLists.any((l) => l.id == targetId), isFalse);

      final success = await deleteFuture;
      expect(success, isTrue);
    });

    test('Optimistic addItem instantly appends item to controller state', () async {
      await controller.loadShoppingLists();
      expect(controller.value, isA<ShoppingListLoaded>());
      final loadedLists = (controller.value as ShoppingListLoaded).lists;
      final targetList = loadedLists.first;
      final initialItemCount = targetList.items.length;

      final now = DateTime.now();
      final newItem = ShoppingItem(
        id: 'test-new-item-${now.millisecondsSinceEpoch}',
        title: 'Test Optimistic Item',
        createdAt: now,
        updatedAt: now,
      );

      // Invoke addItem (do NOT await — check optimistic state immediately)
      final addFuture = controller.addItem(targetList.id, newItem);
      final stateAfterOptimistic = (controller.value as ShoppingListLoaded).lists
          .firstWhere((l) => l.id == targetList.id);
      expect(stateAfterOptimistic.items.length, initialItemCount + 1);
      expect(stateAfterOptimistic.items.any((i) => i.title == 'Test Optimistic Item'), isTrue);

      await addFuture;
      // After completion, item should still be present
      final stateAfterComplete = (controller.value as ShoppingListLoaded).lists
          .firstWhere((l) => l.id == targetList.id);
      expect(stateAfterComplete.items.any((i) => i.title == 'Test Optimistic Item'), isTrue);
    });

    test('addItem failure reverts to previous loaded state, not ShoppingListError', () async {
      await controller.loadShoppingLists();
      expect(controller.value, isA<ShoppingListLoaded>());

      // Use a non-existent list id to force a CacheFailure
      final now = DateTime.now();
      final newItem = ShoppingItem(
        id: 'fail-item',
        title: 'Should Fail',
        createdAt: now,
        updatedAt: now,
      );

      final previousState = controller.value;
      await controller.addItem('non-existent-list-id', newItem);

      // State should be reverted to the previous loaded state, NOT ShoppingListError
      expect(controller.value, isA<ShoppingListLoaded>());
      expect(controller.value, equals(previousState));
    });



    testWidgets('3-dots menu on ShoppingListCard shows Edit and Delete options', (WidgetTester tester) async {
      final list = (InMemoryShoppingListRemoteDataSource.withDefaultData()
              .getShoppingLists('test@shoppingexplore.com'))
          .then((l) => l.first);
      final targetList = await list;

      bool editTapped = false;
      bool deleteTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('he')],
          home: Scaffold(
            body: ShoppingListCard(
              shoppingList: targetList.toDomain(),
              onTap: () {},
              onEdit: () => editTapped = true,
              onDelete: () => deleteTapped = true,
            ),
          ),
        ),
      );

      // Tap 3-dots popup menu
      final popupFinder = find.byType(PopupMenuButton<String>);
      expect(popupFinder, findsOneWidget);
      await tester.tap(popupFinder);
      await tester.pumpAndSettle();

      expect(find.text('Edit List Information'), findsOneWidget);
      expect(find.text('Delete List'), findsOneWidget);

      await tester.tap(find.text('Edit List Information'));
      await tester.pumpAndSettle();
      expect(editTapped, isTrue);
      expect(deleteTapped, isFalse);
    });

    testWidgets('Delete confirmation dialog displays Hebrew localized text in Hebrew locale', (WidgetTester tester) async {
      final list = (await InMemoryShoppingListRemoteDataSource.withDefaultData()
              .getShoppingLists('test@shoppingexplore.com'))
          .first;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('he'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('he'), Locale('en')],
          home: Scaffold(
            body: ShoppingListCard(
              shoppingList: list.toDomain(),
              onTap: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Tap 3-dots menu and select Delete List
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('מחק רשימה'));
      await tester.pumpAndSettle();

      // Verify Hebrew alert dialog title and confirm prompt
      expect(find.text('מחק רשימה'), findsNWidgets(2)); // Menu item + Dialog title
      expect(find.text('האם אתה בטוח שברצונך למחוק רשימה זו?'), findsOneWidget);
      expect(find.text('ביטול'), findsOneWidget);
    });

    testWidgets('Deleting a suggestion in ShoppingItemDetailPage instantly updates UI', (WidgetTester tester) async {
      await controller.loadShoppingLists();
      final loadedList = (controller.value as ShoppingListLoaded).lists.first;

      const suggestion = ProductSuggestion(
        id: 'sug-test-1',
        name: 'Organic Milk',
        price: 4.50,
      );

      final itemWithSuggestion = loadedList.items.first.copyWith(
        suggestions: [suggestion],
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: ShoppingItemDetailPage(
            initialItem: itemWithSuggestion,
            listId: loadedList.id,
            controller: controller,
            availableEmails: const [],
            imageStorageService: FakeImageStorageService(),
          ),
        ),
      );

      expect(find.text('Organic Milk'), findsOneWidget);

      // Expand the suggestion card
      final expandIcon = find.byIcon(Icons.add);
      expect(expandIcon, findsOneWidget);
      await tester.tap(expandIcon);
      await tester.pumpAndSettle();

      // Delete suggestion
      final deleteIcon = find.byIcon(Icons.delete_outline);
      expect(deleteIcon, findsOneWidget);
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      // Verify suggestion is removed immediately
      expect(find.text('Organic Milk'), findsNothing);
    });
  });
}
