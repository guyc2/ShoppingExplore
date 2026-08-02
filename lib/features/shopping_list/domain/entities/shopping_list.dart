import 'package:equatable/equatable.dart';
import 'shopping_item.dart';

class ShoppingList extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? colorHex;
  final String? ownerId;
  final List<String> sharedWithEmails;
  final List<ShoppingItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShoppingList({
    required this.id,
    required this.title,
    this.description,
    this.colorHex,
    this.ownerId,
    this.sharedWithEmails = const [],
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  ShoppingList copyWith({
    String? id,
    String? title,
    String? description,
    String? colorHex,
    String? ownerId,
    List<String>? sharedWithEmails,
    List<ShoppingItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
      ownerId: ownerId ?? this.ownerId,
      sharedWithEmails: sharedWithEmails ?? this.sharedWithEmails,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        colorHex,
        ownerId,
        sharedWithEmails,
        items,
        createdAt,
        updatedAt,
      ];
}
