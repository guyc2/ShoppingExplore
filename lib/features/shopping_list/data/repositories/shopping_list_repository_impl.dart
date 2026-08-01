import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
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
    try {
      final dtos = await localDataSource.getShoppingLists();
      final lists = dtos.map((dto) => dto.toDomain()).toList();
      return Success(lists);
    } on Failure catch (f) {
      return Error(f);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<ShoppingList>> getShoppingList(String id) async {
    try {
      final dto = await localDataSource.getShoppingList(id);
      return Success(dto.toDomain());
    } on Failure catch (f) {
      return Error(f);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> saveShoppingList(ShoppingList list) async {
    try {
      final dto = ShoppingListDto.fromDomain(list);
      await localDataSource.saveShoppingList(dto);
      return const Success(null);
    } on Failure catch (f) {
      return Error(f);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteShoppingList(String id) async {
    try {
      await localDataSource.deleteShoppingList(id);
      return const Success(null);
    } on Failure catch (f) {
      return Error(f);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<ShoppingItem>> saveShoppingItem(String listId, ShoppingItem item) async {
    try {
      final dto = ShoppingItemDto.fromDomain(item);
      await localDataSource.saveShoppingItem(listId, dto);
      return Success(item);
    } on Failure catch (f) {
      return Error(f);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteShoppingItem(String listId, String itemId) async {
    try {
      await localDataSource.deleteShoppingItem(listId, itemId);
      return const Success(null);
    } on Failure catch (f) {
      return Error(f);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }
}
