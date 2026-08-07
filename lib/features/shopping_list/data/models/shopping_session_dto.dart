import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/shopping_session.dart';

class ShoppingSessionDto {
  final String userEmail;
  final String? locationName;
  final String startedAt;

  const ShoppingSessionDto({
    required this.userEmail,
    this.locationName,
    required this.startedAt,
  });

  factory ShoppingSessionDto.fromJson(Map<String, dynamic> json) {
    return ShoppingSessionDto(
      userEmail: json['userEmail'] as String,
      locationName: json['locationName'] as String?,
      startedAt: json['startedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userEmail': userEmail,
      'locationName': locationName,
      'startedAt': startedAt,
    };
  }

  factory ShoppingSessionDto.fromFirestore(Map<String, dynamic> data) {
    return ShoppingSessionDto(
      userEmail: data['userEmail'] as String,
      locationName: data['locationName'] as String?,
      startedAt: data['startedAt'] is Timestamp
          ? (data['startedAt'] as Timestamp).toDate().toIso8601String()
          : (data['startedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userEmail': userEmail,
      'locationName': locationName,
      'startedAt': Timestamp.fromDate(DateTime.parse(startedAt)),
    };
  }

  factory ShoppingSessionDto.fromDomain(ShoppingSession session) {
    return ShoppingSessionDto(
      userEmail: session.userEmail,
      locationName: session.locationName,
      startedAt: session.startedAt.toIso8601String(),
    );
  }

  ShoppingSession toDomain() {
    return ShoppingSession(
      userEmail: userEmail,
      locationName: locationName,
      startedAt: DateTime.parse(startedAt),
    );
  }
}
