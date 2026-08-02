import '../../domain/entities/user.dart';

class UserDto {
  final String id;
  final String email;
  final String displayName;
  final String createdAt;

  const UserDto({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt,
    };
  }

  User toDomain() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }

  factory UserDto.fromDomain(User user) {
    return UserDto(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      createdAt: user.createdAt.toIso8601String(),
    );
  }
}
