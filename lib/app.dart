import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shopping_explore/core/utils/logger.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/shopping_list/data/datasources/shopping_list_local_datasource.dart';
import 'features/shopping_list/data/repositories/shopping_list_repository_impl.dart';
import 'features/shopping_list/domain/usecases/create_shopping_item.dart';
import 'features/shopping_list/domain/usecases/delete_shopping_item.dart';
import 'features/shopping_list/domain/usecases/get_shopping_lists.dart';
import 'features/shopping_list/domain/usecases/toggle_item_completion.dart';
import 'features/shopping_list/domain/usecases/update_item_properties.dart';
import 'features/shopping_list/presentation/controllers/shopping_list_controller.dart';
import 'features/shopping_list/presentation/views/shopping_list_view.dart';

/// The root application widget for ShoppingExplore.
class ShoppingExploreApp extends StatefulWidget {
  const ShoppingExploreApp({super.key});

  @override
  State<ShoppingExploreApp> createState() => _ShoppingExploreAppState();
}

class _ShoppingExploreAppState extends State<ShoppingExploreApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('he', '');
  late final ShoppingListController _controller;
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    final localDataSource = InMemoryShoppingListLocalDataSource.withDefaultData();
    final repository = ShoppingListRepositoryImpl(localDataSource: localDataSource);
    _controller = ShoppingListController(
      getShoppingLists: GetShoppingLists(repository),
      createShoppingItem: CreateShoppingItem(repository),
      toggleItemCompletion: ToggleItemCompletion(repository),
      updateItemProperties: UpdateItemProperties(repository),
      deleteShoppingItem: DeleteShoppingItem(repository),
    );

    final authDataSource = InMemoryAuthDataSource(startAuthenticated: false);
    final authRepository = AuthRepositoryImpl(localDataSource: authDataSource);
    _authController = AuthController(
      loginUseCase: LoginUseCase(authRepository),
      registerUseCase: RegisterUseCase(authRepository),
      logoutUseCase: LogoutUseCase(authRepository),
      getCurrentUserUseCase: GetCurrentUserUseCase(authRepository),
    );
  }

  @override
  void dispose() {
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
      ),
    );
  }
}
