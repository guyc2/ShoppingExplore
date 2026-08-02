import '../../../../core/error/result.dart';
import '../repositories/shopping_list_repository.dart';

class DeleteShoppingList {
  final ShoppingListRepository repository;

  const DeleteShoppingList(this.repository);

  Future<Result<void>> execute(String listId) async {
    return await repository.deleteShoppingList(listId);
  }
}
