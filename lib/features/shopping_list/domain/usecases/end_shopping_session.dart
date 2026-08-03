import '../../../../core/error/result.dart';
import '../entities/shopping_list.dart';
import '../repositories/shopping_list_repository.dart';

class EndShoppingSession {
  final ShoppingListRepository repository;

  EndShoppingSession(this.repository);

  Future<Result<ShoppingList>> call(String listId, String userEmail) {
    return repository.endShoppingSession(listId, userEmail);
  }
}
