import 'package:equatable/equatable.dart';

class ShoppingSession extends Equatable {
  final String userEmail;
  final String? locationName;
  final DateTime startedAt;

  const ShoppingSession({
    required this.userEmail,
    this.locationName,
    required this.startedAt,
  });

  ShoppingSession copyWith({
    String? userEmail,
    String? locationName,
    DateTime? startedAt,
  }) {
    return ShoppingSession(
      userEmail: userEmail ?? this.userEmail,
      locationName: locationName ?? this.locationName,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  @override
  List<Object?> get props => [userEmail, locationName, startedAt];
}
