import 'package:flutter/material.dart';
import '../../domain/entities/shopping_list.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';

/// A stylish card widget for displaying a shopping list summary on the
/// multi-list dashboard. Shows category icon, title, short description,
/// completion progress bar, and collaborator avatar pills.
class ShoppingListCard extends StatelessWidget {
  final ShoppingList shoppingList;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ShoppingListCard({
    super.key,
    required this.shoppingList,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final completedCount = shoppingList.items
        .where((i) => i.isCompleted)
        .length;
    final totalCount = shoppingList.items.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    final listColor = _parseHexColor(shoppingList.colorHex) ?? colorScheme.primary;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: title/description + 3-dot menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shoppingList.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (shoppingList.shortDescription != null &&
                            shoppingList.shortDescription!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            shoppingList.shortDescription!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                          Icons.more_vert,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            onEdit?.call();
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(context);
                          }
                        },
                        itemBuilder: (context) => [
                          if (onEdit != null)
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 20, color: colorScheme.onSurface),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      l10n?.editListInfo ?? 'Edit List Information',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (onDelete != null)
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 20, color: colorScheme.error),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      l10n?.deleteList ?? 'Delete List',
                                      style: TextStyle(color: colorScheme.error),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),

              const Spacer(),

              // Bottom row: small category icon (left) + progress bar (right)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Small icon badge — bottom-left
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: listColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(shoppingList.imageUrl),
                      color: listColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Progress section fills the rest
                  Expanded(
                    child: _buildProgressSection(
                      context,
                      progress,
                      completedCount,
                      totalCount,
                      listColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Collaborator pills
              _buildCollaboratorRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    double progress,
    int completed,
    int total,
    Color listColor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completed / $total',
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
    );
  }

  Widget _buildCollaboratorRow(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final allEmails = <String>[
      if (shoppingList.ownerId != null) shoppingList.ownerId!,
      ...shoppingList.sharedWithEmails,
    ];

    if (allEmails.isEmpty) return const SizedBox.shrink();

    final displayCount = allEmails.length > 3 ? 3 : allEmails.length;
    final overflow = allEmails.length - displayCount;

    return Row(
      children: [
        // Stacked avatar circles
        SizedBox(
          width: displayCount * 22.0 + 4,
          height: 26,
          child: Stack(
            children: List.generate(displayCount, (i) {
              final initial = allEmails[i].isNotEmpty
                  ? allEmails[i][0].toUpperCase()
                  : '?';
              return Positioned(
                left: i * 18.0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _avatarColor(i, colorScheme),
                    border: Border.all(
                      color: colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        if (overflow > 0)
          Text(
            '+$overflow',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Color _avatarColor(int index, ColorScheme colorScheme) {
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
    ];
    return colors[index % colors.length];
  }

  void _showDeleteConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.deleteList ?? 'Delete List'),
        content: Text(l10n?.deleteListConfirm ?? 'Are you sure you want to delete this list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onDelete?.call();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n?.deleteList ?? 'Delete'),
          ),
        ],
      ),
    );
  }

  static IconData _getCategoryIcon(String? imageUrl) {
    switch (imageUrl) {
      case 'grocery':
        return Icons.local_grocery_store_rounded;
      case 'tech':
        return Icons.devices_rounded;
      case 'party':
        return Icons.celebration_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'health':
        return Icons.health_and_safety_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
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
