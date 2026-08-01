import '../../../../core/error/failure.dart';
import '../../domain/entities/shopping_item.dart';
import '../models/shopping_item_dto.dart';
import '../models/shopping_list_dto.dart';

abstract class ShoppingListLocalDataSource {
  Future<List<ShoppingListDto>> getShoppingLists();
  Future<ShoppingListDto> getShoppingList(String id);
  Future<void> saveShoppingList(ShoppingListDto list);
  Future<void> deleteShoppingList(String id);
  Future<void> saveShoppingItem(String listId, ShoppingItemDto item);
  Future<void> deleteShoppingItem(String listId, String itemId);
}

class InMemoryShoppingListLocalDataSource implements ShoppingListLocalDataSource {
  final Map<String, ShoppingListDto> _cache = {};

  InMemoryShoppingListLocalDataSource();

  factory InMemoryShoppingListLocalDataSource.withDefaultData() {
    final ds = InMemoryShoppingListLocalDataSource();
    final now = DateTime.now();
    final defaultList = ShoppingListDto(
      id: 'default-list',
      title: 'Weekly Groceries',
      description: 'Smart list with checklist and complex item properties',
      createdAt: now,
      updatedAt: now,
      items: [
        ShoppingItemDto(
          id: 'item-1',
          title: 'Organic Honeycrisp Apples',
          quantity: 4.0,
          priority: Priority.high, // High priority
          notes: 'Check for local orchard display',
          imageUrls: const ['https://example.com/apple.jpg'],
          linkUrls: const ['https://example.com/apples-info'],
          attributes: const {'organic': 'true', 'origin': 'local'},
          isCompleted: false,
          createdAt: now,
          updatedAt: now,
        ),
        ShoppingItemDto(
          id: 'item-2',
          title: 'Almond Milk (Unsweetened)',
          quantity: 2.0,
          priority: Priority.medium, // Medium priority
          isCompleted: false,
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );
    ds._cache[defaultList.id] = defaultList;
    return ds;
  }

  @override
  Future<List<ShoppingListDto>> getShoppingLists() async {
    return _cache.values.toList();
  }

  @override
  Future<ShoppingListDto> getShoppingList(String id) async {
    final list = _cache[id];
    if (list == null) {
      throw const CacheFailure('Shopping list not found');
    }
    return list;
  }

  @override
  Future<void> saveShoppingList(ShoppingListDto list) async {
    _cache[list.id] = list;
  }

  @override
  Future<void> deleteShoppingList(String id) async {
    if (!_cache.containsKey(id)) {
      throw const CacheFailure('Shopping list not found');
    }
    _cache.remove(id);
  }

  @override
  Future<void> saveShoppingItem(String listId, ShoppingItemDto item) async {
    final list = _cache[listId];
    if (list == null) {
      throw const CacheFailure('Shopping list not found');
    }
    final existingIndex = list.items.indexWhere((i) => i.id == item.id);
    final updatedItems = List<ShoppingItemDto>.from(
      list.items.map((i) => ShoppingItemDto.fromDomain(i)),
    );
    if (existingIndex >= 0) {
      updatedItems[existingIndex] = item;
    } else {
      updatedItems.add(item);
    }
    _cache[listId] = ShoppingListDto(
      id: list.id,
      title: list.title,
      description: list.description,
      colorHex: list.colorHex,
      items: updatedItems,
      createdAt: list.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteShoppingItem(String listId, String itemId) async {
    final list = _cache[listId];
    if (list == null) {
      throw const CacheFailure('Shopping list not found');
    }
    final updatedItems = list.items
        .where((i) => i.id != itemId)
        .map((i) => ShoppingItemDto.fromDomain(i))
        .toList();
    _cache[listId] = ShoppingListDto(
      id: list.id,
      title: list.title,
      description: list.description,
      colorHex: list.colorHex,
      items: updatedItems,
      createdAt: list.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
