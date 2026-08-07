import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_explore/core/storage/domain/repositories/storage_repository.dart';
import 'package:shopping_explore/features/auth/data/datasources/auth_remote_datasource.dart';

@GenerateMocks([
  FirebaseAuth,
  UserCredential,
  User,
  UserMetadata,
  AuthRemoteDataSource,
  StorageRepository,
  FirebaseFirestore,
])
void main() {}
