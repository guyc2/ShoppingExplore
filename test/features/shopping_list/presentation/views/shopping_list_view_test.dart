import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/shopping_list/data/datasources/shopping_list_local_datasource.dart';
import 'package:shopping_explore/features/shopping_list/data/repositories/shopping_list_repository_impl.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/create_shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/delete_shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/get_shopping_lists.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/toggle_item_completion.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/update_item_properties.dart';
import 'package:shopping_explore/features/shopping_list/presentation/controllers/shopping_list_controller.dart';
import 'package:shopping_explore/features/shopping_list/presentation/views/shopping_list_view.dart';

void main() {
  group('ShoppingListView Screen Test', () {
    late InMemoryShoppingListLocalDataSource localDataSource;
    late ShoppingListRepositoryImpl repository;
    late ShoppingListController controller;

    setUp(() {
      localDataSource = InMemoryShoppingListLocalDataSource.withDefaultData();
      repository = ShoppingListRepositoryImpl(localDataSource: localDataSource);
      controller = ShoppingListController(
        getShoppingLists: GetShoppingLists(repository),
        createShoppingItem: CreateShoppingItem(repository),
        toggleItemCompletion: ToggleItemCompletion(repository),
        updateItemProperties: UpdateItemProperties(repository),
        deleteShoppingItem: DeleteShoppingItem(repository),
      );
    });

    testWidgets('renders default weekly groceries list and allows quick adding item', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ShoppingListView(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Weekly Groceries'), findsOneWidget);
      expect(find.text('Organic Honeycrisp Apples'), findsOneWidget);
      expect(find.text('Almond Milk (Unsweetened)'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Fresh Bread');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Fresh Bread'), findsOneWidget);
    });
  });
}
