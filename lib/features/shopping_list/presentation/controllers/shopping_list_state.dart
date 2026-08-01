import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/shopping_list.dart';

abstract class ShoppingListState extends Equatable {
  const ShoppingListState();

  @override
  List<Object?> get props => [];
}

class ShoppingListInitial extends ShoppingListState {
  const ShoppingListInitial();
}

class ShoppingListLoading extends ShoppingListState {
  const ShoppingListLoading();
}

class ShoppingListLoaded extends ShoppingListState {
  final List<ShoppingList> lists;

  const ShoppingListLoaded(this.lists);

  @override
  List<Object?> get props => [lists];
}

class ShoppingListError extends ShoppingListState {
  final Failure failure;

  const ShoppingListError(this.failure);

  @override
  List<Object?> get props => [failure];
}
