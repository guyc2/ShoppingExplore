import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/shopping_list/data/datasources/shopping_list_remote_datasource.dart';
import 'package:shopping_explore/core/storage/domain/repositories/storage_repository.dart';
import 'package:shopping_explore/features/shopping_list/data/models/shopping_list_dto.dart';
import 'package:shopping_explore/features/shopping_list/data/repositories/shopping_list_repository_impl.dart';
import 'package:shopping_explore/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/create_shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/create_shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/delete_shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/delete_shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/get_shopping_lists.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/toggle_item_completion.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/update_item_properties.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/update_shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/watch_shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/watch_shopping_lists.dart';
import 'package:shopping_explore/features/shopping_list/presentation/controllers/shopping_list_controller.dart';
import 'package:shopping_explore/features/shopping_list/presentation/controllers/shopping_list_state.dart';

class FakeStorageRepository extends Fake implements StorageRepository {}

void main() {
  group('ShoppingList Real-Time Reactive Sync Tests', () {
    late InMemoryShoppingListRemoteDataSource dataSource;
    late ShoppingListRepositoryImpl repository;
    late ShoppingListController controller;

    setUp(() {
      dataSource = InMemoryShoppingListRemoteDataSource();
      repository = ShoppingListRepositoryImpl(remoteDataSource: dataSource,
        storageRepository: FakeStorageRepository());

      controller = ShoppingListController(
        getShoppingLists: GetShoppingLists(repository),
        createShoppingItem: CreateShoppingItem(repository),
        toggleItemCompletion: ToggleItemCompletion(repository),
        updateItemProperties: UpdateItemProperties(repository),
        deleteShoppingItem: DeleteShoppingItem(repository),
        createShoppingList: CreateShoppingList(repository),
        updateShoppingList: UpdateShoppingList(repository),
        deleteShoppingList: DeleteShoppingList(repository),
        watchShoppingLists: WatchShoppingLists(repository),
        watchShoppingList: WatchShoppingList(repository),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('watchShoppingLists emits initial state and updates when a new list is saved', () async {
      final stream = repository.watchShoppingLists(null);

      final events = <int>[];
      final subscription = stream.listen((result) {
        if (result.isSuccess) {
          events.add(result.value.length);
        }
      });

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, equals([0]));

      final now = DateTime.now();
      final newList = ShoppingListDto(
        id: 'list-1',
        title: 'New Sync List',
        ownerId: 'test@shoppingexplore.com',
        createdAt: now,
        updatedAt: now,
      );

      await dataSource.saveShoppingList(newList);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(events, equals([0, 1]));
      await subscription.cancel();
    });

    test('watchShoppingList emits updates when an item is added to the list', () async {
      final now = DateTime.now();
      final initialList = ShoppingListDto(
        id: 'list-2',
        title: 'Grocery Sync',
        ownerId: 'test@shoppingexplore.com',
        createdAt: now,
        updatedAt: now,
      );
      await dataSource.saveShoppingList(initialList);

      final stream = repository.watchShoppingList('list-2');
      final itemCounts = <int>[];
      final subscription = stream.listen((result) {
        if (result.isSuccess) {
          itemCounts.add(result.value.items.length);
        }
      });

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(itemCounts, equals([0]));

      final item = ShoppingItem(
        id: 'item-1',
        title: 'Milk',
        createdAt: now,
        updatedAt: now,
      );
      await repository.saveShoppingItem('list-2', item);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(itemCounts, equals([0, 1]));
      await subscription.cancel();
    });

    test('ShoppingListController subscribeToShoppingLists auto-updates value on datasource mutation', () async {
      controller.subscribeToShoppingLists('guy@shoppingexplore.com');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(controller.value, isA<ShoppingListLoaded>());
      expect((controller.value as ShoppingListLoaded).lists.length, equals(0));

      await controller.createList(
        title: 'Collaborative BBQ List',
        ownerId: 'test@shoppingexplore.com',
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(controller.value, isA<ShoppingListLoaded>());
      expect((controller.value as ShoppingListLoaded).lists.length, equals(1));
      expect((controller.value as ShoppingListLoaded).lists.first.title, equals('Collaborative BBQ List'));
    });
  });
}
