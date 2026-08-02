import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/entities/shopping_list.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import '../datasources/shopping_list_local_datasource.dart';
import '../models/shopping_item_dto.dart';
import '../models/shopping_list_dto.dart';

class ShoppingListRepositoryImpl implements ShoppingListRepository {
  final ShoppingListLocalDataSource localDataSource;

  ShoppingListRepositoryImpl({required this.localDataSource});

  @override
  Future<Result<List<ShoppingList>>> getShoppingLists() async {
    AppLogger.d('getShoppingLists requested', tag: 'ShoppingListRepository');
    try {
      final dtos = await localDataSource.getShoppingLists();
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
      final dto = await localDataSource.getShoppingList(id);
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
      await localDataSource.saveShoppingList(dto);
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
  Future<Result<ShoppingList>> shareShoppingList(String listId, String email) async {
    AppLogger.d('shareShoppingList requested for list $listId with email $email', tag: 'ShoppingListRepository');
    try {
      final updatedDto = await localDataSource.shareShoppingList(listId, email);
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
  Future<Result<void>> deleteShoppingList(String id) async {
    AppLogger.d('deleteShoppingList requested for id $id', tag: 'ShoppingListRepository');
    try {
      await localDataSource.deleteShoppingList(id);
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
      final dto = ShoppingItemDto.fromDomain(item);
      await localDataSource.saveShoppingItem(listId, dto);
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
      await localDataSource.deleteShoppingItem(listId, itemId);
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
}
