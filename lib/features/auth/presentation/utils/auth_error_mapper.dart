import 'package:shopping_explore/l10n/generated/app_localizations.dart';

/// Helper utility for mapping authentication error strings and Firebase error codes
/// to localized user-facing messages.
class AuthErrorMapper {
  AuthErrorMapper._();

  /// Maps a raw authentication error string or Firebase Auth exception message
  /// into a localized string using [l10n].
  static String mapErrorMessage(String? rawMessage, AppLocalizations? l10n) {
    if (rawMessage == null || rawMessage.trim().isEmpty) {
      return l10n?.authFailed ?? 'Authentication failed';
    }

    final lower = rawMessage.toLowerCase();

    if (lower.contains('invalid-email') || lower.contains('badly formatted')) {
      return l10n?.authErrorInvalidEmail ?? 'The email address is badly formatted.';
    }
    if (lower.contains('user-disabled') || lower.contains('disabled')) {
      return l10n?.authErrorUserDisabled ?? 'This user account has been disabled.';
    }
    if (lower.contains('user-not-found') || lower.contains('no user found')) {
      return l10n?.authErrorUserNotFound ?? 'No user found for that email.';
    }
    if (lower.contains('wrong-password')) {
      return l10n?.authErrorWrongPassword ?? 'Wrong password provided for that user.';
    }
    if (lower.contains('email-already-in-use') ||
        lower.contains('already in use') ||
        lower.contains('already registered')) {
      return l10n?.authErrorEmailAlreadyInUse ?? 'The email address is already in use by another account.';
    }
    if (lower.contains('weak-password') || lower.contains('not strong enough')) {
      return l10n?.authErrorWeakPassword ?? 'The password is not strong enough.';
    }
    if (lower.contains('network-request-failed') || lower.contains('network error')) {
      return l10n?.authErrorNetworkFailed ?? 'A network error occurred. Please check your connection.';
    }
    if (lower.contains('invalid-credential') || lower.contains('invalid email or password')) {
      return l10n?.authErrorInvalidCredential ?? 'Invalid login credentials.';
    }
    if (lower.contains('operation-not-allowed') ||
        lower.contains('configuration_not_found') ||
        lower.contains('not enabled')) {
      return l10n?.authErrorOperationNotAllowed ?? 'Email/password accounts are not enabled.';
    }

    return rawMessage;
  }
}
