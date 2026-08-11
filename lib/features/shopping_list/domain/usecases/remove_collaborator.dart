import '../../../../core/error/result.dart';
import '../entities/shopping_list.dart';
import '../repositories/shopping_list_repository.dart';

class RemoveCollaborator {
  final ShoppingListRepository repository;

  const RemoveCollaborator(this.repository);

  Future<Result<ShoppingList>> execute(String listId, String email) {
    return repository.removeCollaborator(listId, email);
  }
}
