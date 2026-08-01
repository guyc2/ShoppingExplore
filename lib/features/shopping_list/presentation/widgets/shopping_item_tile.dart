import 'package:flutter/material.dart';
import '../../domain/entities/shopping_item.dart';

class ShoppingItemTile extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ShoppingItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: item.isCompleted ? 0 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: item.isCompleted
              ? colorScheme.outlineVariant
              : colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                        decoration: item.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: item.isCompleted
                            ? colorScheme.onSurface.withOpacity(0.5)
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
    final badges = <Widget>[];

    if (item.quantity != 1.0) {
      badges.add(
        _BadgePill(
          label: 'x${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)}',
          color: colorScheme.primaryContainer,
          textColor: colorScheme.onPrimaryContainer,
        ),
      );
    }

    if (item.priority != Priority.low) {
      final isHigh = item.priority == Priority.high;
      badges.add(
        _BadgePill(
          label: isHigh ? 'High Priority' : 'Medium Priority',
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
