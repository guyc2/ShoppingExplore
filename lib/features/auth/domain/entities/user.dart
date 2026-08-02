import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, createdAt];
}
