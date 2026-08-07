import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shopping_explore/core/utils/logger.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/auth/data/datasources/firebase_auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_explore/core/storage/data/repositories/storage_repository_impl.dart';
import 'package:shopping_explore/core/storage/data/datasources/firebase_storage_datasource.dart';
import 'package:shopping_explore/core/storage/domain/repositories/storage_repository.dart';
import 'features/shopping_list/data/datasources/shopping_list_remote_datasource.dart';
import 'features/shopping_list/data/datasources/firestore_shopping_list_remote_datasource.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/restore_persistent_session_usecase.dart';
import 'features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'features/auth/domain/usecases/update_user_profile_usecase.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/shopping_list/data/repositories/shopping_list_repository_impl.dart';
import 'features/shopping_list/domain/usecases/create_shopping_item.dart';
import 'features/shopping_list/domain/usecases/create_shopping_list.dart';
import 'features/shopping_list/domain/usecases/delete_shopping_item.dart';
import 'features/shopping_list/domain/usecases/delete_shopping_list.dart';
import 'features/shopping_list/domain/usecases/get_shopping_lists.dart';
import 'features/shopping_list/domain/usecases/share_shopping_list.dart';
import 'features/shopping_list/domain/usecases/toggle_item_completion.dart';
import 'features/shopping_list/domain/usecases/update_item_properties.dart';
import 'features/shopping_list/domain/usecases/update_shopping_list.dart';
import 'features/shopping_list/domain/usecases/watch_shopping_list.dart';
import 'features/shopping_list/domain/usecases/watch_shopping_lists.dart';
import 'features/shopping_list/domain/usecases/start_shopping_session.dart';
import 'features/shopping_list/domain/usecases/end_shopping_session.dart';
import 'features/shopping_list/presentation/controllers/shopping_list_controller.dart';
import 'features/shopping_list/presentation/views/shopping_list_view.dart';
import 'core/services/local_image_storage_service_impl.dart';
import 'core/services/image_storage_service.dart';

/// The root application widget for ShoppingExplore.
class ShoppingExploreApp extends StatefulWidget {
  final FirebaseAuth? firebaseAuthOverride;
  final FirebaseFirestore? firestoreOverride;
  final StorageRepository? storageRepositoryOverride;
  final ShoppingListRemoteDataSource? shoppingListRemoteDataSourceOverride;

  const ShoppingExploreApp({
    super.key,
    this.firebaseAuthOverride,
    this.firestoreOverride,
    this.storageRepositoryOverride,
    this.shoppingListRemoteDataSourceOverride,
  });

  @override
  State<ShoppingExploreApp> createState() => _ShoppingExploreAppState();
}

class _ShoppingExploreAppState extends State<ShoppingExploreApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('he', '');
  late final ShoppingListController _controller;
  late final AuthController _authController;
  late final ImageStorageService _imageStorageService;

  @override
  void initState() {
    super.initState();
    AppLogger.i('Initializing ShoppingExploreApp state', tag: 'App');
    _imageStorageService = LocalImageStorageServiceImpl();
    final storageRepository = widget.storageRepositoryOverride ?? StorageRepositoryImpl(
      remoteDataSource: FirebaseStorageDataSource(),
    );
    final dataSource = widget.shoppingListRemoteDataSourceOverride ?? FirestoreShoppingListRemoteDataSource(
      firestore: widget.firestoreOverride ?? FirebaseFirestore.instance,
    );
    final repository = ShoppingListRepositoryImpl(
      remoteDataSource: dataSource,
      storageRepository: storageRepository,
    );

    _controller = ShoppingListController(
      getShoppingLists: GetShoppingLists(repository),
      createShoppingItem: CreateShoppingItem(repository),
      toggleItemCompletion: ToggleItemCompletion(repository),
      updateItemProperties: UpdateItemProperties(repository),
      deleteShoppingItem: DeleteShoppingItem(repository),
      shareShoppingList: ShareShoppingList(repository),
      createShoppingList: CreateShoppingList(repository),
      updateShoppingList: UpdateShoppingList(repository),
      deleteShoppingList: DeleteShoppingList(repository),
      watchShoppingLists: WatchShoppingLists(repository),
      watchShoppingList: WatchShoppingList(repository),
      startShoppingSessionUseCase: StartShoppingSession(repository),
      endShoppingSessionUseCase: EndShoppingSession(repository),
    );

    final authDataSource = FirebaseAuthRemoteDataSource(
      firebaseAuth: widget.firebaseAuthOverride ?? FirebaseAuth.instance,
    );
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authDataSource,
      storageRepository: storageRepository,
      firestore: widget.firestoreOverride ?? FirebaseFirestore.instance,
    );
    _authController = AuthController(
      loginUseCase: LoginUseCase(authRepository),
      registerUseCase: RegisterUseCase(authRepository),
      logoutUseCase: LogoutUseCase(authRepository),
      getCurrentUserUseCase: GetCurrentUserUseCase(authRepository),
      updateUserProfileUseCase: UpdateUserProfileUseCase(authRepository),
      restorePersistentSessionUseCase: RestorePersistentSessionUseCase(authRepository),
      signInWithGoogleUseCase: SignInWithGoogleUseCase(authRepository),
    );

    _authController.addListener(_onAuthStateChanged);
    _onAuthStateChanged();
  }

  void _onAuthStateChanged() {
    final state = _authController.state;
    if (state is Authenticated) {
      _controller.subscribeToShoppingLists(state.user.email);
      _controller.loadShoppingLists();
    } else if (state is Unauthenticated) {
      _controller.subscribeToShoppingLists(null);
      _controller.loadShoppingLists();
    }
  }

  @override
  void dispose() {
    _authController.removeListener(_onAuthStateChanged);
    _authController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  void _toggleLocale() {
    setState(() {
      _locale = _locale.languageCode == 'he'
          ? const Locale('en', '')
          : const Locale('he', '');
    });
    AppLogger.i('Switching locale to: $_locale', tag: 'ShoppingExploreApp');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShoppingExplore',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      locale: _locale,
      supportedLocales: const [
        Locale('he', ''),
        Locale('en', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: ShoppingListView(
        controller: _controller,
        authController: _authController,
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
        currentLocale: _locale,
        onToggleLocale: _toggleLocale,
        imageStorageService: _imageStorageService,
      ),
    );
  }
}
