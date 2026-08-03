import '../../../../core/error/result.dart';
import '../entities/shopping_list.dart';
import '../repositories/shopping_list_repository.dart';

class WatchShoppingList {
  final ShoppingListRepository repository;

  WatchShoppingList(this.repository);

  Stream<Result<ShoppingList>> call(String listId) {
    return repository.watchShoppingList(listId);
  }
}
