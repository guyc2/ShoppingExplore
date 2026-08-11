import 'package:flutter/material.dart';
import '../../../../core/utils/user_utils.dart';
import '../../domain/entities/shopping_list.dart';
import '../controllers/shopping_list_controller.dart';

class ShoppingListShareModal extends StatefulWidget {
  final ShoppingList shoppingList;
  final ShoppingListController controller;

  const ShoppingListShareModal({
    super.key,
    required this.shoppingList,
    required this.controller,
  });

  @override
  State<ShoppingListShareModal> createState() => _ShoppingListShareModalState();
}

class _ShoppingListShareModalState extends State<ShoppingListShareModal> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  String? _errorMessage;
  bool _isSharing = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final email = _emailController.text.trim();
    final displayName = _nameController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }
    setState(() {
      _errorMessage = null;
      _isSharing = true;
    });

    final success = await widget.controller.shareList(
      widget.shoppingList.id,
      email,
      displayName: displayName.isNotEmpty ? displayName : null,
    );

    if (mounted) {
      setState(() => _isSharing = false);
      if (success) {
        _emailController.clear();
        _nameController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('List shared with $email')),
        );
      } else {
        setState(() => _errorMessage = 'Failed to share list');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final list = widget.shoppingList;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Share "${list.title}"',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (list.ownerId != null) ...[
                Text(
                  'Owner: ${getDisplayNameForEmail(list.ownerId, list: list)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                'Shared With:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (list.sharedWithEmails.isEmpty)
                Text(
                  'Not shared with anyone yet.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: list.sharedWithEmails
                      .map(
                        (email) {
                          final name = getDisplayNameForEmail(email, list: list);
                          return Chip(
                            avatar: CircleAvatar(
                              backgroundColor: colorScheme.primary,
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'C',
                                style: TextStyle(color: colorScheme.onPrimary, fontSize: 11),
                              ),
                            ),
                            label: Text(name),
                            backgroundColor: colorScheme.surfaceContainerHighest,
                          );
                        },
                      )
                      .toList(),
                ),
              const SizedBox(height: 20),
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: TextStyle(color: colorScheme.error, fontSize: 13),
                ),
                const SizedBox(height: 8),
              ],
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Add collaborator email *',
                  hintText: 'friend@shoppingexplore.com',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Display name (optional)',
                        hintText: 'e.g. Taylor',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _isSharing ? null : _share,
                    icon: _isSharing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.person_add, size: 18),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
