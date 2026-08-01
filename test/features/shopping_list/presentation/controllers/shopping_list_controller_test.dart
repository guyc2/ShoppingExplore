import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/shopping_list/data/datasources/shopping_list_local_datasource.dart';
import 'package:shopping_explore/features/shopping_list/data/models/shopping_list_dto.dart';
import 'package:shopping_explore/features/shopping_list/data/repositories/shopping_list_repository_impl.dart';
import 'package:shopping_explore/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/create_shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/delete_shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/get_shopping_lists.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/toggle_item_completion.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/update_item_properties.dart';
import 'package:shopping_explore/features/shopping_list/presentation/controllers/shopping_list_controller.dart';
import 'package:shopping_explore/features/shopping_list/presentation/controllers/shopping_list_state.dart';

void main() {
  group('ShoppingListController', () {
    late InMemoryShoppingListLocalDataSource localDataSource;
    late ShoppingListRepositoryImpl repository;
    late ShoppingListController controller;

    final now = DateTime(2026, 1, 1);
    final initialList = ShoppingListDto(
      id: 'list-1',
      title: 'Groceries',
      createdAt: now,
      updatedAt: now,
    );
    final testItem = ShoppingItem(
      id: 'item-1',
      title: 'Milk',
      createdAt: now,
      updatedAt: now,
    );

    setUp(() async {
      localDataSource = InMemoryShoppingListLocalDataSource();
      await localDataSource.saveShoppingList(initialList);
      repository = ShoppingListRepositoryImpl(localDataSource: localDataSource);
      controller = ShoppingListController(
        getShoppingLists: GetShoppingLists(repository),
        createShoppingItem: CreateShoppingItem(repository),
        toggleItemCompletion: ToggleItemCompletion(repository),
        updateItemProperties: UpdateItemProperties(repository),
        deleteShoppingItem: DeleteShoppingItem(repository),
      );
    });

    test('initial state is ShoppingListInitial', () {
      expect(controller.value, equals(const ShoppingListInitial()));
    });

    test('loadShoppingLists emits Loaded state on success', () async {
      await controller.loadShoppingLists();
      expect(controller.value, isA<ShoppingListLoaded>());
      final loaded = controller.value as ShoppingListLoaded;
      expect(loaded.lists.length, equals(1));
    });

    test('addItem adds item and refreshes lists state', () async {
      await controller.addItem('list-1', testItem);
      expect(controller.value, isA<ShoppingListLoaded>());
      final loaded = controller.value as ShoppingListLoaded;
      expect(loaded.lists.first.items.length, equals(1));
      expect(loaded.lists.first.items.first.title, equals('Milk'));
    });

    test('toggleItem updates completion status in Loaded state', () async {
      await controller.addItem('list-1', testItem);
      await controller.toggleItem('list-1', testItem);
      final loaded = controller.value as ShoppingListLoaded;
      expect(loaded.lists.first.items.first.isCompleted, isTrue);
    });

    test('deleteItem removes item from list in Loaded state', () async {
      await controller.addItem('list-1', testItem);
      await controller.deleteItem('list-1', 'item-1');
      final loaded = controller.value as ShoppingListLoaded;
      expect(loaded.lists.first.items, isEmpty);
    });
  });
}
