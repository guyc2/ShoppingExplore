import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/shopping_list/domain/entities/shopping_item.dart';

void main() {
  group('ShoppingItem Entity', () {
    final now = DateTime(2026, 1, 1);
    final item = ShoppingItem(
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

    test('supports value comparisons via Equatable', () {
      final itemCopy = ShoppingItem(
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

      expect(item, equals(itemCopy));
    });

    test('copyWith returns a new object with updated fields', () {
      final updatedItem = item.copyWith(
        title: 'Green Apples',
        isCompleted: true,
        priority: Priority.low,
      );

      expect(updatedItem.title, equals('Green Apples'));
      expect(updatedItem.isCompleted, isTrue);
      expect(updatedItem.priority, equals(Priority.low));
      expect(updatedItem.id, equals(item.id));
      expect(updatedItem.quantity, equals(item.quantity));
      expect(updatedItem.attributes, equals(item.attributes));
    });

    test('default values are applied correctly', () {
      final defaultItem = ShoppingItem(
        id: '2',
        title: 'Milk',
        createdAt: now,
        updatedAt: now,
      );

      expect(defaultItem.isCompleted, isFalse);
      expect(defaultItem.quantity, equals(1.0));
      expect(defaultItem.unit, isNull);
      expect(defaultItem.priority, equals(Priority.medium));
      expect(defaultItem.notes, isNull);
      expect(defaultItem.imageUrls, isEmpty);
      expect(defaultItem.linkUrls, isEmpty);
      expect(defaultItem.attributes, isEmpty);
    });
  });
}
