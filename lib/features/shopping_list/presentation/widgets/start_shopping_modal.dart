import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class StartShoppingModal extends StatefulWidget {
  final String listTitle;
  final void Function(String? locationName) onStart;

  const StartShoppingModal({
    super.key,
    required this.listTitle,
    required this.onStart,
  });

  static Future<void> show(
    BuildContext context, {
    required String listTitle,
    required void Function(String? locationName) onStart,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StartShoppingModal(
        listTitle: listTitle,
        onStart: onStart,
      ),
    );
  }

  @override
  State<StartShoppingModal> createState() => _StartShoppingModalState();
}

class _StartShoppingModalState extends State<StartShoppingModal> {
  final TextEditingController _locationController = TextEditingController();
  String? _selectedChip;

  final List<String> _quickLocations = [
    'Supermarket',
    'Grocery Store',
    'Market',
    'Pharmacy',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _submit() {
    final location = _locationController.text.trim();
    widget.onStart(location.isNotEmpty ? location : _selectedChip);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_cart_checkout_rounded,
                    color: AppColors.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHebrew ? 'התחלת קנייה' : 'Start Shopping',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.listTitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              isHebrew ? 'היכן אתה קונה? (אופציונלי)' : 'Where are you shopping? (optional)',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isHebrew
                  ? 'שותפי הרשימה יוכלו לראות היכן אתה מבצע את הקנייה בזמן אמת.'
                  : 'Collaborators will see where you are shopping in real time.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickLocations.map((loc) {
                final label = isHebrew
                    ? (loc == 'Supermarket'
                        ? 'סופרמרקט'
                        : loc == 'Grocery Store'
                            ? 'מכולת'
                            : loc == 'Market'
                                ? 'שוק'
                                : 'בית מרקחת')
                    : loc;
                final isSelected = _selectedChip == label;
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedChip = selected ? label : null;
                      if (selected) {
                        _locationController.text = label;
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: isHebrew ? 'הזן שם חנות או מיקום...' : 'Enter store name or location...',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                isHebrew ? 'התחל קנייה משותפת' : 'Start Active Shopping',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
