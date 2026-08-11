import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/shopping_list/data/datasources/shopping_list_remote_datasource.dart';
import 'package:shopping_explore/core/storage/domain/repositories/storage_repository.dart';
import 'package:shopping_explore/features/shopping_list/data/models/shopping_list_dto.dart';
import 'package:shopping_explore/features/shopping_list/data/repositories/shopping_list_repository_impl.dart';
import 'package:shopping_explore/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/create_shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/delete_shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/get_shopping_lists.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/share_shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/remove_collaborator.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/toggle_item_completion.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/update_item_properties.dart';

class FakeStorageRepository extends Fake implements StorageRepository {}

void main() {
  group('ShoppingList UseCases', () {
    late InMemoryShoppingListRemoteDataSource localDataSource;
    late ShoppingListRepositoryImpl repository;
    late GetShoppingLists getShoppingLists;
    late CreateShoppingItem createShoppingItem;
    late ToggleItemCompletion toggleItemCompletion;
    late UpdateItemProperties updateItemProperties;
    late DeleteShoppingItem deleteShoppingItem;

    final now = DateTime(2026, 1, 1);
    final initialList = ShoppingListDto(
      id: 'list-1',
      title: 'Groceries',
      ownerId: 'test@shoppingexplore.com',
      createdAt: now,
      updatedAt: now,
    );
    final testItem = ShoppingItem(
      id: 'item-1',
      title: 'Apples',
      quantity: 1.0,
      createdAt: now,
      updatedAt: now,
    );

    setUp(() async {
      localDataSource = InMemoryShoppingListRemoteDataSource();
      await localDataSource.saveShoppingList(initialList);
      repository = ShoppingListRepositoryImpl(remoteDataSource: localDataSource,
        storageRepository: FakeStorageRepository());
      getShoppingLists = GetShoppingLists(repository);
      createShoppingItem = CreateShoppingItem(repository);
      toggleItemCompletion = ToggleItemCompletion(repository);
      updateItemProperties = UpdateItemProperties(repository);
      deleteShoppingItem = DeleteShoppingItem(repository);
    });

    test('GetShoppingLists returns saved lists', () async {
      final result = await getShoppingLists.execute();
      expect(result.isSuccess, isTrue);
      expect(result.value.length, equals(1));
      expect(result.value.first.id, equals('list-1'));
    });

    test('CreateShoppingItem adds item to list', () async {
      final addResult = await createShoppingItem.execute(listId: 'list-1', item: testItem);
      expect(addResult.isSuccess, isTrue);

      final listResult = await getShoppingLists.execute();
      expect(listResult.value.first.items.length, equals(1));
      expect(listResult.value.first.items.first.title, equals('Apples'));
    });

    test('ToggleItemCompletion flips isCompleted state', () async {
      await createShoppingItem.execute(listId: 'list-1', item: testItem);
      final toggleResult = await toggleItemCompletion.execute(listId: 'list-1', item: testItem);
      expect(toggleResult.isSuccess, isTrue);

      final listResult = await getShoppingLists.execute();
      expect(listResult.value.first.items.first.isCompleted, isTrue);
    });

    test('UpdateItemProperties updates rich item fields', () async {
      await createShoppingItem.execute(listId: 'list-1', item: testItem);
      final updated = testItem.copyWith(notes: 'Honeycrisp', priority: Priority.high);
      final updateResult = await updateItemProperties.execute(listId: 'list-1', updatedItem: updated);
      expect(updateResult.isSuccess, isTrue);

      final listResult = await getShoppingLists.execute();
      final fetchedItem = listResult.value.first.items.first;
      expect(fetchedItem.notes, equals('Honeycrisp'));
      expect(fetchedItem.priority, equals(Priority.high));
    });

    test('DeleteShoppingItem removes item from list', () async {
      await createShoppingItem.execute(listId: 'list-1', item: testItem);
      final deleteResult = await deleteShoppingItem.execute(listId: 'list-1', itemId: 'item-1');
      expect(deleteResult.isSuccess, isTrue);

      final listResult = await getShoppingLists.execute();
      expect(listResult.value.first.items, isEmpty);
    });

    test('ShareShoppingList and RemoveCollaborator manage list collaborators', () async {
      final share = ShareShoppingList(repository);
      final remove = RemoveCollaborator(repository);

      final shareResult = await share.execute('list-1', 'friend@shoppingexplore.com', displayName: 'Taylor');
      expect(shareResult.isSuccess, isTrue);
      expect(shareResult.value.sharedWithEmails, contains('friend@shoppingexplore.com'));
      expect(shareResult.value.collaboratorDisplayNames['friend@shoppingexplore.com'], equals('Taylor'));

      final removeResult = await remove.execute('list-1', 'friend@shoppingexplore.com');
      expect(removeResult.isSuccess, isTrue);
      expect(removeResult.value.sharedWithEmails, isNot(contains('friend@shoppingexplore.com')));
      expect(removeResult.value.collaboratorDisplayNames.containsKey('friend@shoppingexplore.com'), isFalse);
    });
  });
}
