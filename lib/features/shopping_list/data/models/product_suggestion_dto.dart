import '../../domain/entities/product_suggestion.dart';

class ProductSuggestionDto extends ProductSuggestion {
  const ProductSuggestionDto({
    required super.id,
    required super.name,
    super.description,
    super.imageUrl,
    super.pros = const [],
    super.cons = const [],
    super.purchaseLocation,
    super.purchaseUrl,
    super.price,
    super.currency,
  });

  factory ProductSuggestionDto.fromJson(Map<String, dynamic> json) {
    return ProductSuggestionDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      pros: (json['pros'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      cons: (json['cons'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      purchaseLocation: json['purchaseLocation'] as String?,
      purchaseUrl: json['purchaseUrl'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'pros': pros,
      'cons': cons,
      'purchaseLocation': purchaseLocation,
      'purchaseUrl': purchaseUrl,
      'price': price,
      'currency': currency,
    };
  }

  factory ProductSuggestionDto.fromDomain(ProductSuggestion entity) {
    return ProductSuggestionDto(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      imageUrl: entity.imageUrl,
      pros: entity.pros,
      cons: entity.cons,
      purchaseLocation: entity.purchaseLocation,
      purchaseUrl: entity.purchaseUrl,
      price: entity.price,
      currency: entity.currency,
    );
  }

  ProductSuggestion toDomain() {
    return ProductSuggestion(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      pros: pros,
      cons: cons,
      purchaseLocation: purchaseLocation,
      purchaseUrl: purchaseUrl,
      price: price,
      currency: currency,
    );
  }
}
