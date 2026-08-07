import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shopping_explore/core/error/failure.dart';
import 'package:shopping_explore/features/auth/data/datasources/firebase_auth_remote_datasource.dart';

import 'auth_mocks.mocks.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late FirebaseAuthRemoteDataSource dataSource;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    dataSource = FirebaseAuthRemoteDataSource(firebaseAuth: mockFirebaseAuth);
  });

  group('FirebaseAuthRemoteDataSource', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tDisplayName = 'Test User';
    const tUid = 'test-uid';
    final tCreationTime = DateTime(2026, 8, 6);

    test('login returns UserDto on success', () async {
      // arrange
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();
      when(mockFirebaseAuth.signInWithEmailAndPassword(email: tEmail, password: tPassword))
          .thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);
      
      when(mockUser.uid).thenReturn(tUid);
      when(mockUser.email).thenReturn(tEmail);
      when(mockUser.displayName).thenReturn(tDisplayName);
      when(mockUser.photoURL).thenReturn(null);
      final mockMetadata = MockUserMetadata();
      when(mockUser.metadata).thenReturn(mockMetadata);
      when(mockMetadata.creationTime).thenReturn(tCreationTime);

      // act
      final result = await dataSource.login(tEmail, tPassword);

      // assert
      expect(result.id, equals(tUid));
      expect(result.email, equals(tEmail));
      expect(result.displayName, equals(tDisplayName));
      verify(mockFirebaseAuth.signInWithEmailAndPassword(email: tEmail, password: tPassword));
      verifyNoMoreInteractions(mockFirebaseAuth);
    });

    test('login throws ValidationFailure on invalid email', () async {
      // arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(email: 'bad', password: tPassword))
          .thenThrow(firebase_auth.FirebaseAuthException(code: 'invalid-email', message: 'The email address is badly formatted.'));

      // act & assert
      expect(() => dataSource.login('bad', tPassword), throwsA(isA<ValidationFailure>()));
    });

    test('register returns UserDto on success', () async {
      // arrange
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();
      
      when(mockFirebaseAuth.createUserWithEmailAndPassword(email: tEmail, password: tPassword))
          .thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.updateDisplayName(tDisplayName)).thenAnswer((_) async => {});
      when(mockUser.reload()).thenAnswer((_) async => {});
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      
      when(mockUser.uid).thenReturn(tUid);
      when(mockUser.email).thenReturn(tEmail);
      when(mockUser.displayName).thenReturn(tDisplayName);
      when(mockUser.photoURL).thenReturn(null);
      final mockMetadata = MockUserMetadata();
      when(mockUser.metadata).thenReturn(mockMetadata);
      when(mockMetadata.creationTime).thenReturn(tCreationTime);

      // act
      final result = await dataSource.register(tEmail, tPassword, tDisplayName);

      // assert
      expect(result.id, equals(tUid));
      expect(result.displayName, equals(tDisplayName));
      verify(mockFirebaseAuth.createUserWithEmailAndPassword(email: tEmail, password: tPassword));
      verify(mockUser.updateDisplayName(tDisplayName));
      verify(mockUser.reload());
    });

    test('getCurrentUser returns UserDto if user is logged in', () async {
      final mockUser = MockUser();
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(tUid);
      when(mockUser.email).thenReturn(tEmail);
      when(mockUser.displayName).thenReturn(tDisplayName);
      when(mockUser.photoURL).thenReturn(null);
      final mockMetadata = MockUserMetadata();
      when(mockUser.metadata).thenReturn(mockMetadata);
      when(mockMetadata.creationTime).thenReturn(tCreationTime);

      final result = await dataSource.getCurrentUser();

      expect(result, isNotNull);
      expect(result?.id, equals(tUid));
      verify(mockFirebaseAuth.currentUser);
    });

    test('getCurrentUser returns null if user is not logged in', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      final result = await dataSource.getCurrentUser();

      expect(result, isNull);
      verify(mockFirebaseAuth.currentUser);
    });

    test('logout calls signOut', () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async => {});

      await dataSource.logout();

      verify(mockFirebaseAuth.signOut());
    });

    test('sendPasswordResetEmail calls sendPasswordResetEmail on FirebaseAuth', () async {
      when(mockFirebaseAuth.sendPasswordResetEmail(email: tEmail)).thenAnswer((_) async => {});

      await dataSource.sendPasswordResetEmail(tEmail);

      verify(mockFirebaseAuth.sendPasswordResetEmail(email: tEmail));
    });

    test('updateProfile updates and reloads user', () async {
      final mockUser = MockUser();
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      
      when(mockUser.updateDisplayName('New Name')).thenAnswer((_) async => {});
      when(mockUser.reload()).thenAnswer((_) async => {});
      
      when(mockUser.uid).thenReturn(tUid);
      when(mockUser.email).thenReturn(tEmail);
      when(mockUser.displayName).thenReturn('New Name');
      when(mockUser.photoURL).thenReturn(null);
      final mockMetadata = MockUserMetadata();
      when(mockUser.metadata).thenReturn(mockMetadata);
      when(mockMetadata.creationTime).thenReturn(tCreationTime);

      final result = await dataSource.updateProfile('New Name', null);

      expect(result.displayName, equals('New Name'));
      verify(mockUser.updateDisplayName('New Name'));
      verify(mockUser.reload());
    });
  });
}
