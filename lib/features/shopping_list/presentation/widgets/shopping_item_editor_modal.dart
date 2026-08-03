import 'package:flutter/material.dart';
import '../../domain/entities/shopping_item.dart';

class ShoppingItemEditorModal extends StatefulWidget {
  final ShoppingItem item;
  final ValueChanged<ShoppingItem> onSave;
  final List<String> availableEmails;

  const ShoppingItemEditorModal({
    super.key,
    required this.item,
    required this.onSave,
    this.availableEmails = const [],
  });

  @override
  State<ShoppingItemEditorModal> createState() =>
      _ShoppingItemEditorModalState();
}

class _ShoppingItemEditorModalState extends State<ShoppingItemEditorModal> {
  late TextEditingController _titleController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;
  late TextEditingController _linksController;
  late TextEditingController _assignedToController;
  late Priority _priority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _quantityController =
        TextEditingController(text: widget.item.quantity.toString());
    _notesController = TextEditingController(text: widget.item.notes ?? '');
    _linksController =
        TextEditingController(text: widget.item.linkUrls.join(', '));
    _assignedToController =
        TextEditingController(text: widget.item.assignedToEmail ?? '');
    _priority = widget.item.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _linksController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final quantity = double.tryParse(_quantityController.text.trim()) ?? 1.0;
    final links = _linksController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final assigned = _assignedToController.text.trim();

    final updatedItem = widget.item.copyWith(
      title: title,
      quantity: quantity,
      priority: _priority,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      linkUrls: links,
      assignedToEmail: assigned.isEmpty ? null : assigned,
    );

    widget.onSave(updatedItem);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Item Details',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<Priority>(
                    initialValue: _priority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: Priority.low,
                        child: Text('Low'),
                      ),
                      DropdownMenuItem(
                        value: Priority.medium,
                        child: Text('Medium'),
                      ),
                      DropdownMenuItem(
                        value: Priority.high,
                        child: Text('High'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _priority = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _linksController,
              decoration: const InputDecoration(
                labelText: 'URLs / Links (comma separated)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _assignedToController,
              decoration: InputDecoration(
                labelText: 'Assigned To (responsible user email)',
                prefixIcon: const Icon(Icons.person_outline),
                border: const OutlineInputBorder(),
                suffixIcon: _assignedToController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _assignedToController.clear();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (widget.availableEmails.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: widget.availableEmails.map((email) {
                  final isSelected =
                      _assignedToController.text.trim().toLowerCase() ==
                          email.toLowerCase();
                  return ChoiceChip(
                    label: Text(
                      email.contains('@') ? email.split('@')[0] : email,
                      style: const TextStyle(fontSize: 12),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _assignedToController.text = selected ? email : '';
                      });
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
