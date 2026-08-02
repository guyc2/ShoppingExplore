import '../../../../core/error/result.dart';
import '../entities/shopping_list.dart';
import '../repositories/shopping_list_repository.dart';

class UpdateShoppingList {
  final ShoppingListRepository repository;

  const UpdateShoppingList(this.repository);

  Future<Result<ShoppingList>> execute(ShoppingList list) async {
    final updatedList = list.copyWith(updatedAt: DateTime.now());
    return await repository.saveShoppingList(updatedList);
  }
}
