import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/core/utils/logger.dart';

void main() {
  group('AppLogger', () {
    test('logs debug message without throwing', () {
      expect(() => AppLogger.d('Debug message', tag: 'Test'), returnsNormally);
    });

    test('logs info message without throwing', () {
      expect(() => AppLogger.i('Info message', tag: 'Test'), returnsNormally);
    });

    test('logs warning message without throwing', () {
      expect(
        () => AppLogger.w('Warning message', tag: 'Test', error: 'Sample Error'),
        returnsNormally,
      );
    });

    test('logs error message without throwing', () {
      expect(
        () => AppLogger.e(
          'Error message',
          error: Exception('Test Exception'),
          stackTrace: StackTrace.current,
          tag: 'Test',
        ),
        returnsNormally,
      );
    });
  });
}
