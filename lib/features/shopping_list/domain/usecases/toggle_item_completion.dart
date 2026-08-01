import '../../../../core/error/result.dart';
import '../entities/shopping_item.dart';
import '../repositories/shopping_list_repository.dart';

class ToggleItemCompletion {
  final ShoppingListRepository repository;

  const ToggleItemCompletion(this.repository);

  Future<Result<ShoppingItem>> execute({
    required String listId,
    required ShoppingItem item,
  }) {
    final updatedItem = item.copyWith(
      isCompleted: !item.isCompleted,
      updatedAt: DateTime.now(),
    );
    return repository.saveShoppingItem(listId, updatedItem);
  }
}
