import '../../../../core/error/result.dart';
import '../entities/shopping_list.dart';
import '../repositories/shopping_list_repository.dart';

class StartShoppingSession {
  final ShoppingListRepository repository;

  StartShoppingSession(this.repository);

  Future<Result<ShoppingList>> call(
    String listId,
    String userEmail, {
    String? locationName,
  }) {
    return repository.startShoppingSession(
      listId,
      userEmail,
      locationName: locationName,
    );
  }
}
