import '../../../../core/error/failure.dart';
import '../models/user_dto.dart';

abstract class AuthLocalDataSource {
  Future<UserDto> login(String email, String password);
  Future<UserDto> register(String email, String password, String displayName);
  Future<void> logout();
  Future<UserDto?> getCurrentUser();
}

class InMemoryAuthDataSource implements AuthLocalDataSource {
  final Map<String, _StoredUser> _users = {
    'user@shoppingexplore.com': _StoredUser(
      dto: const UserDto(
        id: 'user-1',
        email: 'user@shoppingexplore.com',
        displayName: 'Alex User',
        createdAt: '2026-08-01T10:00:00.000Z',
      ),
      password: 'password123',
    ),
    'friend@shoppingexplore.com': _StoredUser(
      dto: const UserDto(
        id: 'user-2',
        email: 'friend@shoppingexplore.com',
        displayName: 'Taylor Friend',
        createdAt: '2026-08-01T10:00:00.000Z',
      ),
      password: 'password123',
    ),
    'admin@shoppingexplore.com': _StoredUser(
      dto: const UserDto(
        id: 'user-3',
        email: 'admin@shoppingexplore.com',
        displayName: 'Admin Manager',
        createdAt: '2026-08-01T10:00:00.000Z',
      ),
      password: 'password123',
    ),
  };

  UserDto? _currentUserDto;

  InMemoryAuthDataSource({bool startAuthenticated = true}) {
    if (startAuthenticated) {
      _currentUserDto = _users['user@shoppingexplore.com']?.dto;
    } else {
      _currentUserDto = null;
    }
  }


  @override
  Future<UserDto> login(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final stored = _users[cleanEmail];
    if (stored == null || stored.password != password) {
      throw const ValidationFailure(
        'Invalid email or password. Try user@shoppingexplore.com / password123',
      );
    }
    _currentUserDto = stored.dto;
    return stored.dto;
  }

  @override
  Future<UserDto> register(String email, String password, String displayName) async {
    final cleanEmail = email.trim().toLowerCase();
    if (_users.containsKey(cleanEmail)) {
      throw const ValidationFailure('Email address is already registered.');
    }
    final newDto = UserDto(
      id: 'user-${_users.length + 1}',
      email: cleanEmail,
      displayName: displayName.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );
    _users[cleanEmail] = _StoredUser(dto: newDto, password: password);
    _currentUserDto = newDto;
    return newDto;
  }

  @override
  Future<void> logout() async {
    _currentUserDto = null;
  }

  @override
  Future<UserDto?> getCurrentUser() async {
    return _currentUserDto;
  }
}

class _StoredUser {
  final UserDto dto;
  final String password;

  _StoredUser({required this.dto, required this.password});
}
