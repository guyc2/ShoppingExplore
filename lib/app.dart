import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
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
  late final ShoppingListController _controller;

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
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShoppingExplore',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: ShoppingListView(
        controller: _controller,
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
