/// Base class for all custom domain/data exceptions in ShoppingExplore.
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a remote server or REST API call fails.
class ServerException extends AppException {
  const ServerException(super.message);
}

/// Thrown when a local database (SQLite/Prefs) or cache operation fails.
class CacheException extends AppException {
  const CacheException(super.message);
}

/// Thrown when user input validation fails.
class ValidationException extends AppException {
  const ValidationException(super.message);
}
