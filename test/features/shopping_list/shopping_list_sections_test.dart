import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/shopping_list/data/datasources/shopping_list_local_datasource.dart';
import 'package:shopping_explore/features/shopping_list/data/models/shopping_item_dto.dart';
import 'package:shopping_explore/features/shopping_list/data/models/shopping_list_dto.dart';
import 'package:shopping_explore/features/shopping_list/data/repositories/shopping_list_repository_impl.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/create_shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/create_shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/delete_shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/delete_shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/get_shopping_lists.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/share_shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/toggle_item_completion.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/update_item_properties.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/update_shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/watch_shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/watch_shopping_lists.dart';
import 'package:shopping_explore/features/shopping_list/presentation/controllers/shopping_list_controller.dart';
import 'package:shopping_explore/features/shopping_list/presentation/views/shopping_list_detail_view.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';

void main() {
  group('ShoppingList 2-Section Checklist Widget Tests', () {
    late InMemoryShoppingListLocalDataSource dataSource;
    late ShoppingListRepositoryImpl repository;
    late ShoppingListController controller;

    setUp(() async {
      dataSource = InMemoryShoppingListLocalDataSource();
      repository = ShoppingListRepositoryImpl(localDataSource: dataSource);

      controller = ShoppingListController(
        getShoppingLists: GetShoppingLists(repository),
        createShoppingItem: CreateShoppingItem(repository),
        toggleItemCompletion: ToggleItemCompletion(repository),
        updateItemProperties: UpdateItemProperties(repository),
        deleteShoppingItem: DeleteShoppingItem(repository),
        shareShoppingList: ShareShoppingList(repository),
        createShoppingList: CreateShoppingList(repository),
        updateShoppingList: UpdateShoppingList(repository),
        deleteShoppingList: DeleteShoppingList(repository),
        watchShoppingLists: WatchShoppingLists(repository),
        watchShoppingList: WatchShoppingList(repository),
      );

      final now = DateTime.now();
      await dataSource.saveShoppingList(
        ShoppingListDto(
          id: 'list-sections-1',
          title: 'Section Test List',
          ownerId: 'guy@shoppingexplore.com',
          createdAt: now,
          updatedAt: now,
        ),
      );
      await dataSource.saveShoppingItem(
        'list-sections-1',
        ShoppingItemDto(
          id: 'item-unmarked-1',
          title: 'Fresh Milk',
          isCompleted: false,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await dataSource.saveShoppingItem(
        'list-sections-1',
        ShoppingItemDto(
          id: 'item-marked-1',
          title: 'Bread',
          isCompleted: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await controller.loadShoppingLists();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('Renders To Buy and Completed sections with correct counts when not in shopping mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', '')],
          locale: const Locale('en', ''),
          home: ShoppingListDetailView(
            listId: 'list-sections-1',
            controller: controller,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('To Buy (1)'), findsOneWidget);
      expect(find.text('Completed (1)'), findsOneWidget);
      expect(find.text('Fresh Milk'), findsOneWidget);
      expect(find.text('Bread'), findsOneWidget);
      expect(find.text('Live Sync'), findsOneWidget);
    });

    testWidgets('Renders Hebrew localized sections when in Hebrew locale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('he', ''), Locale('en', '')],
          locale: const Locale('he', ''),
          home: ShoppingListDetailView(
            listId: 'list-sections-1',
            controller: controller,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('לקנות (1)'), findsOneWidget);
      expect(find.text('הושלמו (1)'), findsOneWidget);
      expect(find.text('סנכרון חי'), findsOneWidget);
    });
  });
}
