import 'package:flutter/material.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/entities/product_suggestion.dart';
import '../controllers/shopping_list_controller.dart';
import '../widgets/shopping_item_editor_modal.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';
import '../widgets/product_suggestion_card.dart';
import '../widgets/add_suggestion_modal.dart';
import '../../../../core/services/image_storage_service.dart';
import '../../../../core/utils/user_utils.dart';

class ShoppingItemDetailPage extends StatefulWidget {
  final ShoppingItem initialItem;
  final String listId;
  final ShoppingListController controller;
  final List<String> availableEmails;
  final ImageStorageService imageStorageService;

  const ShoppingItemDetailPage({
    super.key,
    required this.initialItem,
    required this.listId,
    required this.controller,
    required this.availableEmails,
    required this.imageStorageService,
  });

  @override
  State<ShoppingItemDetailPage> createState() => _ShoppingItemDetailPageState();
}

class _ShoppingItemDetailPageState extends State<ShoppingItemDetailPage> {
  late ShoppingItem item;

  @override
  void initState() {
    super.initState();
    item = widget.initialItem;
    AppLogger.i('Viewing item details for ${item.id}', tag: 'ShoppingItemDetail');
    widget.controller.addListener(_onControllerUpdated);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdated);
    super.dispose();
  }

  void _onControllerUpdated() {
    final list = widget.controller.getList(widget.listId);
    if (list != null) {
      final updatedItem = list.items.cast<ShoppingItem?>().firstWhere(
            (i) => i?.id == item.id,
            orElse: () => null,
          );
      if (updatedItem == null) {
        AppLogger.w('Item ${item.id} was deleted externally. Closing details view.', tag: 'ShoppingItemDetail');
        if (mounted) Navigator.of(context).pop();
        return;
      }
      if (updatedItem != item) {
        setState(() {
          item = updatedItem;
        });
      }
    }
  }

  void _openEditor() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ShoppingItemEditorModal(
        item: item,
        availableEmails: widget.availableEmails,
        onSave: (updated) {
          widget.controller.updateItem(widget.listId, updated);
        },
      ),
    );
  }

  void _openAddSuggestionModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddSuggestionModal(
        imageStorageService: widget.imageStorageService,
        onSave: (suggestion) {
          final updatedSuggestions = List<ProductSuggestion>.from(item.suggestions)..add(suggestion);
          final updatedItem = item.copyWith(suggestions: updatedSuggestions);
          widget.controller.updateItem(widget.listId, updatedItem);
        },
      ),
    );
  }

  void _deleteSuggestion(String suggestionId) {
    final updatedSuggestions = item.suggestions.where((s) => s.id != suggestionId).toList();
    final updatedItem = item.copyWith(suggestions: updatedSuggestions);
    widget.controller.updateItem(widget.listId, updatedItem);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.itemDetails ?? 'Item Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _openEditor,
            tooltip: l10n?.editItem ?? 'Edit Item',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSuggestionModal,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: Text(l10n?.addSuggestion ?? 'Add Suggestion'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildItemHeader(context, theme, l10n),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                '${l10n?.suggestions ?? 'Suggestions'} (${item.suggestions.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          if (item.suggestions.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptySuggestions(context, theme, l10n),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final suggestion = item.suggestions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ProductSuggestionCard(
                      suggestion: suggestion,
                      onEdit: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (context) => AddSuggestionModal(
                            imageStorageService: widget.imageStorageService,
                            initialSuggestion: suggestion,
                            onSave: (updatedSuggestion) {
                              final updatedSuggestions = List<ProductSuggestion>.from(item.suggestions);
                              final idx = updatedSuggestions.indexWhere((x) => x.id == updatedSuggestion.id);
                              if (idx >= 0) {
                                updatedSuggestions[idx] = updatedSuggestion;
                              }
                              widget.controller.updateItem(widget.listId, item.copyWith(suggestions: updatedSuggestions));
                            },
                          ),
                        );
                      },
                      onDelete: () => _deleteSuggestion(suggestion.id),
                    ),
                  );
                },
                childCount: item.suggestions.length,
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80), // Space for FAB
          ),
        ],
      ),
    );
  }

  Widget _buildItemHeader(BuildContext context, ThemeData theme, AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              if (item.quantity != 1.0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'x${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)}${item.unit != null ? ' ${item.unit}' : ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              item.notes!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (item.assignedToEmail != null && item.assignedToEmail!.isNotEmpty)
                Chip(
                  avatar: const Icon(Icons.person_outline, size: 18),
                  label: Text(getDisplayNameForEmail(item.assignedToEmail)),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  labelStyle: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                ),
              if (item.priority != Priority.low)
                Chip(
                  avatar: const Icon(Icons.flag_outlined, size: 18),
                  label: Text(item.priority.name.toUpperCase()),
                  backgroundColor: item.priority == Priority.high
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.tertiaryContainer,
                  labelStyle: TextStyle(
                    color: item.priority == Priority.high
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onTertiaryContainer,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySuggestions(BuildContext context, ThemeData theme, AppLocalizations? l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lightbulb_outline, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            l10n?.noSuggestionsYet ?? 'No suggestions yet',
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.addSuggestionToHelp ?? 'Add a suggestion to help others know exactly what to buy.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
