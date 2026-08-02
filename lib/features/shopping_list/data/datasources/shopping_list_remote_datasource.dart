import '../../../../core/error/failure.dart';
import '../models/shopping_list_dto.dart';

abstract class ShoppingListRemoteDataSource {
  Future<List<ShoppingListDto>> getShoppingLists(String userEmail);
  Future<ShoppingListDto> getShoppingList(String id);
  Future<ShoppingListDto> saveShoppingList(ShoppingListDto dto);
  Future<ShoppingListDto> shareShoppingList(String listId, String email);
  Future<void> deleteShoppingList(String id);
}

class InMemoryShoppingListRemoteDataSource implements ShoppingListRemoteDataSource {
  final Map<String, ShoppingListDto> _cloudStorage = {};

  InMemoryShoppingListRemoteDataSource() {
    final now = DateTime.now();
    _cloudStorage['list-1'] = ShoppingListDto(
      id: 'list-1',
      title: 'Weekly Groceries (Cloud)',
      description: 'Shared weekly groceries list',
      ownerId: 'user@shoppingexplore.com',
      sharedWithEmails: const ['friend@shoppingexplore.com'],
      items: const [],
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<List<ShoppingListDto>> getShoppingLists(String userEmail) async {
    final cleanEmail = userEmail.trim().toLowerCase();
    return _cloudStorage.values.where((list) {
      final owner = list.ownerId?.toLowerCase() ?? '';
      final shared = list.sharedWithEmails.map((e) => e.toLowerCase()).toList();
      return owner == cleanEmail || shared.contains(cleanEmail);
    }).toList();
  }

  @override
  Future<ShoppingListDto> getShoppingList(String id) async {
    final list = _cloudStorage[id];
    if (list == null) {
      throw CacheFailure('Cloud shopping list not found: $id');
    }
    return list;
  }

  @override
  Future<ShoppingListDto> saveShoppingList(ShoppingListDto dto) async {
    _cloudStorage[dto.id] = dto;
    return dto;
  }

  @override
  Future<ShoppingListDto> shareShoppingList(String listId, String email) async {
    final list = _cloudStorage[listId];
    if (list == null) {
      throw CacheFailure('Cannot share non-existent list: $listId');
    }
    final cleanEmail = email.trim().toLowerCase();
    if (list.sharedWithEmails.contains(cleanEmail)) {
      return list;
    }
    final updatedEmails = List<String>.from(list.sharedWithEmails)..add(cleanEmail);
    final updatedDto = ShoppingListDto(
      id: list.id,
      title: list.title,
      description: list.description,
      ownerId: list.ownerId,
      sharedWithEmails: updatedEmails,
      items: list.items,
      createdAt: list.createdAt,
      updatedAt: DateTime.now(),
    );
    _cloudStorage[listId] = updatedDto;
    return updatedDto;
  }

  @override
  Future<void> deleteShoppingList(String id) async {
    _cloudStorage.remove(id);
  }
}
