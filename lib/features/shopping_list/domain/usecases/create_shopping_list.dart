import '../../../../core/error/result.dart';
import '../entities/shopping_list.dart';
import '../repositories/shopping_list_repository.dart';

class CreateShoppingList {
  final ShoppingListRepository repository;

  const CreateShoppingList(this.repository);

  Future<Result<ShoppingList>> execute({
    required String title,
    String? shortDescription,
    String? description,
    String? colorHex,
    String? imageUrl,
    String? ownerId,
    List<String> sharedWithEmails = const [],
  }) async {
    final now = DateTime.now();
    final list = ShoppingList(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      shortDescription: shortDescription,
      description: description,
      colorHex: colorHex ?? '#4CAF50',
      imageUrl: imageUrl ?? 'grocery',
      ownerId: ownerId,
      sharedWithEmails: sharedWithEmails,
      items: const [],
      createdAt: now,
      updatedAt: now,
    );
    return await repository.saveShoppingList(list);
  }
}
