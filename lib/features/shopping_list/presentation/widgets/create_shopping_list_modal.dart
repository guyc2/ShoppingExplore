import 'package:flutter/material.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';
import '../../../../core/utils/logger.dart';

/// A modal dialog for creating a new shopping list. Captures the
/// title, optional short description, optional color selection,
/// and a category icon selector.
class CreateShoppingListModal extends StatefulWidget {
  final void Function(String title, String? shortDescription, String? colorHex, String? imageUrl) onCreate;

  const CreateShoppingListModal({super.key, required this.onCreate});

  @override
  State<CreateShoppingListModal> createState() => _CreateShoppingListModalState();
}

class _CreateShoppingListModalState extends State<CreateShoppingListModal> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedColor = '#6366F1';
  String _selectedIcon = 'grocery';

  static const _colorOptions = [
    '#4CAF50', // Green
    '#2196F3', // Blue
    '#FF5722', // Deep Orange
    '#6366F1', // Indigo (brand)
    '#F59E0B', // Amber
    '#EC4899', // Pink
    '#8B5CF6', // Violet
    '#10B981', // Emerald
  ];

  static const _iconOptions = {
    'grocery': Icons.local_grocery_store_rounded,
    'tech': Icons.devices_rounded,
    'party': Icons.celebration_rounded,
    'home': Icons.home_rounded,
    'health': Icons.health_and_safety_rounded,
    'work': Icons.work_rounded,
    'gift': Icons.card_giftcard_rounded,
    'other': Icons.shopping_bag_rounded,
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.2),
              colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add_shopping_cart,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n?.newShoppingList ?? 'New Shopping List',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title field
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n?.titleLabel ?? 'Title',
                hintText: l10n?.newListTitleHint ?? 'e.g., Birthday Party Supplies',
                prefixIcon: const Icon(Icons.edit_outlined, size: 20),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),

            // Short description field
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: l10n?.shortDescriptionLabel ?? 'Short Description',
                hintText: l10n?.newListDescHint ?? 'Optional brief description',
                prefixIcon: const Icon(Icons.notes_rounded, size: 20),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Category icon selector
            Text(
              l10n?.categoryLabel ?? 'Category',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _iconOptions.entries.map((entry) {
                final isSelected = _selectedIcon == entry.key;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.15)
                          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? Border.all(color: colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: Icon(
                      entry.value,
                      size: 20,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Color selector
            Text(
              l10n?.colorLabel ?? 'Color',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorOptions.map((hex) {
                final color = _parseHex(hex);
                final isSelected = _selectedColor == hex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: colorScheme.onSurface,
                              width: 3,
                            )
                          : Border.all(
                              color: color.withValues(alpha: 0.5),
                              width: 1,
                            ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 16,
                            color: colorScheme.onPrimary,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Create button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _handleCreate,
                icon: const Icon(Icons.add_shopping_cart, size: 20),
                label: Text(l10n?.createList ?? 'Create List'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCreate() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    AppLogger.i('Creating new shopping list: "$title"',
        tag: 'CreateShoppingListModal');

    widget.onCreate(
      title,
      _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : null,
      _selectedColor,
      _selectedIcon,
    );
    Navigator.of(context).pop();
  }

  static Color _parseHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}
