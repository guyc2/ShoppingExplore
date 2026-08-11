import '../../../../core/error/result.dart';
import '../entities/shopping_list.dart';
import '../repositories/shopping_list_repository.dart';

class ShareShoppingList {
  final ShoppingListRepository repository;

  const ShareShoppingList(this.repository);

  Future<Result<ShoppingList>> execute(String listId, String email, {String? displayName}) {
    return repository.shareShoppingList(listId, email, displayName: displayName);
  }
}
