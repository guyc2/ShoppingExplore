import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_explore/core/storage/domain/repositories/storage_repository.dart';
import 'package:shopping_explore/features/shopping_list/data/datasources/shopping_list_remote_datasource.dart';

@GenerateMocks([
  ShoppingListRemoteDataSource,
  StorageRepository,
  FirebaseFirestore,
])
void main() {}
