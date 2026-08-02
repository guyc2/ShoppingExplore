import 'package:flutter/material.dart';
import '../../domain/entities/shopping_list.dart';

/// A stylish card widget for displaying a shopping list summary on the
/// multi-list dashboard. Shows category icon, title, short description,
/// completion progress bar, and collaborator avatar pills.
class ShoppingListCard extends StatelessWidget {
  final ShoppingList shoppingList;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ShoppingListCard({
    super.key,
    required this.shoppingList,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final completedCount = shoppingList.items
        .where((i) => i.isCompleted)
        .length;
    final totalCount = shoppingList.items.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    final listColor = _parseHexColor(shoppingList.colorHex) ?? colorScheme.primary;

    return Card(
      elevation: 3,
      shadowColor: listColor.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: listColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                listColor.withValues(alpha: 0.06),
                colorScheme.surface,
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: icon badge + delete
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryIcon(listColor, colorScheme),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shoppingList.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
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
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => _showDeleteConfirmation(context),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                    ),
                ],
              ),

              const Spacer(),

              // Progress bar
              _buildProgressSection(
                context,
                progress,
                completedCount,
                totalCount,
                listColor,
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

  Widget _buildCategoryIcon(Color listColor, ColorScheme colorScheme) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: listColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getCategoryIcon(shoppingList.imageUrl),
        color: listColor,
        size: 22,
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
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete List?'),
        content: Text('Are you sure you want to delete "${shoppingList.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onDelete?.call();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
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
