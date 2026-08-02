import 'package:flutter/foundation.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/entities/shopping_list.dart';
import '../../domain/usecases/create_shopping_item.dart';
import '../../domain/usecases/create_shopping_list.dart';
import '../../domain/usecases/delete_shopping_item.dart';
import '../../domain/usecases/delete_shopping_list.dart';
import '../../domain/usecases/get_shopping_lists.dart';
import '../../domain/usecases/share_shopping_list.dart';
import '../../domain/usecases/toggle_item_completion.dart';
import '../../domain/usecases/update_item_properties.dart';
import '../../domain/usecases/update_shopping_list.dart';
import 'shopping_list_state.dart';

class ShoppingListController extends ValueNotifier<ShoppingListState> {
  final GetShoppingLists getShoppingLists;
  final CreateShoppingItem createShoppingItem;
  final ToggleItemCompletion toggleItemCompletion;
  final UpdateItemProperties updateItemProperties;
  final DeleteShoppingItem deleteShoppingItem;
  final ShareShoppingList? shareShoppingList;
  final CreateShoppingList? createShoppingList;
  final UpdateShoppingList? updateShoppingList;
  final DeleteShoppingList? deleteShoppingList;

  ShoppingListController({
    required this.getShoppingLists,
    required this.createShoppingItem,
    required this.toggleItemCompletion,
    required this.updateItemProperties,
    required this.deleteShoppingItem,
    this.shareShoppingList,
    this.createShoppingList,
    this.updateShoppingList,
    this.deleteShoppingList,
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

  Future<bool> shareList(String listId, String email) async {
    AppLogger.d('Sharing list $listId with $email', tag: 'ShoppingListController');
    if (shareShoppingList == null) {
      AppLogger.w('ShareShoppingList usecase not configured', tag: 'ShoppingListController');
      return false;
    }
    final result = await shareShoppingList!.execute(listId, email);
    if (result.isSuccess) {
      AppLogger.i('List shared successfully with $email', tag: 'ShoppingListController');
      await loadShoppingLists();
      return true;
    } else {
      AppLogger.w('Failed to share list: ${result.error.message}', tag: 'ShoppingListController');
      value = ShoppingListError(result.error);
      return false;
    }
  }

  Future<bool> createList({
    required String title,
    String? shortDescription,
    String? description,
    String? colorHex,
    String? imageUrl,
    String? ownerId,
    List<String> sharedWithEmails = const [],
  }) async {
    AppLogger.d('Creating new shopping list: $title', tag: 'ShoppingListController');
    if (createShoppingList == null) {
      AppLogger.w('CreateShoppingList usecase not configured', tag: 'ShoppingListController');
      return false;
    }
    final result = await createShoppingList!.execute(
      title: title,
      shortDescription: shortDescription,
      description: description,
      colorHex: colorHex,
      imageUrl: imageUrl,
      ownerId: ownerId,
      sharedWithEmails: sharedWithEmails,
    );
    if (result.isSuccess) {
      AppLogger.i('Shopping list created successfully: ${result.value.id}', tag: 'ShoppingListController');
      await loadShoppingLists();
      return true;
    } else {
      AppLogger.w('Failed to create shopping list: ${result.error.message}', tag: 'ShoppingListController');
      value = ShoppingListError(result.error);
      return false;
    }
  }

  Future<bool> updateList(ShoppingList list) async {
    AppLogger.d('Updating shopping list: ${list.title}', tag: 'ShoppingListController');
    if (updateShoppingList == null) {
      AppLogger.w('UpdateShoppingList usecase not configured', tag: 'ShoppingListController');
      return false;
    }
    final result = await updateShoppingList!.execute(list);
    if (result.isSuccess) {
      AppLogger.i('Shopping list updated successfully', tag: 'ShoppingListController');
      await loadShoppingLists();
      return true;
    } else {
      AppLogger.w('Failed to update shopping list: ${result.error.message}', tag: 'ShoppingListController');
      value = ShoppingListError(result.error);
      return false;
    }
  }

  Future<bool> deleteList(String listId) async {
    AppLogger.d('Deleting shopping list $listId', tag: 'ShoppingListController');
    if (deleteShoppingList == null) {
      AppLogger.w('DeleteShoppingList usecase not configured', tag: 'ShoppingListController');
      return false;
    }
    final result = await deleteShoppingList!.execute(listId);
    if (result.isSuccess) {
      AppLogger.i('Shopping list deleted successfully', tag: 'ShoppingListController');
      await loadShoppingLists();
      return true;
    } else {
      AppLogger.w('Failed to delete shopping list: ${result.error.message}', tag: 'ShoppingListController');
      value = ShoppingListError(result.error);
      return false;
    }
  }

  // Active Shopping Mode state
  final Map<String, bool> _shoppingModes = {};
  final Map<String, Set<String>> _removedCartItemIds = {};

  bool isShoppingMode(String listId) => _shoppingModes[listId] ?? false;
  Set<String> removedCartItemIds(String listId) => _removedCartItemIds[listId] ?? {};

  void enterShoppingMode(String listId) {
    AppLogger.i('Entering shopping mode for list $listId', tag: 'ShoppingListController');
    _shoppingModes[listId] = true;
    _removedCartItemIds[listId] = {};
    notifyListeners();
  }

  void removeItemInShoppingMode(String listId, String itemId) {
    AppLogger.d('Marking item $itemId as removed in shopping mode for list $listId', tag: 'ShoppingListController');
    _removedCartItemIds.putIfAbsent(listId, () => {});
    _removedCartItemIds[listId]!.add(itemId);
    notifyListeners();
  }

  void restoreItemFromCart(String listId, String itemId) {
    AppLogger.d('Restoring item $itemId from cart in shopping mode for list $listId', tag: 'ShoppingListController');
    if (_removedCartItemIds.containsKey(listId)) {
      _removedCartItemIds[listId]!.remove(itemId);
      notifyListeners();
    }
  }

  Future<void> completeShoppingMode(String listId) async {
    AppLogger.i('Completing shopping mode for list $listId', tag: 'ShoppingListController');
    final removedIds = _removedCartItemIds[listId] ?? {};
    for (final itemId in removedIds) {
      AppLogger.d('Permanently deleting item $itemId on shopping mode complete', tag: 'ShoppingListController');
      await deleteShoppingItem.execute(listId: listId, itemId: itemId);
    }
    _removedCartItemIds.remove(listId);
    _shoppingModes[listId] = false;
    await loadShoppingLists();
  }

  void cancelShoppingMode(String listId) {
    AppLogger.i('Canceling shopping mode for list $listId and restoring all removed items', tag: 'ShoppingListController');
    _removedCartItemIds.remove(listId);
    _shoppingModes[listId] = false;
    notifyListeners();
  }
}

