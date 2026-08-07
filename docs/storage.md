---
aliases: [Firebase Storage, Upload, Media]
tags: [feature, data-layer, firebase]
---
# Storage Module

The **Storage Module** provides centralized media uploading capabilities using Firebase Storage. It is consumed across various features (such as Auth for avatars, and ShoppingList for item images) to keep file I/O and cloud uploads abstracted behind a simple interface.

## Architecture

This module lives in `lib/core/storage/` as a shared infrastructure component.

- **Domain:** `StorageRepository`
  - Defines the interface: `uploadAvatar(String userId, Uint8List fileBytes, String extension)` and `uploadItemImage(String listId, String itemId, Uint8List fileBytes, String extension)`.
- **Data:** `FirebaseStorageDataSource`
  - Implements the interface using `firebase_storage`.
  - Enforces `AppLogger` telemetry and maps Firebase exceptions to `NetworkFailure` or `ServerFailure`.

## Security Rules

Access to storage is governed by `storage.rules`:
- **Avatars**: Users can only upload and modify avatars in their specific `avatars/{userId}/` folder.
- **Item Images**: Authenticated users can upload to `lists/{listId}/items/{itemId}/`. Read access is open to authenticated users for shared lists.
