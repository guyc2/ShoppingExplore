import '../../domain/entities/shopping_list.dart';
import 'shopping_item_dto.dart';

class ShoppingListDto extends ShoppingList {
  const ShoppingListDto({
    required super.id,
    required super.title,
    super.description,
    super.colorHex,
    super.ownerId,
    super.sharedWithEmails = const [],
    super.items = const [],
    required super.createdAt,
    required super.updatedAt,
  });

  factory ShoppingListDto.fromJson(Map<String, dynamic> json) {
    return ShoppingListDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      colorHex: json['colorHex'] as String?,
      ownerId: json['ownerId'] as String?,
      sharedWithEmails: (json['sharedWithEmails'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => ShoppingItemDto.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'colorHex': colorHex,
      'ownerId': ownerId,
      'sharedWithEmails': sharedWithEmails,
      'items': items.map((item) => ShoppingItemDto.fromDomain(item).toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ShoppingListDto.fromDomain(ShoppingList list) {
    return ShoppingListDto(
      id: list.id,
      title: list.title,
      description: list.description,
      colorHex: list.colorHex,
      ownerId: list.ownerId,
      sharedWithEmails: list.sharedWithEmails,
      items: list.items,
      createdAt: list.createdAt,
      updatedAt: list.updatedAt,
    );
  }

  ShoppingList toDomain() {
    return ShoppingList(
      id: id,
      title: title,
      description: description,
      colorHex: colorHex,
      ownerId: ownerId,
      sharedWithEmails: sharedWithEmails,
      items: items.map((item) => ShoppingItemDto.fromDomain(item).toDomain()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
