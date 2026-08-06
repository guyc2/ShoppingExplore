import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/features/shopping_list/data/models/product_suggestion_dto.dart';
import 'package:shopping_explore/features/shopping_list/data/models/shopping_item_dto.dart';
import 'package:shopping_explore/features/shopping_list/domain/entities/product_suggestion.dart';

void main() {
  group('ProductSuggestionDto JSON Serialization', () {
    const tSuggestionDto = ProductSuggestionDto(
      id: 'sug-1',
      name: 'Nike Pegasus',
      description: 'Great for running',
      imageUrl: 'https://example.com/shoe.jpg',
      pros: ['Comfortable', 'Durable'],
      cons: ['Expensive'],
      purchaseLocation: 'Nike Store',
      purchaseUrl: 'https://nike.com',
      price: 129.99,
    );

    const tSuggestionDomain = ProductSuggestion(
      id: 'sug-1',
      name: 'Nike Pegasus',
      description: 'Great for running',
      imageUrl: 'https://example.com/shoe.jpg',
      pros: ['Comfortable', 'Durable'],
      cons: ['Expensive'],
      purchaseLocation: 'Nike Store',
      purchaseUrl: 'https://nike.com',
      price: 129.99,
    );

    final tJson = {
      'id': 'sug-1',
      'name': 'Nike Pegasus',
      'description': 'Great for running',
      'imageUrl': 'https://example.com/shoe.jpg',
      'pros': ['Comfortable', 'Durable'],
      'cons': ['Expensive'],
      'purchaseLocation': 'Nike Store',
      'purchaseUrl': 'https://nike.com',
      'price': 129.99,
    };

    test('should return a valid ProductSuggestionDto from JSON', () {
      final result = ProductSuggestionDto.fromJson(tJson);
      expect(result, equals(tSuggestionDto));
    });

    test('should return a JSON map containing proper data', () {
      final result = tSuggestionDto.toJson();
      expect(result, equals(tJson));
    });

    test('should map from domain correctly', () {
      final result = ProductSuggestionDto.fromDomain(tSuggestionDomain);
      expect(result, equals(tSuggestionDto));
    });

    test('should map to domain correctly', () {
      final result = tSuggestionDto.toDomain();
      expect(result, equals(tSuggestionDomain));
    });

    test('ShoppingItemDto correctly serializes nested suggestions', () {
      final itemWithSuggestionsJson = {
        'id': 'item-1',
        'title': 'Running Shoes',
        'isCompleted': false,
        'quantity': 1.0,
        'unit': null,
        'priority': 'medium',
        'notes': null,
        'assignedToEmail': null,
        'imageUrls': [],
        'linkUrls': [],
        'attributes': {},
        'suggestions': [tJson],
        'createdAt': DateTime(2023).toIso8601String(),
        'updatedAt': DateTime(2023).toIso8601String(),
      };

      final dto = ShoppingItemDto.fromJson(itemWithSuggestionsJson);
      expect(dto.suggestions, hasLength(1));
      expect(dto.suggestions.first.id, equals('sug-1'));
      expect(dto.suggestions.first.name, equals('Nike Pegasus'));

      final outJson = dto.toJson();
      expect(outJson['suggestions'], isA<List>());
      expect((outJson['suggestions'] as List).first['name'], equals('Nike Pegasus'));
    });
  });
}
