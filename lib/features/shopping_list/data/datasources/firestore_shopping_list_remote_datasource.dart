import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/logger.dart';
import '../models/shopping_item_dto.dart';
import '../models/shopping_list_dto.dart';
import '../models/shopping_session_dto.dart';
import 'shopping_list_remote_datasource.dart';

class FirestoreShoppingListRemoteDataSource implements ShoppingListRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreShoppingListRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ShoppingListDto>> getShoppingLists(String userEmail) async {
    try {
      final cleanEmail = userEmail.trim().toLowerCase();
      AppLogger.d('Fetching shopping lists for: "$cleanEmail"', tag: 'FirestoreShoppingListRemoteDataSource');
      
      if (cleanEmail.isEmpty) {
        final snapshot = await _firestore.collection('shopping_lists').get();
        return snapshot.docs
            .map((doc) => ShoppingListDto.fromFirestore(doc.data(), docId: doc.id))
            .toList();
      }

      final ownedIdQuery = _firestore.collection('shopping_lists').where('ownerId', isEqualTo: cleanEmail).get();
      final ownedEmailQuery = _firestore.collection('shopping_lists').where('ownerEmail', isEqualTo: cleanEmail).get();
      final sharedQuery = _firestore.collection('shopping_lists').where('sharedWithEmails', arrayContains: cleanEmail).get();

      final results = await Future.wait([ownedIdQuery, ownedEmailQuery, sharedQuery]);
      
      final Map<String, ShoppingListDto> uniqueLists = {};
      
      for (final snapshot in results) {
        for (final doc in snapshot.docs) {
          uniqueLists[doc.id] = ShoppingListDto.fromFirestore(doc.data(), docId: doc.id);
        }
      }
      
      return uniqueLists.values.toList();
    } on FirebaseException catch (e) {
      AppLogger.e('Firebase error getting shopping lists', tag: 'FirestoreShoppingListRemoteDataSource', error: e);
      throw NetworkFailure('Failed to get shopping lists: ${e.message}');
    } catch (e) {
      AppLogger.e('Unknown error getting shopping lists', tag: 'FirestoreShoppingListRemoteDataSource', error: e);
      throw NetworkFailure('Failed to get shopping lists: $e');
    }
  }

  @override
  Future<ShoppingListDto> getShoppingList(String id) async {
    try {
      AppLogger.d('Fetching shopping list: $id', tag: 'FirestoreShoppingListRemoteDataSource');
      final doc = await _firestore.collection('shopping_lists').doc(id).get();
      if (!doc.exists || doc.data() == null) {
        throw CacheFailure('Shopping list not found: $id');
      }
      return ShoppingListDto.fromFirestore(doc.data()!, docId: doc.id);
    } on FirebaseException catch (e) {
      AppLogger.e('Firebase error getting shopping list', tag: 'FirestoreShoppingListRemoteDataSource', error: e);
      throw NetworkFailure('Failed to get shopping list: ${e.message}');
    }
  }

  @override
  Future<ShoppingListDto> saveShoppingList(ShoppingListDto dto) async {
    try {
      AppLogger.d('Saving shopping list: ${dto.id}', tag: 'FirestoreShoppingListRemoteDataSource');
      await _firestore.collection('shopping_lists').doc(dto.id).set(dto.toFirestore(), SetOptions(merge: true));
      return dto;
    } on FirebaseException catch (e) {
      AppLogger.e('Firebase error saving shopping list', tag: 'FirestoreShoppingListRemoteDataSource', error: e);
      throw NetworkFailure('Failed to save shopping list: ${e.message}');
    }
  }

  @override
  Future<ShoppingListDto> shareShoppingList(String listId, String email, {String? displayName}) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      AppLogger.d('Sharing shopping list $listId with $cleanEmail ($displayName)', tag: 'FirestoreShoppingListRemoteDataSource');
      
      final docRef = _firestore.collection('shopping_lists').doc(listId);
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) {
          throw const CacheFailure('List does not exist');
        }
        
        final List<dynamic> shared = (doc.data()?['sharedWithEmails'] as List<dynamic>?) ?? [];
        final Map<String, dynamic> names = Map<String, dynamic>.from((doc.data()?['collaboratorDisplayNames'] as Map<String, dynamic>?) ?? {});
        
        final updates = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
        };
        
        if (!shared.contains(cleanEmail)) {
          updates['sharedWithEmails'] = FieldValue.arrayUnion([cleanEmail]);
        }
        
        if (displayName != null && displayName.trim().isNotEmpty) {
          names[cleanEmail] = displayName.trim();
          updates['collaboratorDisplayNames'] = names;
        }
        
        transaction.update(docRef, updates);
      });
      
      return await getShoppingList(listId);
    } on FirebaseException catch (e) {
      AppLogger.e('Firebase error sharing shopping list', tag: 'FirestoreShoppingListRemoteDataSource', error: e);
      throw NetworkFailure('Failed to share shopping list: ${e.message}');
    }
  }

  @override
  Future<ShoppingListDto> removeCollaborator(String listId, String email) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      AppLogger.d('Removing collaborator $cleanEmail from list $listId', tag: 'FirestoreShoppingListRemoteDataSource');
      final docRef = _firestore.collection('shopping_lists').doc(listId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw CacheFailure('Cannot remove collaborator from non-existent list: $listId');
        }
        
        final data = snapshot.data() ?? {};
        final sharedRaw = data['sharedWithEmails'];
        final shared = sharedRaw is List ? List<String>.from(sharedRaw) : <String>[];
        final namesRaw = data['collaboratorDisplayNames'];
        final names = namesRaw is Map ? Map<String, dynamic>.from(namesRaw) : <String, dynamic>{};
        
        shared.removeWhere((e) => e.trim().toLowerCase() == cleanEmail);
        names.remove(cleanEmail);
        names.remove(email.trim());
        
        transaction.update(docRef, {
          'sharedWithEmails': shared,
          'collaboratorDisplayNames': names,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      
      return await getShoppingList(listId);
    } on FirebaseException catch (e) {
      AppLogger.e('Firebase error removing collaborator', tag: 'FirestoreShoppingListRemoteDataSource', error: e);
      throw NetworkFailure('Failed to remove collaborator: ${e.message}');
    }
  }

  @override
  Future<void> deleteShoppingList(String id) async {
    try {
      AppLogger.d('Deleting shopping list: $id', tag: 'FirestoreShoppingListRemoteDataSource');
      await _firestore.collection('shopping_lists').doc(id).delete();
    } on FirebaseException catch (e) {
      AppLogger.e('Firebase error deleting shopping list', tag: 'FirestoreShoppingListRemoteDataSource', error: e);
      throw NetworkFailure('Failed to delete shopping list: ${e.message}');
    }
  }

  @override
  Stream<List<ShoppingListDto>> watchShoppingLists(String userEmail) {
    final cleanEmail = userEmail.trim().toLowerCase();
    AppLogger.d('Watching shopping lists for: $cleanEmail', tag: 'FirestoreShoppingListRemoteDataSource');
    
    // Firestore supports Filter.or natively
    return _firestore
        .collection('shopping_lists')
        .where(
          Filter.or(
            Filter('ownerEmail', isEqualTo: cleanEmail),
            Filter('sharedWithEmails', arrayContains: cleanEmail),
          ),
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ShoppingListDto.fromFirestore(doc.data(), docId: doc.id))
          .toList();
    });
  }

  @override
  Stream<ShoppingListDto?> watchShoppingList(String id) {
    AppLogger.d('Watching shopping list: $id', tag: 'FirestoreShoppingListRemoteDataSource');
    return _firestore
        .collection('shopping_lists')
        .doc(id)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return ShoppingListDto.fromFirestore(doc.data()!, docId: doc.id);
    });
  }

  @override
  Future<void> saveShoppingItem(String listId, ShoppingItemDto item) async {
    try {
      AppLogger.d('Saving item ${item.id} to list $listId', tag: 'FirestoreShoppingListRemoteDataSource');
      final docRef = _firestore.collection('shopping_lists').doc(listId);

      // Read current items directly from the raw Firestore array field,
      // avoiding a full document re-parse that could fail if 'id' is absent.
      final doc = await docRef.get();
      if (!doc.exists) throw const CacheFailure('List not found');

      final rawItems = (doc.data()?['items'] as List<dynamic>?) ?? [];
      final items = rawItems
          .map((e) => ShoppingItemDto.fromFirestore(e as Map<String, dynamic>))
          .toList();

      final idx = items.indexWhere((i) => i.id == item.id);
      if (idx >= 0) {
        items[idx] = item;
      } else {
        items.add(item);
      }

      await docRef.update({
        'items': items.map((i) => i.toFirestore()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.i('Successfully saved item ${item.id} in list $listId', tag: 'FirestoreShoppingListRemoteDataSource');
    } on FirebaseException catch (e) {
      AppLogger.e('Firebase error saving item', error: e, tag: 'FirestoreShoppingListRemoteDataSource');
      throw NetworkFailure('Failed to save shopping item: ${e.message}');
    } catch (e) {
      AppLogger.e('Failed to save shopping item', error: e, tag: 'FirestoreShoppingListRemoteDataSource');
      throw NetworkFailure('Failed to save shopping item: $e');
    }
  }

  @override
  Future<void> deleteShoppingItem(String listId, String itemId) async {
    try {
      AppLogger.d('Deleting item $itemId from list $listId', tag: 'FirestoreShoppingListRemoteDataSource');
      final docRef = _firestore.collection('shopping_lists').doc(listId);

      final doc = await docRef.get();
      if (!doc.exists) throw const CacheFailure('List not found');

      final rawItems = (doc.data()?['items'] as List<dynamic>?) ?? [];
      final items = rawItems
          .map((e) => ShoppingItemDto.fromFirestore(e as Map<String, dynamic>))
          .where((i) => i.id != itemId)
          .toList();

      await docRef.update({
        'items': items.map((i) => i.toFirestore()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.i('Successfully deleted item $itemId from list $listId', tag: 'FirestoreShoppingListRemoteDataSource');
    } on FirebaseException catch (e) {
      AppLogger.e('Firebase error deleting item', error: e, tag: 'FirestoreShoppingListRemoteDataSource');
      throw NetworkFailure('Failed to delete shopping item: ${e.message}');
    } catch (e) {
      AppLogger.e('Failed to delete shopping item', error: e, tag: 'FirestoreShoppingListRemoteDataSource');
      throw NetworkFailure('Failed to delete shopping item: $e');
    }
  }

  @override
  Future<ShoppingListDto> startShoppingSession(String listId, String userEmail, {String? locationName}) async {
    try {
      AppLogger.d('Starting shopping session for $userEmail on list $listId', tag: 'FirestoreShoppingListRemoteDataSource');
      final docRef = _firestore.collection('shopping_lists').doc(listId);
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) throw const CacheFailure('List not found');
        
        final listDto = ShoppingListDto.fromFirestore(doc.data()!);
        final sessions = List<ShoppingSessionDto>.from(listDto.activeSessions.map((s) => ShoppingSessionDto.fromDomain(s)));
        
        sessions.removeWhere((s) => s.userEmail == userEmail);
        sessions.add(ShoppingSessionDto(
          userEmail: userEmail,
          locationName: locationName,
          startedAt: DateTime.now().toIso8601String(),
        ));
        
        transaction.update(docRef, {
          'activeSessions': sessions.map((s) => s.toFirestore()).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      
      return await getShoppingList(listId);
    } catch (e) {
      AppLogger.e('Failed to start shopping session', error: e, tag: 'FirestoreShoppingListRemoteDataSource');
      throw NetworkFailure('Failed to start shopping session: $e');
    }
  }

  @override
  Future<ShoppingListDto> endShoppingSession(String listId, String userEmail) async {
    try {
      AppLogger.d('Ending shopping session for $userEmail on list $listId', tag: 'FirestoreShoppingListRemoteDataSource');
      final docRef = _firestore.collection('shopping_lists').doc(listId);
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) throw const CacheFailure('List not found');
        
        final listDto = ShoppingListDto.fromFirestore(doc.data()!);
        final sessions = List<ShoppingSessionDto>.from(listDto.activeSessions.map((s) => ShoppingSessionDto.fromDomain(s)));
        
        sessions.removeWhere((s) => s.userEmail == userEmail);
        
        transaction.update(docRef, {
          'activeSessions': sessions.map((s) => s.toFirestore()).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      
      return await getShoppingList(listId);
    } catch (e) {
      AppLogger.e('Failed to end shopping session', error: e, tag: 'FirestoreShoppingListRemoteDataSource');
      throw NetworkFailure('Failed to end shopping session: $e');
    }
  }
}
