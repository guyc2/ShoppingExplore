import 'dart:async';
import '../../../../core/error/failure.dart';
import '../models/shopping_item_dto.dart';
import '../models/shopping_list_dto.dart';
import '../models/shopping_session_dto.dart';
import 'package:shopping_explore/features/shopping_list/domain/entities/shopping_item.dart';

abstract class ShoppingListRemoteDataSource {
  Future<List<ShoppingListDto>> getShoppingLists(String userEmail);
  Future<ShoppingListDto> getShoppingList(String id);
  Future<ShoppingListDto> saveShoppingList(ShoppingListDto dto);
  Future<ShoppingListDto> shareShoppingList(String listId, String email, {String? displayName});
  Future<ShoppingListDto> removeCollaborator(String listId, String email);
  Future<void> deleteShoppingList(String id);
  Future<void> saveShoppingItem(String listId, ShoppingItemDto item);
  Future<void> deleteShoppingItem(String listId, String itemId);
  Future<ShoppingListDto> startShoppingSession(String listId, String userEmail, {String? locationName});
  Future<ShoppingListDto> endShoppingSession(String listId, String userEmail);
  Stream<List<ShoppingListDto>> watchShoppingLists(String userEmail);
  Stream<ShoppingListDto?> watchShoppingList(String id);
}

class InMemoryShoppingListRemoteDataSource implements ShoppingListRemoteDataSource {
  final Map<String, ShoppingListDto> _cloudStorage = {};
  final StreamController<void> _changesController = StreamController<void>.broadcast();

  InMemoryShoppingListRemoteDataSource.withDefaultData() {
    final now = DateTime.now();

    final defaultList = ShoppingListDto(
      id: 'default-list',
      title: 'Weekly Groceries',
      shortDescription: 'Fresh produce, dairy & essentials',
      description: 'Smart list with checklist and complex item properties for household weekly shopping.',
      colorHex: '#4CAF50',
      imageUrl: 'grocery',
      ownerId: 'test@shoppingexplore.com',
      sharedWithEmails: const ['user@shoppingexplore.com', 'friend@shoppingexplore.com'],
      collaboratorDisplayNames: const {
        'test@shoppingexplore.com': 'Guy C',
        'guy@shoppingexplore.com': 'Guy C',
        'user@shoppingexplore.com': 'Alex User',
        'friend@shoppingexplore.com': 'Taylor Friend',
        'colleague@shoppingexplore.com': 'Sam Colleague',
      },
      createdAt: now,
      updatedAt: now,
      items: [
        ShoppingItemDto(
          id: 'item-1',
          title: 'Organic Honeycrisp Apples',
          quantity: 4.0,
          priority: Priority.high,
          notes: 'Check for local orchard display',
          assignedToEmail: 'test@shoppingexplore.com',
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
      ownerId: 'test@shoppingexplore.com',
      sharedWithEmails: const ['user@shoppingexplore.com', 'colleague@shoppingexplore.com'],
      collaboratorDisplayNames: const {
        'test@shoppingexplore.com': 'Guy C',
        'guy@shoppingexplore.com': 'Guy C',
        'user@shoppingexplore.com': 'Alex User',
        'friend@shoppingexplore.com': 'Taylor Friend',
        'colleague@shoppingexplore.com': 'Sam Colleague',
      },
      createdAt: now,
      updatedAt: now,
      items: [
        ShoppingItemDto(
          id: 'tech-1',
          title: '4K USB-C Curved Monitor',
          quantity: 1.0,
          priority: Priority.high,
          notes: 'Check HDMI 2.1 compatibility',
          assignedToEmail: 'test@shoppingexplore.com',
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
      ownerId: 'test@shoppingexplore.com',
      sharedWithEmails: const ['user@shoppingexplore.com', 'friend@shoppingexplore.com'],
      collaboratorDisplayNames: const {
        'test@shoppingexplore.com': 'Guy C',
        'guy@shoppingexplore.com': 'Guy C',
        'user@shoppingexplore.com': 'Alex User',
        'friend@shoppingexplore.com': 'Taylor Friend',
        'colleague@shoppingexplore.com': 'Sam Colleague',
      },
      createdAt: now,
      updatedAt: now,
      items: [
        ShoppingItemDto(
          id: 'bbq-1',
          title: 'Prime Ribeye Steaks',
          quantity: 6.0,
          priority: Priority.high,
          assignedToEmail: 'test@shoppingexplore.com',
          isCompleted: false,
          createdAt: now,
          updatedAt: now,
        ),
        ShoppingItemDto(
          id: 'bbq-2',
          title: 'Craft IPA Beer 6-pack',
          quantity: 2.0,
          priority: Priority.low,
          isCompleted: false,
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );

    _cloudStorage[defaultList.id] = defaultList;
    _cloudStorage[techList.id] = techList;
    _cloudStorage[bbqList.id] = bbqList;
  }

  @override
  Stream<List<ShoppingListDto>> watchShoppingLists(String userEmail) async* {
    yield await getShoppingLists(userEmail);
    yield* _changesController.stream.asyncMap((_) => getShoppingLists(userEmail));
  }

  @override
  Stream<ShoppingListDto?> watchShoppingList(String id) async* {
    yield _cloudStorage[id];
    yield* _changesController.stream.map((_) => _cloudStorage[id]);
  }

  void notifyChanges() {
    if (!_changesController.isClosed) {
      _changesController.add(null);
    }
  }

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
    if (cleanEmail.isEmpty) {
      return _cloudStorage.values.toList();
    }
    return _cloudStorage.values.where((list) {
      final owner = list.ownerId?.toLowerCase() ?? '';
      final shared = list.sharedWithEmails.map((e) => e.toLowerCase()).toList();
      return owner.isEmpty || owner == cleanEmail || shared.contains(cleanEmail);
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
    notifyChanges();
    return dto;
  }

  @override
  Future<ShoppingListDto> shareShoppingList(String listId, String email, {String? displayName}) async {
    final list = _cloudStorage[listId];
    if (list == null) {
      throw CacheFailure('Cannot share non-existent list: $listId');
    }
    final cleanEmail = email.trim().toLowerCase();
    final updatedEmails = List<String>.from(list.sharedWithEmails);
    if (!updatedEmails.contains(cleanEmail)) {
      updatedEmails.add(cleanEmail);
    }
    final updatedDisplayNames = Map<String, String>.from(list.collaboratorDisplayNames);
    if (displayName != null && displayName.trim().isNotEmpty) {
      updatedDisplayNames[cleanEmail] = displayName.trim();
    }
    final updatedDto = ShoppingListDto(
      id: list.id,
      title: list.title,
      description: list.description,
      shortDescription: list.shortDescription,
      colorHex: list.colorHex,
      imageUrl: list.imageUrl,
      ownerId: list.ownerId,
      sharedWithEmails: updatedEmails,
      collaboratorDisplayNames: updatedDisplayNames,
      items: list.items,
      activeSessions: list.activeSessions,
      createdAt: list.createdAt,
      updatedAt: DateTime.now(),
    );
    _cloudStorage[listId] = updatedDto;
    notifyChanges();
    return updatedDto;
  }

  @override
  Future<ShoppingListDto> removeCollaborator(String listId, String email) async {
    final list = _cloudStorage[listId];
    if (list == null) {
      throw CacheFailure('Cannot remove collaborator from non-existent list: $listId');
    }
    final cleanEmail = email.trim().toLowerCase();
    final updatedEmails = List<String>.from(list.sharedWithEmails)
      ..removeWhere((e) => e.trim().toLowerCase() == cleanEmail);
    final updatedDisplayNames = Map<String, String>.from(list.collaboratorDisplayNames)
      ..remove(cleanEmail)
      ..remove(email.trim());

    final updatedDto = ShoppingListDto(
      id: list.id,
      title: list.title,
      description: list.description,
      shortDescription: list.shortDescription,
      colorHex: list.colorHex,
      imageUrl: list.imageUrl,
      ownerId: list.ownerId,
      sharedWithEmails: updatedEmails,
      collaboratorDisplayNames: updatedDisplayNames,
      items: list.items,
      activeSessions: list.activeSessions,
      createdAt: list.createdAt,
      updatedAt: DateTime.now(),
    );
    _cloudStorage[listId] = updatedDto;
    notifyChanges();
    return updatedDto;
  }

  @override
  Future<void> deleteShoppingList(String id) async {
    _cloudStorage.remove(id);
    notifyChanges();
  }

  @override
  Future<void> saveShoppingItem(String listId, ShoppingItemDto item) async {
    final list = _cloudStorage[listId];
    if (list == null) throw const CacheFailure('List not found');
    final items = List<ShoppingItemDto>.from(list.items);
    final idx = items.indexWhere((i) => i.id == item.id);
    if (idx >= 0) {
      items[idx] = item;
    } else {
      items.add(item);
    }
    _cloudStorage[listId] = ShoppingListDto.fromDomain(list.copyWith(items: items));
    notifyChanges();
  }

  @override
  Future<void> deleteShoppingItem(String listId, String itemId) async {
    final list = _cloudStorage[listId];
    if (list == null) throw const CacheFailure('List not found');
    final items = list.items.where((i) => i.id != itemId).toList();
    _cloudStorage[listId] = ShoppingListDto.fromDomain(list.copyWith(items: items));
    notifyChanges();
  }

  @override
  Future<ShoppingListDto> startShoppingSession(String listId, String userEmail, {String? locationName}) async {
    final list = _cloudStorage[listId];
    if (list == null) throw const CacheFailure('List not found');
    
    final sessions = List<ShoppingSessionDto>.from(list.activeSessions.map((s) => ShoppingSessionDto.fromDomain(s)));
    sessions.removeWhere((s) => s.userEmail == userEmail);
    sessions.add(ShoppingSessionDto(
      userEmail: userEmail,
      locationName: locationName,
      startedAt: DateTime.now().toIso8601String(),
    ));
    
    final updatedList = ShoppingListDto.fromDomain(list.toDomain().copyWith(
      activeSessions: sessions.map((s) => s.toDomain()).toList(),
    ));
    
    _cloudStorage[listId] = updatedList;
    notifyChanges();
    return updatedList;
  }

  @override
  Future<ShoppingListDto> endShoppingSession(String listId, String userEmail) async {
    final list = _cloudStorage[listId];
    if (list == null) throw const CacheFailure('List not found');
    
    final sessions = List<ShoppingSessionDto>.from(list.activeSessions.map((s) => ShoppingSessionDto.fromDomain(s)));
    sessions.removeWhere((s) => s.userEmail == userEmail);
    
    final updatedList = ShoppingListDto.fromDomain(list.toDomain().copyWith(
      activeSessions: sessions.map((s) => s.toDomain()).toList(),
    ));
    
    _cloudStorage[listId] = updatedList;
    notifyChanges();
    return updatedList;
  }
}
