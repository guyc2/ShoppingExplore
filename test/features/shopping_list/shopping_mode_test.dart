import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/shopping_list/data/datasources/shopping_list_remote_datasource.dart';
import 'package:shopping_explore/core/storage/domain/repositories/storage_repository.dart';
import 'package:shopping_explore/features/shopping_list/data/repositories/shopping_list_repository_impl.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/create_shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/delete_shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/get_shopping_lists.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/toggle_item_completion.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/update_item_properties.dart';
import 'package:shopping_explore/features/shopping_list/presentation/controllers/shopping_list_controller.dart';

class FakeStorageRepository extends Fake implements StorageRepository {}

void main() {
  group('Active Shopping Mode Controller Tests', () {
    late InMemoryShoppingListRemoteDataSource localDataSource;
    late ShoppingListRepositoryImpl repository;
    late ShoppingListController controller;

    setUp(() {
      localDataSource = InMemoryShoppingListRemoteDataSource.withDefaultData();
      repository = ShoppingListRepositoryImpl(remoteDataSource: localDataSource,
        storageRepository: FakeStorageRepository());
      controller = ShoppingListController(
        getShoppingLists: GetShoppingLists(repository),
        createShoppingItem: CreateShoppingItem(repository),
        toggleItemCompletion: ToggleItemCompletion(repository),
        updateItemProperties: UpdateItemProperties(repository),
        deleteShoppingItem: DeleteShoppingItem(repository),
      );
    });

    test('enterShoppingMode and removeItemInShoppingMode track removed items without deleting from datasource', () async {
      await controller.loadShoppingLists();
      const listId = 'default-list';
      const itemId = 'item-1';

      expect(controller.isShoppingMode(listId), isFalse);
      expect(controller.removedCartItemIds(listId), isEmpty);

      controller.enterShoppingMode(listId);
      expect(controller.isShoppingMode(listId), isTrue);

      controller.removeItemInShoppingMode(listId, itemId);
      expect(controller.removedCartItemIds(listId), contains(itemId));

      // Ensure item still exists in repository datasource
      final fetched = await repository.getShoppingList(listId);
      expect(fetched.value.items.any((i) => i.id == itemId), isTrue);
    });

    test('restoreItemFromCart removes item from cart in Shopping Mode', () async {
      await controller.loadShoppingLists();
      const listId = 'default-list';
      const itemId = 'item-1';

      controller.enterShoppingMode(listId);
      controller.removeItemInShoppingMode(listId, itemId);
      expect(controller.removedCartItemIds(listId), contains(itemId));

      controller.restoreItemFromCart(listId, itemId);
      expect(controller.removedCartItemIds(listId), isEmpty);
    });

    test('cancelShoppingMode clears removed items and restores list without deletion', () async {
      await controller.loadShoppingLists();
      const listId = 'default-list';
      const itemId = 'item-1';

      controller.enterShoppingMode(listId);
      controller.removeItemInShoppingMode(listId, itemId);
      expect(controller.removedCartItemIds(listId), contains(itemId));

      await controller.cancelShoppingMode(listId);
      expect(controller.isShoppingMode(listId), isFalse);
      expect(controller.removedCartItemIds(listId), isEmpty);

      final fetched = await repository.getShoppingList(listId);
      expect(fetched.value.items.any((i) => i.id == itemId), isTrue);
    });

    test('completeShoppingMode permanently deletes removed items from datasource', () async {
      await controller.loadShoppingLists();
      const listId = 'default-list';
      const itemId = 'item-1';

      controller.enterShoppingMode(listId);
      controller.removeItemInShoppingMode(listId, itemId);

      await controller.completeShoppingMode(listId);
      expect(controller.isShoppingMode(listId), isFalse);
      expect(controller.removedCartItemIds(listId), isEmpty);

      final fetched = await repository.getShoppingList(listId);
      expect(fetched.value.items.any((i) => i.id == itemId), isFalse);
    });
  });
}
