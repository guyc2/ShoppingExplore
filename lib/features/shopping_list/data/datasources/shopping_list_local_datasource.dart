import 'dart:async';
import '../../../../core/error/failure.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/entities/shopping_session.dart';
import '../models/shopping_item_dto.dart';
import '../models/shopping_list_dto.dart';

abstract class ShoppingListLocalDataSource {
  Future<List<ShoppingListDto>> getShoppingLists();
  Future<ShoppingListDto> getShoppingList(String id);
  Future<void> saveShoppingList(ShoppingListDto list);
  Future<ShoppingListDto> shareShoppingList(String listId, String email);
  Future<void> deleteShoppingList(String id);
  Future<void> saveShoppingItem(String listId, ShoppingItemDto item);
  Future<void> deleteShoppingItem(String listId, String itemId);
  Future<ShoppingListDto> startShoppingSession(String listId, String userEmail, {String? locationName});
  Future<ShoppingListDto> endShoppingSession(String listId, String userEmail);
  Stream<void> get changesStream;
}

class InMemoryShoppingListLocalDataSource implements ShoppingListLocalDataSource {
  final Map<String, ShoppingListDto> _cache = {};
  final StreamController<void> _changesController = StreamController<void>.broadcast();

  @override
  Stream<void> get changesStream => _changesController.stream;

  void notifyChanges() {
    if (!_changesController.isClosed) {
      _changesController.add(null);
    }
  }

  InMemoryShoppingListLocalDataSource();

  factory InMemoryShoppingListLocalDataSource.withDefaultData() {
    final ds = InMemoryShoppingListLocalDataSource();
    final now = DateTime.now();

    final defaultList = ShoppingListDto(
      id: 'default-list',
      title: 'Weekly Groceries',
      shortDescription: 'Fresh produce, dairy & essentials',
      description: 'Smart list with checklist and complex item properties for household weekly shopping.',
      colorHex: '#4CAF50',
      imageUrl: 'grocery',
      ownerId: 'guy@shoppingexplore.com',
      sharedWithEmails: const ['user@shoppingexplore.com', 'friend@shoppingexplore.com'],
      createdAt: now,
      updatedAt: now,
      items: [
        ShoppingItemDto(
          id: 'item-1',
          title: 'Organic Honeycrisp Apples',
          quantity: 4.0,
          priority: Priority.high,
          notes: 'Check for local orchard display',
          assignedToEmail: 'guy@shoppingexplore.com',
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
          priority: Priority.medium,
          assignedToEmail: 'friend@shoppingexplore.com',
          isCompleted: true,
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );

    final techList = ShoppingListDto(
      id: 'tech-list',
      title: 'Tech & Electronics Wishlist',
      shortDescription: 'Gadgets, cables & workstation gear',
      description: 'Items to research, compare prices, and buy for the office renovation and smart home setup.',
      colorHex: '#2196F3',
      imageUrl: 'tech',
      ownerId: 'guy@shoppingexplore.com',
      sharedWithEmails: const ['user@shoppingexplore.com', 'colleague@shoppingexplore.com'],
      createdAt: now,
      updatedAt: now,
      items: [
        ShoppingItemDto(
          id: 'tech-1',
          title: '4K USB-C Curved Monitor',
          quantity: 1.0,
          priority: Priority.high,
          notes: 'Check HDMI 2.1 compatibility',
          assignedToEmail: 'guy@shoppingexplore.com',
          isCompleted: false,
          createdAt: now,
          updatedAt: now,
        ),
        ShoppingItemDto(
          id: 'tech-2',
          title: 'Ergonomic Mechanical Keyboard',
          quantity: 1.0,
          priority: Priority.medium,
          notes: 'Brown switches preferred',
          assignedToEmail: 'colleague@shoppingexplore.com',
          isCompleted: true,
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );

    final bbqList = ShoppingListDto(
      id: 'bbq-list',
      title: 'Weekend BBQ Party',
      shortDescription: 'Meats, drinks & grill supplies',
      description: 'Everything needed for Sunday afternoon barbecue party with friends and family.',
      colorHex: '#FF9800',
      imageUrl: 'party',
      ownerId: 'guy@shoppingexplore.com',
      sharedWithEmails: const ['user@shoppingexplore.com', 'friend@shoppingexplore.com'],
      createdAt: now,
      updatedAt: now,
      items: [
        ShoppingItemDto(
          id: 'bbq-1',
          title: 'Prime Ribeye Steaks',
          quantity: 6.0,
          priority: Priority.high,
          assignedToEmail: 'guy@shoppingexplore.com',
          isCompleted: false,
          createdAt: now,
          updatedAt: now,
        ),
        ShoppingItemDto(
          id: 'bbq-2',
          title: 'Craft IPA Beer 6-pack',
          quantity: 4.0,
          priority: Priority.medium,
          assignedToEmail: 'friend@shoppingexplore.com',
          isCompleted: false,
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );

    ds._cache[defaultList.id] = defaultList;
    ds._cache[techList.id] = techList;
    ds._cache[bbqList.id] = bbqList;
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
    notifyChanges();
  }

  @override
  Future<ShoppingListDto> shareShoppingList(String listId, String email) async {
    final list = _cache[listId];
    if (list == null) {
      throw const CacheFailure('Shopping list not found');
    }
    final cleanEmail = email.trim().toLowerCase();
    if (list.sharedWithEmails.contains(cleanEmail)) {
      return list;
    }
    final updatedEmails = List<String>.from(list.sharedWithEmails)..add(cleanEmail);
    final updatedDto = ShoppingListDto(
      id: list.id,
      title: list.title,
      shortDescription: list.shortDescription,
      description: list.description,
      colorHex: list.colorHex,
      imageUrl: list.imageUrl,
      ownerId: list.ownerId,
      sharedWithEmails: updatedEmails,
      items: list.items,
      activeSessions: list.activeSessions,
      createdAt: list.createdAt,
      updatedAt: DateTime.now(),
    );
    _cache[listId] = updatedDto;
    notifyChanges();
    return updatedDto;
  }

  @override
  Future<void> deleteShoppingList(String id) async {
    if (!_cache.containsKey(id)) {
      throw const CacheFailure('Shopping list not found');
    }
    _cache.remove(id);
    notifyChanges();
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
      shortDescription: list.shortDescription,
      description: list.description,
      colorHex: list.colorHex,
      imageUrl: list.imageUrl,
      ownerId: list.ownerId,
      sharedWithEmails: list.sharedWithEmails,
      items: updatedItems,
      activeSessions: list.activeSessions,
      createdAt: list.createdAt,
      updatedAt: DateTime.now(),
    );
    notifyChanges();
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
      shortDescription: list.shortDescription,
      description: list.description,
      colorHex: list.colorHex,
      imageUrl: list.imageUrl,
      ownerId: list.ownerId,
      sharedWithEmails: list.sharedWithEmails,
      items: updatedItems,
      activeSessions: list.activeSessions,
      createdAt: list.createdAt,
      updatedAt: DateTime.now(),
    );
    notifyChanges();
  }

  @override
  Future<ShoppingListDto> startShoppingSession(String listId, String userEmail, {String? locationName}) async {
    final list = _cache[listId];
    if (list == null) {
      throw const CacheFailure('Shopping list not found');
    }
    final remainingSessions = list.activeSessions
        .where((s) => s.userEmail.toLowerCase() != userEmail.toLowerCase())
        .toList();
    final newSession = ShoppingSession(
      userEmail: userEmail,
      locationName: locationName,
      startedAt: DateTime.now(),
    );
    final updatedList = ShoppingListDto(
      id: list.id,
      title: list.title,
      shortDescription: list.shortDescription,
      description: list.description,
      colorHex: list.colorHex,
      imageUrl: list.imageUrl,
      ownerId: list.ownerId,
      sharedWithEmails: list.sharedWithEmails,
      items: list.items,
      activeSessions: [...remainingSessions, newSession],
      createdAt: list.createdAt,
      updatedAt: DateTime.now(),
    );
    _cache[listId] = updatedList;
    notifyChanges();
    return updatedList;
  }

  @override
  Future<ShoppingListDto> endShoppingSession(String listId, String userEmail) async {
    final list = _cache[listId];
    if (list == null) {
      throw const CacheFailure('Shopping list not found');
    }
    final remainingSessions = list.activeSessions
        .where((s) => s.userEmail.toLowerCase() != userEmail.toLowerCase())
        .toList();
    final updatedList = ShoppingListDto(
      id: list.id,
      title: list.title,
      shortDescription: list.shortDescription,
      description: list.description,
      colorHex: list.colorHex,
      imageUrl: list.imageUrl,
      ownerId: list.ownerId,
      sharedWithEmails: list.sharedWithEmails,
      items: list.items,
      activeSessions: remainingSessions,
      createdAt: list.createdAt,
      updatedAt: DateTime.now(),
    );
    _cache[listId] = updatedList;
    notifyChanges();
    return updatedList;
  }
}
