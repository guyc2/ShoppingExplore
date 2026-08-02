import 'package:flutter/material.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';
import '../../../../core/utils/logger.dart';
import 'package:shopping_explore/features/auth/presentation/controllers/auth_controller.dart';
import 'package:shopping_explore/features/auth/presentation/widgets/auth_user_button.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/entities/shopping_list.dart';
import '../controllers/shopping_list_controller.dart';
import '../controllers/shopping_list_state.dart';
import '../widgets/add_item_input.dart';
import '../widgets/shopping_item_editor_modal.dart';
import '../widgets/shopping_item_tile.dart';
import '../widgets/shopping_list_share_modal.dart';

class ShoppingListView extends StatefulWidget {
  final ShoppingListController controller;
  final AuthController? authController;
  final ThemeMode? themeMode;
  final VoidCallback? onToggleTheme;
  final Locale? currentLocale;
  final VoidCallback? onToggleLocale;

  const ShoppingListView({
    super.key,
    required this.controller,
    this.authController,
    this.themeMode,
    this.onToggleTheme,
    this.currentLocale,
    this.onToggleLocale,
  });

  @override
  State<ShoppingListView> createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<ShoppingListView> {
  @override
  void initState() {
    super.initState();
    AppLogger.i('Initializing ShoppingListView...', tag: 'ShoppingListView');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadShoppingLists();
      widget.authController?.checkAuthStatus();
    });
  }

  void _onAddItem(String listId, String title) {
    AppLogger.d('Quick-adding item "$title" to list $listId', tag: 'ShoppingListView');
    final now = DateTime.now();
    final item = ShoppingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: now,
      updatedAt: now,
    );
    widget.controller.addItem(listId, item);
  }

  void _openEditor(BuildContext context, String listId, ShoppingItem item) {
    AppLogger.d('Opening editor for item ${item.id}', tag: 'ShoppingListView');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ShoppingItemEditorModal(
        item: item,
        onSave: (updatedItem) {
          widget.controller.updateItem(listId, updatedItem);
        },
      ),
    );
  }

  void _openShareModal(BuildContext context, ShoppingList list) {
    AppLogger.d('Opening share modal for list ${list.id}', tag: 'ShoppingListView');
    showDialog<void>(
      context: context,
      builder: (_) => ShoppingListShareModal(
        shoppingList: list,
        controller: widget.controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.appTitle ?? 'Shopping Explore',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (widget.authController != null)
            AuthUserButton(authController: widget.authController!),
          if (widget.onToggleLocale != null)
            IconButton(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    widget.currentLocale?.languageCode == 'he' ? 'HE' : 'EN',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              tooltip: 'Switch Language',
              onPressed: widget.onToggleLocale,
            ),
          if (widget.onToggleTheme != null)
            IconButton(
              icon: Icon(
                widget.themeMode == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              tooltip: 'Toggle Theme',
              onPressed: widget.onToggleTheme,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: ValueListenableBuilder<ShoppingListState>(
        valueListenable: widget.controller,
        builder: (context, state, _) {
          if (state is ShoppingListLoading || state is ShoppingListInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ShoppingListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.failure.message,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => widget.controller.loadShoppingLists(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ShoppingListLoaded) {
            if (state.lists.isEmpty) {
              return const Center(child: Text('No shopping lists found.'));
            }

            final activeList = state.lists.first;
            final items = activeList.items;

            return Column(
              children: [
                _buildListHeader(context, activeList),
                Expanded(
                  child: items.isEmpty
                      ? _buildEmptyState(context)
                      : _buildItemsList(context, activeList),
                ),
                AddItemInput(
                  onAdd: (title) => _onAddItem(activeList.id, title),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _startShoppingMode(String listId) {
    widget.controller.enterShoppingMode(listId);
    setState(() {});
  }

  void _completeShoppingMode(String listId) {
    widget.controller.completeShoppingMode(listId);
    setState(() {});
  }

  void _cancelShoppingMode(String listId) {
    widget.controller.cancelShoppingMode(listId);
    setState(() {});
  }

  void _removeItem(String listId, String itemId) {
    if (widget.controller.isShoppingMode(listId)) {
      widget.controller.removeItemInShoppingMode(listId, itemId);
    } else {
      widget.controller.deleteItem(listId, itemId);
    }
    setState(() {});
  }

  void _restoreItem(String listId, String itemId) {
    widget.controller.restoreItemFromCart(listId, itemId);
    setState(() {});
  }

  Widget _buildItemsList(BuildContext context, ShoppingList activeList) {
    final isShoppingMode = widget.controller.isShoppingMode(activeList.id);
    final removedIds = widget.controller.removedCartItemIds(activeList.id);
    final l10n = AppLocalizations.of(context);

    if (!isShoppingMode) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: activeList.items.length,
        itemBuilder: (context, index) {
          final item = activeList.items[index];
          return ShoppingItemTile(
            item: item,
            onToggle: () => widget.controller.toggleItem(
              activeList.id,
              item,
            ),
            onDelete: () => _removeItem(activeList.id, item.id),
            onTap: () => _openEditor(
              context,
              activeList.id,
              item,
            ),
          );
        },
      );
    }

    final activeItems = activeList.items
        .where((i) => !removedIds.contains(i.id))
        .toList();
    final removedItems = activeList.items
        .where((i) => removedIds.contains(i.id))
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            '${l10n?.activeItemsSection ?? 'Active Items'} (${activeItems.length})',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        ...activeItems.map(
          (item) => ShoppingItemTile(
            item: item,
            onToggle: () => widget.controller.toggleItem(
              activeList.id,
              item,
            ),
            onDelete: () => _removeItem(activeList.id, item.id),
            onTap: () => _openEditor(
              context,
              activeList.id,
              item,
            ),
          ),
        ),
        if (removedItems.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              '${l10n?.removedItemsSection ?? 'In Cart / Removed Items'} (${removedItems.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
          ),
          ...removedItems.map(
            (item) => ShoppingItemTile(
              item: item,
              isRemovedInShoppingMode: true,
              onToggle: () {},
              onDelete: () => widget.controller.deleteItem(activeList.id, item.id),
              onRestore: () => _restoreItem(activeList.id, item.id),
              onTap: () => _openEditor(
                context,
                activeList.id,
                item,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildListHeader(BuildContext context, ShoppingList list) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final completedCount = list.items.where((i) => i.isCompleted).length;
    final totalCount = list.items.length;
    final isShoppingMode = widget.controller.isShoppingMode(list.id);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    list.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.share, size: 20, color: colorScheme.primary),
                    tooltip: l10n?.shareList ?? 'Share List',
                    onPressed: () => _openShareModal(context, list),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              Text(
                '$completedCount of $totalCount completed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!isShoppingMode)
            ActionChip(
              avatar: Icon(
                Icons.shopping_cart_checkout,
                size: 16,
                color: colorScheme.primary,
              ),
              label: Text(l10n?.startShopping ?? 'Start Shopping'),
              onPressed: () => _startShoppingMode(list.id),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  avatar: Icon(
                    Icons.shopping_cart,
                    size: 16,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  label: Text(
                    l10n?.activeShoppingMode ?? 'Active Shopping Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: colorScheme.primaryContainer,
                ),
                ActionChip(
                  avatar: Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  label: Text(l10n?.completeShopping ?? 'Complete Shopping'),
                  onPressed: () => _completeShoppingMode(list.id),
                ),
                ActionChip(
                  avatar: Icon(
                    Icons.cancel_outlined,
                    size: 16,
                    color: colorScheme.error,
                  ),
                  label: Text(l10n?.cancelShopping ?? 'Cancel Shopping'),
                  onPressed: () => _cancelShoppingMode(list.id),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.emptyList ?? 'Your shopping list is empty',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.addFirstItem ?? 'Add an item below to get started!',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
