import 'package:flutter/foundation.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/restore_persistent_session_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';

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
  final UpdateUserProfileUseCase? updateUserProfileUseCase;
  final RestorePersistentSessionUseCase? restorePersistentSessionUseCase;
  final SignInWithGoogleUseCase? signInWithGoogleUseCase;

  AuthState _state = const AuthInitial();
  AuthState get state => _state;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    this.updateUserProfileUseCase,
    this.restorePersistentSessionUseCase,
    this.signInWithGoogleUseCase,
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
      } else if (restorePersistentSessionUseCase != null) {
        AppLogger.i('Attempting to restore persistent session...', tag: 'AuthController');
        final restoreResult = await restorePersistentSessionUseCase!.execute();
        if (restoreResult.isSuccess && restoreResult.value != null) {
          final restoredUser = restoreResult.value!;
          AppLogger.i('Restored persistent session as: ${restoredUser.email}', tag: 'AuthController');
          _setState(Authenticated(restoredUser));
        } else {
          AppLogger.i('No persistent session found', tag: 'AuthController');
          _setState(const Unauthenticated());
        }
      } else {
        AppLogger.i('No authenticated user found', tag: 'AuthController');
        _setState(const Unauthenticated());
      }
    } else {
      AppLogger.w('Failed to check auth status: ${result.error.message}', tag: 'AuthController');
      _setState(AuthError(result.error.message));
    }
  }

  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    _setState(const AuthLoading());
    AppLogger.d('Attempting login for email: $email (rememberMe: $rememberMe)', tag: 'AuthController');
    final result = await loginUseCase.execute(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
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

  Future<bool> register(
    String email,
    String password,
    String displayName, {
    bool rememberMe = false,
  }) async {
    _setState(const AuthLoading());
    AppLogger.d('Attempting registration for email: $email (rememberMe: $rememberMe)', tag: 'AuthController');
    final result = await registerUseCase.execute(
      email: email,
      password: password,
      displayName: displayName,
      rememberMe: rememberMe,
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

  Future<bool> signInWithGoogle({bool rememberMe = false}) async {
    if (signInWithGoogleUseCase == null) {
      AppLogger.w('SignInWithGoogleUseCase is not configured', tag: 'AuthController');
      return false;
    }
    _setState(const AuthLoading());
    AppLogger.d('Attempting Google Sign-In (rememberMe: $rememberMe)', tag: 'AuthController');
    final result = await signInWithGoogleUseCase!.execute(rememberMe: rememberMe);
    if (result.isSuccess) {
      final user = result.value;
      AppLogger.i('Google Sign-In successful: ${user.email}', tag: 'AuthController');
      _setState(Authenticated(user));
      return true;
    } else {
      AppLogger.w('Google Sign-In failed: ${result.error.message}', tag: 'AuthController');
      _setState(AuthError(result.error.message));
      return false;
    }
  }

  Future<bool> updateProfile({
    required String displayName,
    String? avatarUrl,
  }) async {
    if (updateUserProfileUseCase == null) {
      AppLogger.w('UpdateUserProfileUseCase is not configured', tag: 'AuthController');
      return false;
    }
    AppLogger.d('Updating user profile: $displayName', tag: 'AuthController');
    final result = await updateUserProfileUseCase!.execute(
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
    if (result.isSuccess) {
      final updatedUser = result.value;
      AppLogger.i('User profile updated successfully: ${updatedUser.displayName}', tag: 'AuthController');
      _setState(Authenticated(updatedUser));
      return true;
    } else {
      AppLogger.w('Failed to update user profile: ${result.error.message}', tag: 'AuthController');
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
