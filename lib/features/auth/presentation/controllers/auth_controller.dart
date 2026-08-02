import 'package:flutter/foundation.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class AuthController extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthState _state = const AuthInitial();
  AuthState get state => _state;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  });

  Future<void> checkAuthStatus() async {
    _setState(const AuthLoading());
    AppLogger.i('Checking authentication status...', tag: 'AuthController');
    final result = await getCurrentUserUseCase.execute();
    if (result.isSuccess) {
      final user = result.value;
      if (user != null) {
        AppLogger.i('Authenticated as: ${user.email}', tag: 'AuthController');
        _setState(Authenticated(user));
      } else {
        AppLogger.i('No authenticated user found', tag: 'AuthController');
        _setState(const Unauthenticated());
      }
    } else {
      AppLogger.w('Failed to check auth status: ${result.error.message}', tag: 'AuthController');
      _setState(AuthError(result.error.message));
    }
  }

  Future<bool> login(String email, String password) async {
    _setState(const AuthLoading());
    AppLogger.d('Attempting login for email: $email', tag: 'AuthController');
    final result = await loginUseCase.execute(email: email, password: password);
    if (result.isSuccess) {
      final user = result.value;
      AppLogger.i('Login successful: ${user.email}', tag: 'AuthController');
      _setState(Authenticated(user));
      return true;
    } else {
      AppLogger.w('Login failed: ${result.error.message}', tag: 'AuthController');
      _setState(AuthError(result.error.message));
      return false;
    }
  }

  Future<bool> register(String email, String password, String displayName) async {
    _setState(const AuthLoading());
    AppLogger.d('Attempting registration for email: $email', tag: 'AuthController');
    final result = await registerUseCase.execute(
      email: email,
      password: password,
      displayName: displayName,
    );
    if (result.isSuccess) {
      final user = result.value;
      AppLogger.i('Registration successful: ${user.email}', tag: 'AuthController');
      _setState(Authenticated(user));
      return true;
    } else {
      AppLogger.w('Registration failed: ${result.error.message}', tag: 'AuthController');
      _setState(AuthError(result.error.message));
      return false;
    }
  }

  Future<void> logout() async {
    AppLogger.d('Logging out user...', tag: 'AuthController');
    final result = await logoutUseCase.execute();
    if (result.isSuccess) {
      AppLogger.i('Logout complete', tag: 'AuthController');
      _setState(const Unauthenticated());
    } else {
      AppLogger.w('Logout error: ${result.error.message}', tag: 'AuthController');
      _setState(const Unauthenticated());
    }
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }
}
