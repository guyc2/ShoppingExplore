---
name: logging
description: Guidelines and utility interface for logging events, warnings, and errors across the application. Use when adding logs to repositories, view models, or data sources.
---
# Logging Guidelines

When building or modifying features in **ShoppingExplore**, use the customized central logger utility.

## Setup & Interface

The central logging interface is defined in `lib/core/utils/logger.dart` via the `AppLogger` utility.

### Logging Methods

1. **Debug Logs (`AppLogger.d`)**: Use for fine-grained development tracing (e.g., entering methods, caching lookups, state transitions).
2. **Info Logs (`AppLogger.i`)**: Use for key system events (e.g., initialization, API requests start, user actions).
3. **Warning Logs (`AppLogger.w`)**: Use for non-fatal errors or unexpected states that can be recovered from.
4. **Error Logs (`AppLogger.e`)**: Use for severe failures, throwing exceptions, or failed computations (always provide error object and stack trace).

## Code Pattern Example

### Repository / Data Source Usage
```dart
import 'package:shopping_explore/core/utils/logger.dart';

Future<void> fetchData() async {
  AppLogger.d('Starting data fetch...', tag: 'MyRepository');
  try {
    // operation
    AppLogger.i('Data fetch successful', tag: 'MyRepository');
  } catch (e, stackTrace) {
    AppLogger.e('Data fetch failed', error: e, stackTrace: stackTrace, tag: 'MyRepository');
  }
}
```

### State Management (ViewModel) Usage
```dart
import 'package:shopping_explore/core/utils/logger.dart';

class MyController extends StateNotifier {
  void action() {
    AppLogger.d('Controller action triggered', tag: 'MyController');
    // update state
  }
}
```
