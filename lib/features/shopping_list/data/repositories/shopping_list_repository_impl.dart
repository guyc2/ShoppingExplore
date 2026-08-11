// ignore_for_file: close_sinks
import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/domain/repositories/storage_repository.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/entities/shopping_list.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import '../datasources/shopping_list_remote_datasource.dart';
import '../models/shopping_item_dto.dart';
import '../models/shopping_list_dto.dart';

class ShoppingListRepositoryImpl implements ShoppingListRepository {
  final ShoppingListRemoteDataSource remoteDataSource;
  final StorageRepository storageRepository;

  ShoppingListRepositoryImpl({
    required this.remoteDataSource,
    required this.storageRepository,
  });

  @override
  Future<Result<List<ShoppingList>>> getShoppingLists() async {
    AppLogger.d('getShoppingLists requested', tag: 'ShoppingListRepository');
    try {
      String userEmail = '';
      try {
        userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      } catch (_) {
        userEmail = 'test@shoppingexplore.com';
      }
      final dtos = await remoteDataSource.getShoppingLists(userEmail);
      final lists = dtos.map((dto) => dto.toDomain()).toList();
      return Success(lists);
    } on Failure catch (f) {
      AppLogger.w('getShoppingLists failure: ${f.message}', tag: 'ShoppingListRepository');
      return Error(f);
    } catch (e, stackTrace) {
      AppLogger.e('getShoppingLists unexpected error', error: e, stackTrace: stackTrace, tag: 'ShoppingListRepository');
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<ShoppingList>> getShoppingList(String id) async {
    AppLogger.d('getShoppingList requested for id $id', tag: 'ShoppingListRepository');
    try {
      final dto = await remoteDataSource.getShoppingList(id);
      AppLogger.i('Successfully fetched list $id', tag: 'ShoppingListRepository');
      return Success(dto.toDomain());
    } on Failure catch (f) {
      AppLogger.w('getShoppingList failure: ${f.message}', tag: 'ShoppingListRepository');
      return Error(f);
    } catch (e, stackTrace) {
      AppLogger.e('getShoppingList unexpected error', error: e, stackTrace: stackTrace, tag: 'ShoppingListRepository');
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<ShoppingList>> saveShoppingList(ShoppingList list) async {
    AppLogger.d('saveShoppingList requested for list ${list.id}', tag: 'ShoppingListRepository');
    try {
      final dto = ShoppingListDto.fromDomain(list);
      await remoteDataSource.saveShoppingList(dto);
      AppLogger.i('Successfully saved list ${list.id}', tag: 'ShoppingListRepository');
      return Success(list);
    } on Failure catch (f) {
      AppLogger.w('saveShoppingList failure: ${f.message}', tag: 'ShoppingListRepository');
      return Error(f);
    } catch (e, stackTrace) {
      AppLogger.e('saveShoppingList unexpected error', error: e, stackTrace: stackTrace, tag: 'ShoppingListRepository');
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<ShoppingList>> shareShoppingList(String listId, String email, {String? displayName}) async {
    AppLogger.d('shareShoppingList requested for list $listId with email $email (displayName: $displayName)', tag: 'ShoppingListRepository');
    try {
      final updatedDto = await remoteDataSource.shareShoppingList(listId, email, displayName: displayName);
      final domainList = updatedDto.toDomain();
      AppLogger.i('Successfully shared list $listId with $email', tag: 'ShoppingListRepository');
      return Success(domainList);
    } on Failure catch (f) {
      AppLogger.w('shareShoppingList failure: ${f.message}', tag: 'ShoppingListRepository');
      return Error(f);
    } catch (e, stackTrace) {
      AppLogger.e('shareShoppingList unexpected error', error: e, stackTrace: stackTrace, tag: 'ShoppingListRepository');
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<ShoppingList>> removeCollaborator(String listId, String email) async {
    AppLogger.d('removeCollaborator requested for list $listId with email $email', tag: 'ShoppingListRepository');
    try {
      final updatedDto = await remoteDataSource.removeCollaborator(listId, email);
      final domainList = updatedDto.toDomain();
      AppLogger.i('Successfully removed collaborator $email from list $listId', tag: 'ShoppingListRepository');
      return Success(domainList);
    } on Failure catch (f) {
      AppLogger.w('removeCollaborator failure: ${f.message}', tag: 'ShoppingListRepository');
      return Error(f);
    } catch (e, stackTrace) {
      AppLogger.e('removeCollaborator unexpected error', error: e, stackTrace: stackTrace, tag: 'ShoppingListRepository');
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteShoppingList(String id) async {
    AppLogger.d('deleteShoppingList requested for id $id', tag: 'ShoppingListRepository');
    try {
      await remoteDataSource.deleteShoppingList(id);
      AppLogger.i('Successfully deleted list $id', tag: 'ShoppingListRepository');
      return const Success(null);
    } on Failure catch (f) {
      AppLogger.w('deleteShoppingList failure: ${f.message}', tag: 'ShoppingListRepository');
      return Error(f);
    } catch (e, stackTrace) {
      AppLogger.e('deleteShoppingList unexpected error', error: e, stackTrace: stackTrace, tag: 'ShoppingListRepository');
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<ShoppingItem>> saveShoppingItem(String listId, ShoppingItem item) async {
    AppLogger.d('saveShoppingItem requested for item ${item.id} in list $listId', tag: 'ShoppingListRepository');
    try {
      // Handle local image uploads
      final updatedImageUrls = <String>[];
      for (final url in item.imageUrls) {
        if (!url.startsWith('http')) {
          final file = File(url);
          final bytes = await file.readAsBytes();
          final ext = url.split('.').last;
          final result = await storageRepository.uploadItemImage(
            listId: listId,
            itemId: item.id,
            imageBytes: bytes,
            extension: ext,
          );
          if (result is Success<String>) {
            updatedImageUrls.add(result.value);
          } else if (result is Error<String>) {
            return Error(result.failure);
          }
        } else {
          updatedImageUrls.add(url);
        }
      }

      final itemWithUpdatedImages = item.copyWith(imageUrls: updatedImageUrls);
      final dto = ShoppingItemDto.fromDomain(itemWithUpdatedImages);
      await remoteDataSource.saveShoppingItem(listId, dto);
      AppLogger.i('Successfully saved item ${item.id} in list $listId', tag: 'ShoppingListRepository');
      return Success(item);
    } on Failure catch (f) {
      AppLogger.w('saveShoppingItem failure: ${f.message}', tag: 'ShoppingListRepository');
      return Error(f);
    } catch (e, stackTrace) {
      AppLogger.e('saveShoppingItem unexpected error', error: e, stackTrace: stackTrace, tag: 'ShoppingListRepository');
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteShoppingItem(String listId, String itemId) async {
    AppLogger.d('deleteShoppingItem requested for item $itemId from list $listId', tag: 'ShoppingListRepository');
    try {
      await remoteDataSource.deleteShoppingItem(listId, itemId);
      AppLogger.i('Successfully deleted item $itemId from list $listId', tag: 'ShoppingListRepository');
      return const Success(null);
    } on Failure catch (f) {
      AppLogger.w('deleteShoppingItem failure: ${f.message}', tag: 'ShoppingListRepository');
      return Error(f);
    } catch (e, stackTrace) {
      AppLogger.e('deleteShoppingItem unexpected error', error: e, stackTrace: stackTrace, tag: 'ShoppingListRepository');
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<Result<List<ShoppingList>>> watchShoppingLists(String? userEmail) {
    AppLogger.d('watchShoppingLists requested for user $userEmail', tag: 'ShoppingListRepository');
    
    String email = userEmail ?? '';
    if (email.isEmpty) {
      try {
        email = FirebaseAuth.instance.currentUser?.email ?? 'test@shoppingexplore.com';
      } catch (_) {
        email = 'test@shoppingexplore.com';
      }
    }
    
    return remoteDataSource.watchShoppingLists(email).map<Result<List<ShoppingList>>>((dtos) {
      final lists = dtos.map((dto) => dto.toDomain()).toList();
      return Success(lists);
    }).handleError((Object e) {
      AppLogger.e('watchShoppingLists stream error', error: e, tag: 'ShoppingListRepository');
      return Error<List<ShoppingList>>(NetworkFailure(e.toString()));
    });
  }

  @override
  Stream<Result<ShoppingList>> watchShoppingList(String id) {
    AppLogger.d('watchShoppingList requested for list $id', tag: 'ShoppingListRepository');
    
    return remoteDataSource.watchShoppingList(id).map<Result<ShoppingList>>((dto) {
      if (dto == null) {
        return const Error(CacheFailure('List not found'));
      }
      return Success(dto.toDomain());
    }).handleError((Object e) {
      AppLogger.e('watchShoppingList stream error', error: e, tag: 'ShoppingListRepository');
      return Error<ShoppingList>(NetworkFailure(e.toString()));
    });
  }

  @override
  Future<Result<ShoppingList>> startShoppingSession(String listId, String userEmail, {String? locationName}) async {
    AppLogger.d('startShoppingSession requested for user $userEmail on list $listId at $locationName', tag: 'ShoppingListRepository');
    try {
      final updatedDto = await remoteDataSource.startShoppingSession(listId, userEmail, locationName: locationName);
      final domainList = updatedDto.toDomain();
      AppLogger.i('Successfully started shopping session for $userEmail on list $listId', tag: 'ShoppingListRepository');
      return Success(domainList);
    } on Failure catch (f) {
      AppLogger.w('startShoppingSession failure: ${f.message}', tag: 'ShoppingListRepository');
      return Error(f);
    } catch (e, stackTrace) {
      AppLogger.e('startShoppingSession unexpected error', error: e, stackTrace: stackTrace, tag: 'ShoppingListRepository');
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<ShoppingList>> endShoppingSession(String listId, String userEmail) async {
    AppLogger.d('endShoppingSession requested for user $userEmail on list $listId', tag: 'ShoppingListRepository');
    try {
      final updatedDto = await remoteDataSource.endShoppingSession(listId, userEmail);
      final domainList = updatedDto.toDomain();
      AppLogger.i('Successfully ended shopping session for $userEmail on list $listId', tag: 'ShoppingListRepository');
      return Success(domainList);
    } on Failure catch (f) {
      AppLogger.w('endShoppingSession failure: ${f.message}', tag: 'ShoppingListRepository');
      return Error(f);
    } catch (e, stackTrace) {
      AppLogger.e('endShoppingSession unexpected error', error: e, stackTrace: stackTrace, tag: 'ShoppingListRepository');
      return Error(CacheFailure(e.toString()));
    }
  }
}
