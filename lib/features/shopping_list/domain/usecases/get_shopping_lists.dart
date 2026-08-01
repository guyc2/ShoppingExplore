import '../../../../core/error/result.dart';
import '../entities/shopping_list.dart';
import '../repositories/shopping_list_repository.dart';

class GetShoppingLists {
  final ShoppingListRepository repository;

  const GetShoppingLists(this.repository);

  Future<Result<List<ShoppingList>>> execute() {
    return repository.getShoppingLists();
  }
}
