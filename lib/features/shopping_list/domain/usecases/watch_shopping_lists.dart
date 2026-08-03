import '../../../../core/error/result.dart';
import '../entities/shopping_list.dart';
import '../repositories/shopping_list_repository.dart';

class WatchShoppingLists {
  final ShoppingListRepository repository;

  WatchShoppingLists(this.repository);

  Stream<Result<List<ShoppingList>>> call({String? userEmail}) {
    return repository.watchShoppingLists(userEmail);
  }
}
