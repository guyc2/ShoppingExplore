import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/shopping_list.dart';
import 'shopping_item_dto.dart';
import 'shopping_session_dto.dart';

class ShoppingListDto extends ShoppingList {
  const ShoppingListDto({
    required super.id,
    required super.title,
    super.shortDescription,
    super.description,
    super.colorHex,
    super.imageUrl,
    super.ownerId,
    super.sharedWithEmails = const [],
    super.items = const [],
    super.activeSessions = const [],
    required super.createdAt,
    required super.updatedAt,
  });

  factory ShoppingListDto.fromJson(Map<String, dynamic> json) {
    return ShoppingListDto(
      id: json['id'] as String,
      title: json['title'] as String,
      shortDescription: json['shortDescription'] as String?,
      description: json['description'] as String?,
      colorHex: json['colorHex'] as String?,
      imageUrl: json['imageUrl'] as String?,
      ownerId: json['ownerId'] as String?,
      sharedWithEmails: (json['sharedWithEmails'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => ShoppingItemDto.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      activeSessions: (json['activeSessions'] as List<dynamic>?)
              ?.map((session) => ShoppingSessionDto.fromJson(session as Map<String, dynamic>).toDomain())
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
      'shortDescription': shortDescription,
      'description': description,
      'colorHex': colorHex,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'sharedWithEmails': sharedWithEmails,
      'items': items.map((item) => ShoppingItemDto.fromDomain(item).toJson()).toList(),
      'activeSessions': activeSessions.map((session) => ShoppingSessionDto.fromDomain(session).toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ShoppingListDto.fromFirestore(Map<String, dynamic> data) {
    return ShoppingListDto(
      id: data['id'] as String,
      title: data['title'] as String,
      shortDescription: data['shortDescription'] as String?,
      description: data['description'] as String?,
      colorHex: data['colorHex'] as String?,
      imageUrl: data['imageUrl'] as String?,
      ownerId: (data['ownerId'] as String?) ?? (data['ownerEmail'] as String?),
      sharedWithEmails: (data['sharedWithEmails'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => ShoppingItemDto.fromFirestore(item as Map<String, dynamic>))
              .toList() ??
          const [],
      activeSessions: (data['activeSessions'] as List<dynamic>?)
              ?.map((session) => ShoppingSessionDto.fromFirestore(session as Map<String, dynamic>).toDomain())
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
      'shortDescription': shortDescription,
      'description': description,
      'colorHex': colorHex,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerEmail': ownerId,
      'sharedWithEmails': sharedWithEmails,
      'items': items.map((item) => ShoppingItemDto.fromDomain(item).toFirestore()).toList(),
      'activeSessions': activeSessions.map((session) => ShoppingSessionDto.fromDomain(session).toFirestore()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ShoppingListDto.fromDomain(ShoppingList list) {
    return ShoppingListDto(
      id: list.id,
      title: list.title,
      shortDescription: list.shortDescription,
      description: list.description,
      colorHex: list.colorHex,
      imageUrl: list.imageUrl,
      ownerId: list.ownerId,
      sharedWithEmails: list.sharedWithEmails,
      items: list.items,
      activeSessions: list.activeSessions,
      createdAt: list.createdAt,
      updatedAt: list.updatedAt,
    );
  }

  ShoppingList toDomain() {
    return ShoppingList(
      id: id,
      title: title,
      shortDescription: shortDescription,
      description: description,
      colorHex: colorHex,
      imageUrl: imageUrl,
      ownerId: ownerId,
      sharedWithEmails: sharedWithEmails,
      items: items.map((item) => ShoppingItemDto.fromDomain(item).toDomain()).toList(),
      activeSessions: activeSessions,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
