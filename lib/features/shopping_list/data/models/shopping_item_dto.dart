import '../../domain/entities/shopping_item.dart';

class ShoppingItemDto extends ShoppingItem {
  const ShoppingItemDto({
    required super.id,
    required super.title,
    super.isCompleted = false,
    super.quantity = 1.0,
    super.unit,
    super.priority = Priority.medium,
    super.notes,
    super.assignedToEmail,
    super.imageUrls = const [],
    super.linkUrls = const [],
    super.attributes = const {},
    required super.createdAt,
    required super.updatedAt,
  });

  factory ShoppingItemDto.fromJson(Map<String, dynamic> json) {
    return ShoppingItemDto(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] as String?,
      priority: Priority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => Priority.medium,
      ),
      notes: json['notes'] as String?,
      assignedToEmail: json['assignedToEmail'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.cast<String>() ?? const [],
      linkUrls: (json['linkUrls'] as List<dynamic>?)?.cast<String>() ?? const [],
      attributes: (json['attributes'] as Map<String, dynamic>?)?.cast<String, String>() ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'quantity': quantity,
      'unit': unit,
      'priority': priority.name,
      'notes': notes,
      'assignedToEmail': assignedToEmail,
      'imageUrls': imageUrls,
      'linkUrls': linkUrls,
      'attributes': attributes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ShoppingItemDto.fromDomain(ShoppingItem item) {
    return ShoppingItemDto(
      id: item.id,
      title: item.title,
      isCompleted: item.isCompleted,
      quantity: item.quantity,
      unit: item.unit,
      priority: item.priority,
      notes: item.notes,
      assignedToEmail: item.assignedToEmail,
      imageUrls: item.imageUrls,
      linkUrls: item.linkUrls,
      attributes: item.attributes,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  ShoppingItem toDomain() {
    return ShoppingItem(
      id: id,
      title: title,
      isCompleted: isCompleted,
      quantity: quantity,
      unit: unit,
      priority: priority,
      notes: notes,
      assignedToEmail: assignedToEmail,
      imageUrls: imageUrls,
      linkUrls: linkUrls,
      attributes: attributes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
