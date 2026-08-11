import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/image_storage_service.dart';
import '../../domain/entities/product_suggestion.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';

class AddSuggestionModal extends StatefulWidget {
  final ProductSuggestion? initialSuggestion;
  final void Function(ProductSuggestion) onSave;
  final ImageStorageService imageStorageService;

  const AddSuggestionModal({
    super.key,
    this.initialSuggestion,
    required this.onSave,
    required this.imageStorageService,
  });

  @override
  State<AddSuggestionModal> createState() => _AddSuggestionModalState();
}

class _AddSuggestionModalState extends State<AddSuggestionModal> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _prosController = TextEditingController();
  final _consController = TextEditingController();
  final _storeController = TextEditingController();
  final _urlController = TextEditingController();
  final _priceController = TextEditingController();
  
  final _descriptionFocusNode = FocusNode();
  late final String _suggestionId;
  late final ImageStorageService _storageService;
  bool _isPickingImage = false;
  String _currency = '₪';

  @override
  void initState() {
    super.initState();
    _storageService = widget.imageStorageService;
    _suggestionId = widget.initialSuggestion?.id ?? const Uuid().v4();
    _descriptionFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

    if (widget.initialSuggestion != null) {
      final s = widget.initialSuggestion!;
      _nameController.text = s.name;
      _descriptionController.text = s.description ?? '';
      _imageUrlController.text = s.imageUrl ?? '';
      _prosController.text = s.pros.join(', ');
      _consController.text = s.cons.join(', ');
      _storeController.text = s.purchaseLocation ?? '';
      _urlController.text = s.purchaseUrl ?? '';
      if (s.price != null) {
        _priceController.text = s.price.toString();
      }
      if (s.currency != null) {
        _currency = s.currency!;
      }
    }
  }

  @override
  void dispose() {
    _descriptionFocusNode.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _prosController.dispose();
    _consController.dispose();
    _storeController.dispose();
    _urlController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _autoSave() {
    try {
      final name = _nameController.text.trim();
      if (name.isEmpty) return;

      final pros = _prosController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      
      final cons = _consController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final suggestion = ProductSuggestion(
        id: _suggestionId,
        name: name,
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        pros: pros,
        cons: cons,
        purchaseLocation: _storeController.text.trim().isEmpty ? null : _storeController.text.trim(),
        purchaseUrl: _urlController.text.trim().isEmpty ? null : _urlController.text.trim(),
        price: double.tryParse(_priceController.text.trim()),
        currency: _currency,
      );

      AppLogger.i('Auto-saved product suggestion: ${suggestion.name}', tag: 'AddSuggestionModal');
      widget.onSave(suggestion);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to auto-save product suggestion', error: e.toString(), stackTrace: stackTrace, tag: 'AddSuggestionModal');
    }
  }

  Widget _buildImageSection(AppLocalizations? l10n) {
    final hasImage = _imageUrlController.text.trim().isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage) ...[
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImageWidget(_imageUrlController.text.trim()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _imageUrlController.clear();
                  });
                  _autoSave();
                },
              ),
            ],
          ),
        ] else if (_isPickingImage) ...[
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImagePickerSource.camera, l10n),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(l10n?.takePhoto ?? 'Take Photo'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImagePickerSource.gallery, l10n),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(l10n?.chooseFromGallery ?? 'Choose Gallery'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: _imageUrlController,
          decoration: InputDecoration(
            labelText: l10n?.imageUrl ?? 'Or paste Image URL',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.link),
          ),
          keyboardType: TextInputType.url,
          textDirection: TextDirection.ltr,
          onChanged: (_) {
            setState(() {});
            _autoSave();
          },
        ),
      ],
    );
  }

  Widget _buildImageWidget(String path) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: path.startsWith('http://') || path.startsWith('https://')
          ? Image.network(
              path,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.broken_image, size: 48));
              },
            )
          : Image.file(
              File(path),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.broken_image, size: 48));
              },
            ),
    );
  }

  Future<void> _pickImage(ImagePickerSource source, AppLocalizations? l10n) async {
    setState(() {
      _isPickingImage = true;
    });

    final result = await _storageService.pickAndCompressImage(source);

    if (mounted) {
      setState(() {
        _isPickingImage = false;
      });

      if (result.isSuccess) {
        final path = result.value;
        if (path != null) {
          setState(() {
            _imageUrlController.text = path;
          });
          _autoSave();
        }
      } else {
        AppLogger.e('Failed to pick image', error: result.error.message, tag: 'AddSuggestionModal');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.imagePickError ?? 'Failed to pick image'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final maxHeight = mediaQuery.size.height * 0.85;

    final isEditing = widget.initialSuggestion != null;
    final title = isEditing 
        ? (l10n?.editSuggestion ?? 'Edit Suggestion') 
        : (l10n?.addSuggestion ?? 'Add Suggestion');

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n?.nameExample ?? 'Name (e.g. Nike Pegasus)',
                  border: const OutlineInputBorder(),
                ),
                autofocus: !isEditing,
                onChanged: (_) => _autoSave(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                focusNode: _descriptionFocusNode,
                decoration: InputDecoration(
                  labelText: l10n?.description ?? 'Description',
                  border: const OutlineInputBorder(),
                ),
                maxLines: _descriptionFocusNode.hasFocus ? 7 : 2,
                onChanged: (_) => _autoSave(),
              ),
              const SizedBox(height: 12),
              _buildImageSection(l10n),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _prosController,
                      decoration: InputDecoration(
                        labelText: l10n?.prosComma ?? 'Pros (comma separated)',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.add_circle_outline, color: Colors.green),
                      ),
                      onChanged: (_) => _autoSave(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _consController,
                      decoration: InputDecoration(
                        labelText: l10n?.consComma ?? 'Cons (comma separated)',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.remove_circle_outline, color: Theme.of(context).colorScheme.error),
                      ),
                      onChanged: (_) => _autoSave(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _storeController,
                      decoration: InputDecoration(
                        labelText: l10n?.storeName ?? 'Store Name',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.store_outlined),
                      ),
                      onChanged: (_) => _autoSave(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: l10n?.price ?? 'Price',
                        border: const OutlineInputBorder(),
                        prefixIcon: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _currency,
                            items: const [
                              DropdownMenuItem(value: '₪', child: Text(' ₪ ')),
                              DropdownMenuItem(value: '\$', child: Text(' \$ ')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _currency = val);
                                _autoSave();
                              }
                            },
                          ),
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => _autoSave(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: l10n?.productPageLink ?? 'Product Page Link',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.open_in_new),
                ),
                keyboardType: TextInputType.url,
                textDirection: TextDirection.ltr,
                onChanged: (_) => _autoSave(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
