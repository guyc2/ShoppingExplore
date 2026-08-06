import 'package:equatable/equatable.dart';

class ProductSuggestion extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<String> pros;
  final List<String> cons;
  final String? purchaseLocation;
  final String? purchaseUrl;
  final double? price;
  final String? currency;

  const ProductSuggestion({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.pros = const [],
    this.cons = const [],
    this.purchaseLocation,
    this.purchaseUrl,
    this.price,
    this.currency,
  });

  ProductSuggestion copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    List<String>? pros,
    List<String>? cons,
    String? purchaseLocation,
    String? purchaseUrl,
    double? price,
    String? currency,
  }) {
    return ProductSuggestion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      pros: pros ?? this.pros,
      cons: cons ?? this.cons,
      purchaseLocation: purchaseLocation ?? this.purchaseLocation,
      purchaseUrl: purchaseUrl ?? this.purchaseUrl,
      price: price ?? this.price,
      currency: currency ?? this.currency,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        pros,
        cons,
        purchaseLocation,
        purchaseUrl,
        price,
        currency,
      ];
}
