import '../models/user_dto.dart';

abstract class AuthRemoteDataSource {
  Future<UserDto> login(String email, String password);
  Future<UserDto> register(String email, String password, String displayName);
  Future<void> logout();
  Future<UserDto?> getCurrentUser();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserDto> updateProfile(String displayName, String? avatarUrl);
}
