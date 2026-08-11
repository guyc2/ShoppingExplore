import 'package:flutter/material.dart';
import 'package:shopping_explore/core/utils/user_utils.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';
import '../../domain/entities/shopping_item.dart';
import 'quantity_picker_modal.dart';

class ShoppingItemTile extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final bool isRemovedInShoppingMode;
  final VoidCallback? onRestore;
  final ValueChanged<double>? onUpdateQuantity;

  const ShoppingItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
    this.isRemovedInShoppingMode = false,
    this.onRestore,
    this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: (item.isCompleted || isRemovedInShoppingMode) ? 0 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: (item.isCompleted || isRemovedInShoppingMode)
              ? colorScheme.outlineVariant
              : colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isRemovedInShoppingMode)
                Icon(
                  Icons.shopping_cart_checkout,
                  color: colorScheme.primary,
                )
              else
                Checkbox(
                  value: item.isCompleted,
                  onChanged: (_) => onToggle(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: (item.isCompleted || isRemovedInShoppingMode)
                            ? TextDecoration.lineThrough
                            : null,
                        color: (item.isCompleted || isRemovedInShoppingMode)
                            ? colorScheme.onSurface.withValues(alpha: 0.5)
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildBadges(context),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onUpdateQuantity != null
                    ? () {
                        QuantityPickerModal.show(
                          context,
                          initialQuantity: item.quantity,
                          onQuantitySelected: onUpdateQuantity!,
                        );
                      }
                    : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.unfold_more,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              if (isRemovedInShoppingMode && onRestore != null)
                IconButton(
                  icon: Icon(
                    Icons.restore,
                    color: colorScheme.primary,
                  ),
                  onPressed: onRestore,
                  tooltip: 'Restore Item',
                )
              else
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: colorScheme.error,
                  ),
                  onPressed: onDelete,
                  tooltip: 'Delete Item',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadges(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final badges = <Widget>[];

    if (item.assignedToEmail != null && item.assignedToEmail!.isNotEmpty) {
      badges.add(
        _BadgePill(
          label: getDisplayNameForEmail(item.assignedToEmail),
          color: colorScheme.secondaryContainer,
          textColor: colorScheme.onSecondaryContainer,
        ),
      );
    }

    if (item.priority != Priority.low) {
      final isHigh = item.priority == Priority.high;
      final priorityText = isHigh
          ? (l10n?.priorityHigh ?? 'High')
          : (l10n?.priorityMedium ?? 'Medium');
      badges.add(
        _BadgePill(
          label: priorityText,
          color: isHigh ? colorScheme.errorContainer : colorScheme.tertiaryContainer,
          textColor: isHigh ? colorScheme.onErrorContainer : colorScheme.onTertiaryContainer,
        ),
      );
    }

    if (item.notes != null && item.notes!.isNotEmpty) {
      badges.add(
        Icon(
          Icons.note_alt_outlined,
          size: 16,
          color: colorScheme.secondary,
        ),
      );
    }

    if (item.imageUrls.isNotEmpty) {
      badges.add(
        Icon(
          Icons.image_outlined,
          size: 16,
          color: colorScheme.secondary,
        ),
      );
    }

    if (item.linkUrls.isNotEmpty) {
      badges.add(
        Icon(
          Icons.link_outlined,
          size: 16,
          color: colorScheme.secondary,
        ),
      );
    }

    if (item.attributes.isNotEmpty) {
      badges.add(
        _BadgePill(
          label: '${item.attributes.length} attrs',
          color: colorScheme.secondaryContainer,
          textColor: colorScheme.onSecondaryContainer,
        ),
      );
    }

    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: badges,
    );
  }
}

class _BadgePill extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _BadgePill({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
