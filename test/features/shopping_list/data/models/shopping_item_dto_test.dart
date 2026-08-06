import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/shopping_list/data/models/shopping_item_dto.dart';
import 'package:shopping_explore/features/shopping_list/domain/entities/shopping_item.dart';

void main() {
  group('ShoppingItemDto', () {
    final now = DateTime.parse('2026-01-01T12:00:00.000');
    final dto = ShoppingItemDto(
      id: '1',
      title: 'Apples',
      quantity: 2.5,
      unit: 'kg',
      priority: Priority.high,
      notes: 'Organic only',
      imageUrls: const ['https://example.com/apple.jpg'],
      linkUrls: const ['https://example.com/store/apple'],
      attributes: const {'store': 'WholeFoods', 'brand': 'Nature'},
      createdAt: now,
      updatedAt: now,
    );

    final jsonMap = {
      'id': '1',
      'title': 'Apples',
      'isCompleted': false,
      'quantity': 2.5,
      'unit': 'kg',
      'priority': 'high',
      'notes': 'Organic only',
      'assignedToEmail': null,
      'imageUrls': ['https://example.com/apple.jpg'],
      'linkUrls': ['https://example.com/store/apple'],
      'attributes': {'store': 'WholeFoods', 'brand': 'Nature'},
      'suggestions': [],
      'createdAt': '2026-01-01T12:00:00.000',
      'updatedAt': '2026-01-01T12:00:00.000',
    };

    test('toJson converts ShoppingItemDto to JSON map correctly', () {
      expect(dto.toJson(), equals(jsonMap));
    });

    test('fromJson converts JSON map to valid ShoppingItemDto', () {
      final fromJsonDto = ShoppingItemDto.fromJson(jsonMap);
      expect(fromJsonDto, equals(dto));
    });

    test('fromDomain and toDomain correctly convert between Entity and DTO', () {
      final domainItem = dto.toDomain();
      expect(domainItem, isA<ShoppingItem>());
      expect(domainItem.id, equals(dto.id));
      expect(domainItem.title, equals(dto.title));

      final convertedDto = ShoppingItemDto.fromDomain(domainItem);
      expect(convertedDto, equals(dto));
    });
  });
}
