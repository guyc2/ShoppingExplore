import 'package:flutter/material.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/user_utils.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/entities/shopping_list.dart';
import '../controllers/shopping_list_controller.dart';
import '../controllers/shopping_list_state.dart';
import '../widgets/add_item_input.dart';
import '../widgets/active_shoppers_banner.dart';
import '../widgets/shopping_item_tile.dart';
import 'shopping_item_detail_page.dart';
import '../widgets/shopping_list_share_modal.dart';
import '../widgets/start_shopping_modal.dart';
import '../../../../core/services/image_storage_service.dart';

/// Detail view for a single shopping list. Displays the list metadata
/// header (title, description, color, icon, collaborators), the
/// interactive 2-section checklist with Active Shopping Mode,
/// and a quick-add input bar.
class ShoppingListDetailView extends StatefulWidget {
  final ShoppingListController controller;
  final String listId;
  final ImageStorageService imageStorageService;

  const ShoppingListDetailView({
    super.key,
    required this.controller,
    required this.listId,
    required this.imageStorageService,
  });

  @override
  State<ShoppingListDetailView> createState() => _ShoppingListDetailViewState();
}

class _ShoppingListDetailViewState extends State<ShoppingListDetailView> {
  @override
  void initState() {
    super.initState();
    AppLogger.i('Opening detail view for list ${widget.listId}',
        tag: 'ShoppingListDetailView');
    widget.controller.subscribeToShoppingList(widget.listId);
  }

  ShoppingList? _findList(ShoppingListState state) {
    if (state is ShoppingListLoaded) {
      try {
        return state.lists.firstWhere((l) => l.id == widget.listId);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  void _onAddItem(String title) {
    AppLogger.d('Quick-adding item "$title" to list ${widget.listId}',
        tag: 'ShoppingListDetailView');
    final now = DateTime.now();
    final item = ShoppingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: now,
      updatedAt: now,
    );
    widget.controller.addItem(widget.listId, item);
  }

  void _openEditor(BuildContext context, ShoppingItem item, [List<String> availableEmails = const []]) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ShoppingItemDetailPage(
          initialItem: item,
          listId: widget.listId,
          controller: widget.controller,
          availableEmails: availableEmails,
          imageStorageService: widget.imageStorageService,
        ),
      ),
    );
  }

  void _openShareModal(BuildContext context, ShoppingList list) {
    showDialog<void>(
      context: context,
      builder: (_) => ShoppingListShareModal(
        shoppingList: list,
        controller: widget.controller,
      ),
    );
  }

  void _removeItem(String itemId) {
    if (widget.controller.isShoppingMode(widget.listId)) {
      widget.controller.removeItemInShoppingMode(widget.listId, itemId);
    } else {
      widget.controller.deleteItem(widget.listId, itemId);
    }
    setState(() {});
  }

  void _restoreItem(String itemId) {
    widget.controller.restoreItemFromCart(widget.listId, itemId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder<ShoppingListState>(
      valueListenable: widget.controller,
      builder: (context, state, _) {
        final list = _findList(state);
        if (list == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n?.appTitle ?? 'Shopping Explore'),
            ),
            body: const Center(child: Text('List not found')),
          );
        }

        final listColor = _parseHexColor(list.colorHex) ??
            theme.colorScheme.primary;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sync_rounded, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        l10n?.liveSyncing ?? 'Live Sync',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.share, color: theme.colorScheme.primary),
                tooltip: l10n?.shareList ?? 'Share List',
                onPressed: () => _openShareModal(context, list),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: Column(
            children: [
              // List metadata header
              _buildMetadataHeader(context, list, listColor),

              // Active Shoppers banner
              ActiveShoppersBanner(
                activeSessions: list.activeSessions,
                currentUserEmail: 'guy@shoppingexplore.com',
              ),

              // Item checklist
              Expanded(
                child: list.items.isEmpty
                    ? _buildEmptyState(context)
                    : _buildItemsList(context, list),
              ),

              // Quick-add bar
              AddItemInput(
                onAdd: (title) => _onAddItem(title),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetadataHeader(
    BuildContext context,
    ShoppingList list,
    Color listColor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final completedCount = list.items.where((i) => i.isCompleted).length;
    final totalCount = list.items.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    final isShoppingMode = widget.controller.isShoppingMode(list.id);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            listColor.withValues(alpha: 0.08),
            colorScheme.surface.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top header row: Compact Start Shopping button + Short description
          if (!isShoppingMode)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ActionChip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  avatar: Icon(
                    Icons.shopping_cart_checkout,
                    size: 14,
                    color: colorScheme.primary,
                  ),
                  label: Text(
                    l10n?.startShopping ?? 'Start Shopping',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  onPressed: () {
                    StartShoppingModal.show(
                      context,
                      listTitle: list.title,
                      onStart: (locationName) {
                        widget.controller.enterShoppingMode(
                          list.id,
                          userEmail: 'guy@shoppingexplore.com',
                          locationName: locationName,
                        );
                        setState(() {});
                      },
                    );
                  },
                ),
                if (list.shortDescription != null && list.shortDescription!.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      list.shortDescription!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            )
          else ...[
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  avatar: Icon(
                    Icons.shopping_cart,
                    size: 14,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  label: Text(
                    l10n?.activeShoppingMode ?? 'Active Shopping Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 11,
                    ),
                  ),
                  backgroundColor: colorScheme.primaryContainer,
                ),
                ActionChip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  avatar: Icon(Icons.check_circle_outline, size: 14, color: colorScheme.primary),
                  label: Text(l10n?.completeShopping ?? 'Complete Shopping', style: const TextStyle(fontSize: 11)),
                  onPressed: () {
                    widget.controller.completeShoppingMode(
                      list.id,
                      userEmail: 'guy@shoppingexplore.com',
                    );
                    setState(() {});
                  },
                ),
                ActionChip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  avatar: Icon(Icons.cancel_outlined, size: 14, color: colorScheme.error),
                  label: Text(l10n?.cancelShopping ?? 'Cancel Shopping', style: const TextStyle(fontSize: 11)),
                  onPressed: () {
                    widget.controller.cancelShoppingMode(
                      list.id,
                      userEmail: 'guy@shoppingexplore.com',
                    );
                    setState(() {});
                  },
                ),
              ],
            ),
            if (list.shortDescription != null && list.shortDescription!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                list.shortDescription!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
          const SizedBox(height: 8),

          // Full description
          if (list.description != null && list.description!.isNotEmpty) ...[
            Text(
              list.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],

          // Progress row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$completedCount / $totalCount ${l10n?.completedLabel ?? 'completed'}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: listColor,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: listColor.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(listColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Collaborators
          if (list.sharedWithEmails.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                ...list.sharedWithEmails.map(
                  (email) => Chip(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                    label: Text(
                      getDisplayNameForEmail(email),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, ShoppingList list) {
    final isShoppingMode = widget.controller.isShoppingMode(list.id);
    final removedIds = widget.controller.removedCartItemIds(list.id);
    final l10n = AppLocalizations.of(context);
    final availableEmails = [
      if (list.ownerId != null) list.ownerId!,
      ...list.sharedWithEmails,
    ];

    if (!isShoppingMode) {
      final unmarkedItems = list.items.where((i) => !i.isCompleted).toList();
      final markedItems = list.items.where((i) => i.isCompleted).toList();

      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              '${l10n?.toBuySection ?? 'To Buy'} (${unmarkedItems.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          ...unmarkedItems.map(
            (item) => ShoppingItemTile(
              item: item,
              onToggle: () => widget.controller.toggleItem(list.id, item),
              onDelete: () => _removeItem(item.id),
              onTap: () => _openEditor(context, item, availableEmails),
              onUpdateQuantity: (newQty) {
                final updated = item.copyWith(quantity: newQty);
                widget.controller.updateItem(list.id, updated);
              },
            ),
          ),
          if (markedItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                '${l10n?.completedSection ?? 'Completed'} (${markedItems.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
            ),
            ...markedItems.map(
              (item) => ShoppingItemTile(
                item: item,
                onToggle: () => widget.controller.toggleItem(list.id, item),
                onDelete: () => _removeItem(item.id),
                onTap: () => _openEditor(context, item, availableEmails),
                onUpdateQuantity: (newQty) {
                  final updated = item.copyWith(quantity: newQty);
                  widget.controller.updateItem(list.id, updated);
                },
              ),
            ),
          ],
        ],
      );
    }

    final activeItems =
        list.items.where((i) => !removedIds.contains(i.id)).toList();
    final removedItems =
        list.items.where((i) => removedIds.contains(i.id)).toList();

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
            onToggle: () => widget.controller.toggleItem(list.id, item),
            onDelete: () => _removeItem(item.id),
            onTap: () => _openEditor(context, item, availableEmails),
            onUpdateQuantity: (newQty) {
              final updated = item.copyWith(quantity: newQty);
              widget.controller.updateItem(list.id, updated);
            },
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
              onDelete: () =>
                  widget.controller.deleteItem(list.id, item.id),
              onRestore: () => _restoreItem(item.id),
              onTap: () => _openEditor(context, item, availableEmails),
              onUpdateQuantity: (newQty) {
                final updated = item.copyWith(quantity: newQty);
                widget.controller.updateItem(list.id, updated);
              },
            ),
          ),
        ],
      ],
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

  static Color? _parseHexColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) {
      final value = int.tryParse('FF$cleaned', radix: 16);
      if (value != null) return Color(value);
    }
    return null;
  }
}
