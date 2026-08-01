import '../../../../core/error/result.dart';
import '../entities/shopping_item.dart';
import '../repositories/shopping_list_repository.dart';

class CreateShoppingItem {
  final ShoppingListRepository repository;

  const CreateShoppingItem(this.repository);

  Future<Result<ShoppingItem>> execute({
    required String listId,
    required ShoppingItem item,
  }) {
    return repository.saveShoppingItem(listId, item);
  }
}
