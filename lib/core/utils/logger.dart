import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

class AppLogger {
  static void log(LogLevel level, String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    final logTag = tag != null ? '[$tag]' : '[App]';
    final levelName = level.name.toUpperCase();
    final formattedMessage = '$logTag $levelName: $message';

    developer.log(
      formattedMessage,
      time: DateTime.now(),
      level: _getDeveloperLevel(level),
      name: 'ShoppingExplore',
      error: error,
      stackTrace: stackTrace,
    );

    assert(() {
      // ignore: avoid_print
      print('${DateTime.now().toIso8601String()} $formattedMessage');
      // ignore: avoid_print
      if (error != null) print('Error: $error');
      // ignore: avoid_print
      if (stackTrace != null) print('StackTrace:\n$stackTrace');
      return true;
    }());
  }

  static void d(String message, {String? tag}) => log(LogLevel.debug, message, tag: tag);
  static void i(String message, {String? tag}) => log(LogLevel.info, message, tag: tag);
  static void w(String message, {String? tag, Object? error}) => log(LogLevel.warning, message, tag: tag, error: error);
  static void e(String message, {Object? error, StackTrace? stackTrace, String? tag}) =>
      log(LogLevel.error, message, error: error, stackTrace: stackTrace, tag: tag);

  static int _getDeveloperLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}
