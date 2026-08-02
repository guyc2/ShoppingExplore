import 'package:equatable/equatable.dart';

enum Priority { low, medium, high }

class ShoppingItem extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;
  final double quantity;
  final String? unit;
  final Priority priority;
  final String? notes;
  final String? assignedToEmail;
  final List<String> imageUrls;
  final List<String> linkUrls;
  final Map<String, String> attributes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShoppingItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.quantity = 1.0,
    this.unit,
    this.priority = Priority.medium,
    this.notes,
    this.assignedToEmail,
    this.imageUrls = const [],
    this.linkUrls = const [],
    this.attributes = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  ShoppingItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    double? quantity,
    String? unit,
    Priority? priority,
    String? notes,
    String? assignedToEmail,
    List<String>? imageUrls,
    List<String>? linkUrls,
    Map<String, String>? attributes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      assignedToEmail: assignedToEmail ?? this.assignedToEmail,
      imageUrls: imageUrls ?? this.imageUrls,
      linkUrls: linkUrls ?? this.linkUrls,
      attributes: attributes ?? this.attributes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        isCompleted,
        quantity,
        unit,
        priority,
        notes,
        assignedToEmail,
        imageUrls,
        linkUrls,
        attributes,
        createdAt,
        updatedAt,
      ];
}
