import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';
import 'package:shopping_explore/features/shopping_list/data/datasources/shopping_list_remote_datasource.dart';
import 'package:shopping_explore/core/storage/domain/repositories/storage_repository.dart';
import 'package:shopping_explore/features/shopping_list/data/repositories/shopping_list_repository_impl.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/create_shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/create_shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/delete_shopping_item.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/delete_shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/get_shopping_lists.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/toggle_item_completion.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/update_item_properties.dart';
import 'package:shopping_explore/features/shopping_list/domain/usecases/update_shopping_list.dart';
import 'package:shopping_explore/features/shopping_list/presentation/controllers/shopping_list_controller.dart';
import 'package:shopping_explore/features/shopping_list/presentation/views/shopping_list_view.dart';
import 'package:shopping_explore/core/services/image_storage_service.dart';
import 'package:shopping_explore/core/error/result.dart';

class FakeStorageRepository extends Fake implements StorageRepository {}

class FakeImageStorageService implements ImageStorageService {
  @override
  Future<Result<String?>> pickAndCompressImage(ImagePickerSource source) async {
    return const Success(null);
  }
}

void main() {
  group('ShoppingListView Dashboard Test', () {
    late InMemoryShoppingListRemoteDataSource localDataSource;
    late ShoppingListRepositoryImpl repository;
    late ShoppingListController controller;

    setUp(() {
      localDataSource = InMemoryShoppingListRemoteDataSource.withDefaultData();
      repository = ShoppingListRepositoryImpl(remoteDataSource: localDataSource,
        storageRepository: FakeStorageRepository());
      controller = ShoppingListController(
        getShoppingLists: GetShoppingLists(repository),
        createShoppingItem: CreateShoppingItem(repository),
        toggleItemCompletion: ToggleItemCompletion(repository),
        updateItemProperties: UpdateItemProperties(repository),
        deleteShoppingItem: DeleteShoppingItem(repository),
        createShoppingList: CreateShoppingList(repository),
        updateShoppingList: UpdateShoppingList(repository),
        deleteShoppingList: DeleteShoppingList(repository),
      );
    });

    testWidgets('renders multi-list dashboard with all 3 seeded lists', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ShoppingListView(
            controller: controller,
            imageStorageService: FakeImageStorageService(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all 3 seeded lists appear as cards
      expect(find.text('Weekly Groceries'), findsOneWidget);
      expect(find.text('Tech & Electronics Wishlist'), findsOneWidget);
      expect(find.text('Weekend BBQ Party'), findsOneWidget);
    });

    testWidgets('displays shopping cart brand icon in AppBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ShoppingListView(
            controller: controller,
            imageStorageService: FakeImageStorageService(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify shopping cart brand icon is present
      expect(find.byIcon(Icons.shopping_cart_checkout_rounded), findsOneWidget);
    });

    testWidgets('tapping a list card navigates to detail view with items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ShoppingListView(
            controller: controller,
            imageStorageService: FakeImageStorageService(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the Weekly Groceries card
      await tester.tap(find.text('Weekly Groceries'));
      await tester.pumpAndSettle();

      // Verify we're on the detail view with items
      expect(find.text('Organic Honeycrisp Apples'), findsOneWidget);
      expect(find.text('Almond Milk (Unsweetened)'), findsOneWidget);
      expect(find.text('Start Shopping'), findsOneWidget);
    });

    testWidgets('detail view supports entering Shopping Mode and canceling to restore items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ShoppingListView(
            controller: controller,
            imageStorageService: FakeImageStorageService(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Weekly Groceries detail
      await tester.tap(find.text('Weekly Groceries'));
      await tester.pumpAndSettle();

      // Enter shopping mode via StartShoppingModal
      await tester.tap(find.text('Start Shopping'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start Active Shopping'));
      await tester.pumpAndSettle();

      expect(find.text('Active Shopping Mode'), findsOneWidget);
      expect(find.text('Active Items (2)'), findsOneWidget);

      // Remove first item in shopping mode
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      expect(find.text('Active Items (1)'), findsOneWidget);
      expect(find.text('In Cart / Removed Items (1)'), findsOneWidget);

      // Cancel shopping mode -> restores items
      await tester.tap(find.text('Cancel Shopping'));
      await tester.pumpAndSettle();

      expect(find.text('Active Shopping Mode'), findsNothing);
      expect(find.text('Organic Honeycrisp Apples'), findsOneWidget);
    });
  });
}
