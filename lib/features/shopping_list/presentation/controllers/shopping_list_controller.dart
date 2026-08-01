import 'package:flutter/foundation.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/usecases/create_shopping_item.dart';
import '../../domain/usecases/delete_shopping_item.dart';
import '../../domain/usecases/get_shopping_lists.dart';
import '../../domain/usecases/toggle_item_completion.dart';
import '../../domain/usecases/update_item_properties.dart';
import 'shopping_list_state.dart';

class ShoppingListController extends ValueNotifier<ShoppingListState> {
  final GetShoppingLists getShoppingLists;
  final CreateShoppingItem createShoppingItem;
  final ToggleItemCompletion toggleItemCompletion;
  final UpdateItemProperties updateItemProperties;
  final DeleteShoppingItem deleteShoppingItem;

  ShoppingListController({
    required this.getShoppingLists,
    required this.createShoppingItem,
    required this.toggleItemCompletion,
    required this.updateItemProperties,
    required this.deleteShoppingItem,
  }) : super(const ShoppingListInitial());

  Future<void> loadShoppingLists() async {
    AppLogger.i('Loading shopping lists...', tag: 'ShoppingListController');
    value = const ShoppingListLoading();
    final result = await getShoppingLists.execute();
    if (result.isSuccess) {
      AppLogger.i('Successfully loaded ${result.value.length} shopping lists', tag: 'ShoppingListController');
      value = ShoppingListLoaded(result.value);
    } else {
      AppLogger.e('Failed to load shopping lists: ${result.error.message}', tag: 'ShoppingListController');
      value = ShoppingListError(result.error);
    }
  }

  Future<void> addItem(String listId, ShoppingItem item) async {
    AppLogger.d('Adding item to list $listId: ${item.title}', tag: 'ShoppingListController');
    final result = await createShoppingItem.execute(listId: listId, item: item);
    if (result.isSuccess) {
      AppLogger.i('Item added successfully', tag: 'ShoppingListController');
      await loadShoppingLists();
    } else {
      AppLogger.w('Failed to add item: ${result.error.message}', tag: 'ShoppingListController');
      value = ShoppingListError(result.error);
    }
  }

  Future<void> toggleItem(String listId, ShoppingItem item) async {
    AppLogger.d('Toggling completion for item: ${item.title}', tag: 'ShoppingListController');
    final result = await toggleItemCompletion.execute(listId: listId, item: item);
    if (result.isSuccess) {
      AppLogger.i('Item toggled successfully', tag: 'ShoppingListController');
      await loadShoppingLists();
    } else {
      AppLogger.w('Failed to toggle item: ${result.error.message}', tag: 'ShoppingListController');
      value = ShoppingListError(result.error);
    }
  }

  Future<void> updateItem(String listId, ShoppingItem item) async {
    AppLogger.d('Updating rich properties for item: ${item.title}', tag: 'ShoppingListController');
    final result = await updateItemProperties.execute(listId: listId, updatedItem: item);
    if (result.isSuccess) {
      AppLogger.i('Item updated successfully', tag: 'ShoppingListController');
      await loadShoppingLists();
    } else {
      AppLogger.w('Failed to update item: ${result.error.message}', tag: 'ShoppingListController');
      value = ShoppingListError(result.error);
    }
  }

  Future<void> deleteItem(String listId, String itemId) async {
    AppLogger.d('Deleting item $itemId from list $listId', tag: 'ShoppingListController');
    final result = await deleteShoppingItem.execute(listId: listId, itemId: itemId);
    if (result.isSuccess) {
      AppLogger.i('Item deleted successfully', tag: 'ShoppingListController');
      await loadShoppingLists();
    } else {
      AppLogger.w('Failed to delete item: ${result.error.message}', tag: 'ShoppingListController');
      value = ShoppingListError(result.error);
    }
  }
}
