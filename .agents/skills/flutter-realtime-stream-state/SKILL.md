---
name: flutter-realtime-stream-state
description: Guides implementing leak-free real-time broadcast streams in Repositories and subscription state management in MVVM Controllers. Use when adding real-time sync, stream use cases, or live listeners.
---

# Reactive Real-Time Stream State & MVVM Sync Skill

In **ShoppingExplore**, real-time synchronization across shared users is powered by broadcast streams in the Repository layer (`watchShoppingLists`, `watchShoppingList`) and lifecycle-managed stream subscriptions in the Presentation Controller layer (`ShoppingListController`).

---

## 1. Repository Broadcast Stream Architecture

When exposing real-time streams from a repository implementation (`RepositoryImpl`), use `StreamController<T>.broadcast()` with non-blocking `onListen` and `onCancel` handlers:

```dart
@override
Stream<List<ShoppingList>> watchShoppingLists({String? userEmail}) {
  late final StreamController<List<ShoppingList>> controller;
  StreamSubscription? sub;

  controller = StreamController<List<ShoppingList>>.broadcast(
    onListen: () {
      // Emit initial snapshot non-blocking
      getShoppingLists(userEmail: userEmail).then((result) {
        if (!controller.isClosed && result.isSuccess && result.value != null) {
          controller.add(result.value!);
        }
      });

      // Subscribe to underlying data source stream
      sub = _localDataSource.changesStream.listen((_) {
        getShoppingLists(userEmail: userEmail).then((result) {
          if (!controller.isClosed && result.isSuccess && result.value != null) {
            controller.add(result.value!);
          }
        });
      });
    },
    onCancel: () {
      sub?.cancel();
    },
  );

  return controller.stream;
}
```

---

## 2. Controller Stream Subscription Lifecycle

In MVVM Controllers (`ChangeNotifier` / `ValueNotifier`), manage active `StreamSubscription` instances explicitly to prevent memory leaks or duplicate listeners:

```dart
StreamSubscription? _listsSubscription;

void subscribeToShoppingLists({String? userEmail}) {
  _listsSubscription?.cancel();
  _listsSubscription = _watchShoppingListsUseCase(userEmail: userEmail).listen(
    (lists) {
      _state = ShoppingListLoaded(lists);
      notifyListeners();
    },
    onError: (error) {
      AppLogger.e('Stream error in subscribeToShoppingLists', error, tag: 'Controller');
    },
  );
}

@override
void dispose() {
  _listsSubscription?.cancel();
  super.dispose();
}
```

---

## 3. Testing Real-Time Stream State

In unit tests, verify real-time reactivity by:
1. Subscribing to the controller or repository stream.
2. Performing a mutating operation (`saveShoppingList`, `deleteShoppingItem`).
3. Using `expectLater(stream, emits(...))` or verifying that the controller state updates automatically without manual polling.
