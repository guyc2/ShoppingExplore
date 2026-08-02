import '../../../../core/error/result.dart';
import '../entities/shopping_item.dart';
import '../entities/shopping_list.dart';

abstract class ShoppingListRepository {
  Future<Result<List<ShoppingList>>> getShoppingLists();
  Future<Result<ShoppingList>> getShoppingList(String id);
  Future<Result<ShoppingList>> saveShoppingList(ShoppingList list);
  Future<Result<ShoppingList>> shareShoppingList(String listId, String email);
  Future<Result<void>> deleteShoppingList(String id);
  Future<Result<ShoppingItem>> saveShoppingItem(String listId, ShoppingItem item);
  Future<Result<void>> deleteShoppingItem(String listId, String itemId);
}
