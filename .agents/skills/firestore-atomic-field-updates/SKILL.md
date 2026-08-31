---
name: firestore-atomic-field-updates
description: >
  How to perform atomic Firestore field updates (array add/remove, map merge)
  WITHOUT using runTransaction, to avoid MissingPluginException on the
  firebase_firestore transaction platform channel. Use whenever you need to
  atomically modify an array or map field in Firestore, especially in Flutter
  apps where runTransaction can fail during stream teardown or hot reload.
tags: [firebase, firestore, flutter, bugfix, data]
---

# firestore-atomic-field-updates

## The Problem — Why `runTransaction` Breaks

`FirebaseFirestore.instance.runTransaction(...)` opens a native platform channel
listener for the duration of the transaction. If the channel is torn down before
the transaction completes (e.g. during a hot reload, stream cancel, or widget
dispose), Flutter throws:

```
MissingPluginException(No implementation found for method cancel on channel
plugins.flutter.io/firebase_firestore/transaction/<uuid>)
```

This is a known Flutter/Firestore interplay issue and is **not** a Firestore
data-consistency problem — the data may or may not have been written.

---

## The Fix — FieldValue Sentinels + `get` + `update`

Firestore provides **server-side atomic operations** via `FieldValue` that do
not require a transaction for most common update patterns:

| Operation | FieldValue | Atomic? |
|---|---|---|
| Add element to array | `FieldValue.arrayUnion([x])` | ✅ Yes |
| Remove element from array | `FieldValue.arrayRemove([x])` | ✅ Yes |
| Increment a number | `FieldValue.increment(n)` | ✅ Yes |
| Set server timestamp | `FieldValue.serverTimestamp()` | ✅ Yes |
| Merge a map field | needs `get` + `update` | ⚠️ Read-then-write |

---

## Pattern A — Pure Array Operations (no transaction needed)

```dart
// ✅ CORRECT — atomic, no transaction, no channel issues
await docRef.update({
  'sharedWithEmails': FieldValue.arrayRemove([cleanEmail]),
  'updatedAt': FieldValue.serverTimestamp(),
});
```

```dart
// ✅ CORRECT — atomic add
await docRef.update({
  'sharedWithEmails': FieldValue.arrayUnion([cleanEmail]),
  'updatedAt': FieldValue.serverTimestamp(),
});
```

---

## Pattern B — Map Field Merge (read-then-write, no transaction)

When you need to update a nested map field (e.g. `collaboratorDisplayNames`),
`FieldValue` alone is not enough. Use a plain `get` + `update`:

```dart
// Step 1 — read current map
final snapshot = await docRef.get();
if (!snapshot.exists) throw CacheFailure('Document not found: $id');

final data = snapshot.data() ?? {};
final names = data['collaboratorDisplayNames'] is Map
    ? Map<String, dynamic>.from(data['collaboratorDisplayNames'] as Map)
    : <String, dynamic>{};

// Step 2 — mutate in memory
names.remove(cleanEmail);                         // or: names[cleanEmail] = value;

// Step 3 — write the updated map + any FieldValue sentinels in one call
await docRef.update({
  'collaboratorDisplayNames': names,
  'sharedWithEmails': FieldValue.arrayRemove([cleanEmail]),  // still atomic
  'updatedAt': FieldValue.serverTimestamp(),
});
```

> ⚠️ This is a read-then-write, not a true transaction. If two clients update
> the same map simultaneously, the last write wins for that field. This is
> acceptable for low-contention map fields like display name lookups. If you
> need true atomicity on map merges, use Cloud Functions or a dedicated
> subcollection instead.

---

## Pattern C — Combining Both in One Update Call

You can mix `FieldValue` sentinels and plain values in a single `update()` call:

```dart
await docRef.update({
  'sharedWithEmails': FieldValue.arrayUnion([cleanEmail]),  // atomic
  'collaboratorDisplayNames': updatedNamesMap,              // read-then-write
  'updatedAt': FieldValue.serverTimestamp(),                // atomic
});
```

This is a single network round-trip and avoids all transaction channel issues.

---

## When You Still Need `runTransaction`

Use `runTransaction` only when:
- You must **read a value and conditionally write based on it** with true isolation (e.g. decrement a counter only if > 0)
- The read and write **must be atomic** and concurrent clients could race

In those cases, ensure the transaction completes before any widget disposal or
stream cancellation can occur (e.g. guard with a flag, or run in an isolate).

---

## Checklist — Migrating Away From `runTransaction`

```
[ ] Identify what the transaction is reading
[ ] Is the read only needed to update an array field?
      → Use FieldValue.arrayUnion / arrayRemove — no read needed
[ ] Is the read needed to update a map field?
      → Use get() + update() with in-memory map mutation
[ ] Is the read needed for a conditional write?
      → Keep runTransaction but move it outside the widget lifecycle
[ ] Replace transaction.update() with docRef.update()
[ ] Replace transaction.get() with await docRef.get()
[ ] Remove the _firestore.runTransaction() wrapper entirely
[ ] Run flutter analyze — zero issues required
[ ] Run flutter test — all tests must pass
```

---

## Reference Implementation

See [`firestore_shopping_list_remote_datasource.dart`](file:///c:/Projects/ShoppingExplore/lib/features/shopping_list/data/datasources/firestore_shopping_list_remote_datasource.dart)
— `shareShoppingList()` and `removeCollaborator()` methods for the full
before/after migration applied in ShoppingExplore.
