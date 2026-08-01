import '../../../../core/error/result.dart';
import '../repositories/shopping_list_repository.dart';

class DeleteShoppingItem {
  final ShoppingListRepository repository;

  const DeleteShoppingItem(this.repository);

  Future<Result<void>> execute({
    required String listId,
    required String itemId,
  }) {
    return repository.deleteShoppingItem(listId, itemId);
  }
}
