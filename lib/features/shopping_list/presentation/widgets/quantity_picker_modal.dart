import 'package:flutter/material.dart';

/// Modal dialog that allows setting an item quantity via direct text entry
/// or an interactive number wheel / selector.
class QuantityPickerModal extends StatefulWidget {
  final double initialQuantity;
  final ValueChanged<double> onQuantitySelected;

  const QuantityPickerModal({
    super.key,
    required this.initialQuantity,
    required this.onQuantitySelected,
  });

  static Future<void> show(
    BuildContext context, {
    required double initialQuantity,
    required ValueChanged<double> onQuantitySelected,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => QuantityPickerModal(
        initialQuantity: initialQuantity,
        onQuantitySelected: onQuantitySelected,
      ),
    );
  }

  @override
  State<QuantityPickerModal> createState() => _QuantityPickerModalState();
}

class _QuantityPickerModalState extends State<QuantityPickerModal> {
  late TextEditingController _textController;
  late FixedExtentScrollController _wheelController;
  double _currentQuantity = 1.0;

  final List<double> _quickNumbers = List.generate(20, (i) => (i + 1).toDouble());

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.initialQuantity;
    final formatted = _formatQuantity(_currentQuantity);
    _textController = TextEditingController(text: formatted);

    final initialIndex = _quickNumbers.indexOf(_currentQuantity);
    _wheelController = FixedExtentScrollController(
      initialItem: initialIndex >= 0 ? initialIndex : 0,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _wheelController.dispose();
    super.dispose();
  }

  String _formatQuantity(double qty) {
    return qty.truncateToDouble() == qty
        ? qty.toStringAsFixed(0)
        : qty.toStringAsFixed(1);
  }

  void _updateQuantity(double newQty) {
    if (newQty <= 0) return;
    setState(() {
      _currentQuantity = newQty;
      _textController.text = _formatQuantity(newQty);
      final index = _quickNumbers.indexOf(newQty);
      if (index >= 0 && _wheelController.hasClients) {
        _wheelController.jumpToItem(index);
      }
    });
  }

  void _submit() {
    final parsed = double.tryParse(_textController.text.trim());
    final finalQty = (parsed != null && parsed > 0) ? parsed : _currentQuantity;
    widget.onQuantitySelected(finalQty);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.numbers_rounded, color: colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Set Item Quantity'),
        ],
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Direct Text Entry
            TextField(
              controller: _textController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              decoration: InputDecoration(
                labelText: 'Enter amount (by text)',
                border: const OutlineInputBorder(),
                prefixIcon: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (_currentQuantity > 1) {
                      _updateQuantity(_currentQuantity - 1);
                    }
                  },
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    _updateQuantity(_currentQuantity + 1);
                  },
                ),
              ),
              onChanged: (val) {
                final d = double.tryParse(val.trim());
                if (d != null && d > 0) {
                  _currentQuantity = d;
                }
              },
            ),
            const SizedBox(height: 16),

            // Number Wheel Picker Header
            Text(
              'Or scroll number wheel (1-20):',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),

            // Scrollable Number Wheel (ListWheelScrollView)
            SizedBox(
              height: 100,
              child: ListWheelScrollView.useDelegate(
                controller: _wheelController,
                itemExtent: 36,
                perspective: 0.005,
                diameterRatio: 1.2,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  final val = _quickNumbers[index];
                  setState(() {
                    _currentQuantity = val;
                    _textController.text = _formatQuantity(val);
                  });
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: _quickNumbers.length,
                  builder: (context, index) {
                    final numVal = _quickNumbers[index];
                    final isSelected = numVal == _currentQuantity;
                    return Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatQuantity(numVal),
                        style: TextStyle(
                          fontSize: isSelected ? 20 : 15,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
