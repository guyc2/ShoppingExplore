import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/shopping_item.dart';
import 'product_suggestion_dto.dart';

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
    super.suggestions = const [],
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
      attributes: (json['attributes'] as Map?)?.cast<String, String>() ?? const {},
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) => ProductSuggestionDto.fromJson(Map<String, dynamic>.from(e as Map)))
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
      'isCompleted': isCompleted,
      'quantity': quantity,
      'unit': unit,
      'priority': priority.name,
      'notes': notes,
      'assignedToEmail': assignedToEmail,
      'imageUrls': imageUrls,
      'linkUrls': linkUrls,
      'attributes': attributes,
      'suggestions': suggestions.map((s) => ProductSuggestionDto.fromDomain(s).toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ShoppingItemDto.fromFirestore(Map<String, dynamic> data) {
    return ShoppingItemDto(
      id: data['id'] as String,
      title: data['title'] as String,
      isCompleted: data['isCompleted'] as bool? ?? false,
      quantity: (data['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: data['unit'] as String?,
      priority: Priority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => Priority.medium,
      ),
      notes: data['notes'] as String?,
      assignedToEmail: data['assignedToEmail'] as String?,
      imageUrls: (data['imageUrls'] as List<dynamic>?)?.cast<String>() ?? const [],
      linkUrls: (data['linkUrls'] as List<dynamic>?)?.cast<String>() ?? const [],
      attributes: (data['attributes'] as Map?)?.cast<String, String>() ?? const {},
      suggestions: (data['suggestions'] as List<dynamic>?)
              ?.map((e) => ProductSuggestionDto.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : (data['createdAt'] is String
              ? DateTime.parse(data['createdAt'] as String)
              : DateTime.now()),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : (data['updatedAt'] is String
              ? DateTime.parse(data['updatedAt'] as String)
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toFirestore() {
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
      'suggestions': suggestions.map((s) => ProductSuggestionDto.fromDomain(s).toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
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
      suggestions: item.suggestions,
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
      suggestions: suggestions,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
