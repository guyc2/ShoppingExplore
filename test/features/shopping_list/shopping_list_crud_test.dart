import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/shopping_list/data/datasources/shopping_list_local_datasource.dart';
import 'package:shopping_explore/features/shopping_list/data/repositories/shopping_list_repository_impl.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/create_shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/delete_shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/get_shopping_lists.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/update_shopping_list.dart';

void main() {
  group('Shopping List CRUD Domain & Repository Tests', () {
    late InMemoryShoppingListLocalDataSource localDataSource;
    late ShoppingListRepositoryImpl repository;
    late CreateShoppingList createUseCase;
    late UpdateShoppingList updateUseCase;
    late DeleteShoppingList deleteUseCase;
    late GetShoppingLists getUseCase;

    setUp(() {
      localDataSource = InMemoryShoppingListLocalDataSource();
      repository = ShoppingListRepositoryImpl(localDataSource: localDataSource);
      createUseCase = CreateShoppingList(repository);
      updateUseCase = UpdateShoppingList(repository);
      deleteUseCase = DeleteShoppingList(repository);
      getUseCase = GetShoppingLists(repository);
    });

    test('createShoppingList creates a new list with shortDescription and imageUrl', () async {
      final createResult = await createUseCase.execute(
        title: 'New List',
        shortDescription: 'Short desc',
        description: 'Full desc',
        colorHex: '#FF0000',
        imageUrl: 'tech',
        ownerId: 'guy@shoppingexplore.com',
      );

      expect(createResult.isSuccess, isTrue);
      expect(createResult.value.title, equals('New List'));
      expect(createResult.value.shortDescription, equals('Short desc'));
      expect(createResult.value.imageUrl, equals('tech'));

      final getResult = await getUseCase.execute();
      expect(getResult.isSuccess, isTrue);
      expect(getResult.value.length, equals(1));
    });

    test('updateShoppingList updates title and description', () async {
      final createResult = await createUseCase.execute(
        title: 'Initial Title',
      );
      final list = createResult.value;
      final updatedList = list.copyWith(title: 'Updated Title', shortDescription: 'Updated Short');

      final updateResult = await updateUseCase.execute(updatedList);
      expect(updateResult.isSuccess, isTrue);
      expect(updateResult.value.title, equals('Updated Title'));
      expect(updateResult.value.shortDescription, equals('Updated Short'));
    });

    test('deleteShoppingList removes the list from repository', () async {
      final createResult = await createUseCase.execute(title: 'To Be Deleted');
      final listId = createResult.value.id;

      final delResult = await deleteUseCase.execute(listId);
      expect(delResult.isSuccess, isTrue);

      final getResult = await getUseCase.execute();
      expect(getResult.isSuccess, isTrue);
      expect(getResult.value.isEmpty, isTrue);
    });
  });
}
