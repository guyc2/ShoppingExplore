import '../../../../core/error/result.dart';
import '../entities/shopping_item.dart';
import '../repositories/shopping_list_repository.dart';

class UpdateItemProperties {
  final ShoppingListRepository repository;

  const UpdateItemProperties(this.repository);

  Future<Result<ShoppingItem>> execute({
    required String listId,
    required ShoppingItem updatedItem,
  }) {
    final itemWithNewTimestamp = updatedItem.copyWith(updatedAt: DateTime.now());
    return repository.saveShoppingItem(listId, itemWithNewTimestamp);
  }
}
