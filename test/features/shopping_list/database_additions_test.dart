import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/shopping_list/data/datasources/shopping_list_remote_datasource.dart';
import 'package:shopping_explore/features/shopping_list/data/models/shopping_list_dto.dart';
import 'package:shopping_explore/features/shopping_list/data/models/shopping_item_dto.dart';
import 'package:shopping_explore/features/shopping_list/data/repositories/shopping_list_repository_impl.dart';
import 'package:shopping_explore/features/shopping_list/domain/entities/shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/domain/entities/product_suggestion.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/create_shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/create_shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/delete_shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/toggle_item_completion.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/update_item_properties.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/get_shopping_lists.dart';
import 'package:shopping_explore/features/shopping_list/presentation/controllers/shopping_list_controller.dart';
import 'package:shopping_explore/features/shopping_list/presentation/controllers/shopping_list_state.dart';
import '../../shared_fakes.dart';

void main() {
  group('Database Additions & Query Verification Tests', () {
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
        createShoppingItem: CreateShoppingItem(repository),
        toggleItemCompletion: ToggleItemCompletion(repository),
        updateItemProperties: UpdateItemProperties(repository),
        deleteShoppingItem: DeleteShoppingItem(repository),
      );
    });

    test('Creating a new shopping list via Controller saves and retrieves it successfully', () async {
      await controller.loadShoppingLists();
      expect(controller.value, isA<ShoppingListLoaded>());
      final initialLists = (controller.value as ShoppingListLoaded).lists;
      final initialCount = initialLists.length;

      final newList = await controller.createList(
        title: 'Party Supplies',
        shortDescription: 'Snacks & drinks',
        colorHex: '#EC4899',
        imageUrl: 'party',
        ownerId: 'test@shoppingexplore.com',
      );

      expect(newList, isNotNull);
      expect(newList!.title, 'Party Supplies');
      expect(newList.ownerId, 'test@shoppingexplore.com');

      // Reload lists and verify new list is included
      await controller.loadShoppingLists();
      final updatedLists = (controller.value as ShoppingListLoaded).lists;
      expect(updatedLists.length, initialCount + 1);
      expect(updatedLists.any((ShoppingList l) => l.title == 'Party Supplies'), isTrue);
    });

    test('Creating a shopping list in unauthenticated/guest state keeps list accessible', () async {
      final newList = await controller.createList(
        title: 'Guest List',
        shortDescription: 'Unauthenticated user list',
        colorHex: '#4CAF50',
        imageUrl: 'grocery',
        ownerId: null,
      );

      expect(newList, isNotNull);
      expect(newList!.title, 'Guest List');

      // Fetch lists with empty user email (guest mode)
      final listsResult = await repository.getShoppingLists();
      expect(listsResult.isSuccess, isTrue);
      final lists = listsResult.value;
      expect(lists.any((l) => l.title == 'Guest List'), isTrue);
    });

    test('Adding a suggestion to an item preserves item and suggestion in database', () async {
      await controller.loadShoppingLists();
      final loadedLists = (controller.value as ShoppingListLoaded).lists;
      final targetList = loadedLists.first;
      final targetItem = targetList.items.first;

      const newSuggestion = ProductSuggestion(
        id: 'sug-1',
        name: 'Gala Apples Pack',
        description: 'Crisp & sweet',
        price: 3.99,
        pros: ['Crisp', 'Sweet'],
        cons: ['Perishable'],
      );

      final updatedSuggestions = [...targetItem.suggestions, newSuggestion];
      final updatedItem = targetItem.copyWith(suggestions: updatedSuggestions);

      final updateResult = await repository.saveShoppingItem(targetList.id, ShoppingItemDto.fromDomain(updatedItem));
      expect(updateResult.isSuccess, isTrue);

      final fetchedListResult = await repository.getShoppingList(targetList.id);
      expect(fetchedListResult.isSuccess, isTrue);
      final fetchedItem = fetchedListResult.value.items.firstWhere((i) => i.id == targetItem.id);
      expect(fetchedItem.suggestions.length, 1);
      expect(fetchedItem.suggestions.first.name, 'Gala Apples Pack');
      expect(fetchedItem.suggestions.first.price, 3.99);
    });

    test('ShoppingListDto toFirestore includes both ownerId and ownerEmail for Firestore queries', () {
      final now = DateTime.now();
      final dto = ShoppingListDto(
        id: 'list-123',
        title: 'Test List',
        ownerId: 'user@shoppingexplore.com',
        createdAt: now,
        updatedAt: now,
      );

      final firestoreData = dto.toFirestore();
      expect(firestoreData['ownerId'], 'user@shoppingexplore.com');
      expect(firestoreData['ownerEmail'], 'user@shoppingexplore.com');

      final reconstructed = ShoppingListDto.fromFirestore(firestoreData);
      expect(reconstructed.ownerId, 'user@shoppingexplore.com');
    });
  });
}
