import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/shopping_list/data/datasources/shopping_list_local_datasource.dart';
import 'package:shopping_explore/features/shopping_list/data/repositories/shopping_list_repository_impl.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/share_shopping_list.dart';

void main() {
  late InMemoryShoppingListLocalDataSource dataSource;
  late ShoppingListRepositoryImpl repository;

  setUp(() {
    dataSource = InMemoryShoppingListLocalDataSource.withDefaultData();
    repository = ShoppingListRepositoryImpl(localDataSource: dataSource);
  });

  group('Shopping List Sharing Tests', () {
    test('shareShoppingList adds email to sharedWithEmails list', () async {
      final shareUseCase = ShareShoppingList(repository);

      final result = await shareUseCase.execute(
        'default-list',
        'colleague@shoppingexplore.com',
      );

      expect(result.isSuccess, isTrue);
      expect(
        result.value.sharedWithEmails,
        contains('colleague@shoppingexplore.com'),
      );
    });

    test('shareShoppingList does not duplicate existing shared emails', () async {
      final shareUseCase = ShareShoppingList(repository);

      await shareUseCase.execute('default-list', 'friend@shoppingexplore.com');
      final result = await shareUseCase.execute(
        'default-list',
        'friend@shoppingexplore.com',
      );

      expect(result.isSuccess, isTrue);
      final occurrences = result.value.sharedWithEmails
          .where((e) => e == 'friend@shoppingexplore.com')
          .length;
      expect(occurrences, equals(1));
    });
  });
}
