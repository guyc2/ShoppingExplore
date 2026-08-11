import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/product_suggestion.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/logger.dart';

class ProductSuggestionCard extends StatefulWidget {
  final ProductSuggestion suggestion;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFavorite;

  const ProductSuggestionCard({
    super.key,
    required this.suggestion,
    this.onEdit,
    this.onDelete,
    this.onToggleFavorite,
  });

  @override
  State<ProductSuggestionCard> createState() => _ProductSuggestionCardState();
}

class _ProductSuggestionCardState extends State<ProductSuggestionCard> {
  bool _isExpanded = false;
  bool _isImageExpanded = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isExpanded) {
        setState(() {
          _isExpanded = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        AppLogger.e('Exception launching URL: $urlString',
            error: e, tag: 'ProductSuggestionCard');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch link: $urlString')),
          );
        }
      }
    } else {
      AppLogger.w('Invalid URL or cannot launch: $urlString',
          tag: 'ProductSuggestionCard');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch link: $urlString')),
        );
      }
    }
  }

  Widget _buildImageWidget(String path, ThemeData theme) {
    return Container(
      height: 180,
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: path.startsWith('http://') || path.startsWith('https://')
          ? Image.network(
              path,
              height: 180,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _buildFallback(theme),
            )
          : Image.file(
              File(path),
              height: 180,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _buildFallback(theme),
            ),
    );
  }

  Widget _buildFallback(ThemeData theme) {
    return Container(
      height: 180,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(Icons.image_not_supported_outlined,
          size: 48, color: theme.colorScheme.outline),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final suggestion = widget.suggestion;
    final hasImage =
        suggestion.imageUrl != null && suggestion.imageUrl!.isNotEmpty;
    final hasProsCons =
        suggestion.pros.isNotEmpty || suggestion.cons.isNotEmpty;
    final hasPurchaseInfo = suggestion.purchaseLocation != null ||
        suggestion.purchaseUrl != null ||
        suggestion.price != null;

    return Focus(
      focusNode: _focusNode,
      child: TapRegion(
        onTapOutside: (_) {
          if (_isExpanded) {
            setState(() {
              _isExpanded = false;
            });
            _focusNode.unfocus();
          }
        },
        child: Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasImage && _isImageExpanded && _isExpanded)
                _buildImageWidget(suggestion.imageUrl!, theme),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            suggestion.name,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.onToggleFavorite != null)
                          IconButton(
                            icon: Icon(
                              suggestion.isFavorite
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: suggestion.isFavorite
                                  ? Colors.amber.shade700
                                  : theme.colorScheme.outline,
                              size: 26,
                            ),
                            onPressed: widget.onToggleFavorite,
                            tooltip: suggestion.isFavorite
                                ? 'Remove Favorite'
                                : 'Mark as Favorite',
                          ),
                        IconButton(
                          icon: Icon(
                            _isExpanded ? Icons.remove : Icons.add,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                              if (_isExpanded) {
                                _focusNode.requestFocus();
                              } else {
                                _focusNode.unfocus();
                              }
                            });
                          },
                          tooltip: _isExpanded ? 'Collapse' : 'Expand',
                        ),
                        if (_isExpanded && hasImage)
                          IconButton(
                            icon: Icon(
                              _isImageExpanded
                                  ? Icons.image
                                  : Icons.image_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                _isImageExpanded = !_isImageExpanded;
                              });
                            },
                            tooltip: _isImageExpanded
                                ? (l10n?.collapseImage ?? 'Collapse Image')
                                : (l10n?.expandImage ?? 'Expand Image'),
                          ),
                        if (widget.onEdit != null)
                          IconButton(
                            icon: Icon(Icons.edit_outlined,
                                color: theme.colorScheme.primary),
                            onPressed: widget.onEdit,
                            tooltip: l10n?.editSuggestion ?? 'Edit',
                          ),
                        if (_isExpanded && widget.onDelete != null)
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: theme.colorScheme.error),
                            onPressed: widget.onDelete,
                            tooltip:
                                l10n?.deleteSuggestion ?? 'Delete Suggestion',
                          ),
                      ],
                    ),
                    if (_isExpanded) ...[
                      if (suggestion.isFavorite) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber.shade600),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded,
                                  size: 16, color: Colors.amber.shade900),
                              const SizedBox(width: 4),
                              Text(
                                'Favorite Choice',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.amber.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (suggestion.description != null &&
                          suggestion.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          suggestion.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                      if (hasProsCons) ...[
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (suggestion.pros.isNotEmpty)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n?.pros ?? 'Pros',
                                      style:
                                          theme.textTheme.labelLarge?.copyWith(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ...suggestion.pros.map((pro) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 2),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(Icons.check_circle_outline,
                                                  size: 16,
                                                  color: Colors.green.shade600),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                  child: Text(pro,
                                                      style: theme.textTheme
                                                          .bodySmall)),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            if (suggestion.pros.isNotEmpty &&
                                suggestion.cons.isNotEmpty)
                              const SizedBox(width: 16),
                            if (suggestion.cons.isNotEmpty)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n?.cons ?? 'Cons',
                                      style:
                                          theme.textTheme.labelLarge?.copyWith(
                                        color: theme.colorScheme.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ...suggestion.cons.map((con) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 2),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(Icons.remove_circle_outline,
                                                  size: 16,
                                                  color:
                                                      theme.colorScheme.error),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                  child: Text(con,
                                                      style: theme.textTheme
                                                          .bodySmall)),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                      if (hasPurchaseInfo) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (suggestion.purchaseLocation != null &&
                                suggestion.purchaseLocation!.isNotEmpty) ...[
                              Icon(Icons.store_outlined,
                                  size: 18, color: theme.colorScheme.secondary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  suggestion.purchaseLocation!,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            if (suggestion.price != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '${suggestion.currency ?? "₪"}${suggestion.price!.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (suggestion.purchaseUrl != null &&
                            suggestion.purchaseUrl!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () =>
                                  _launchUrl(context, suggestion.purchaseUrl!),
                              icon: const Icon(Icons.open_in_new),
                              label: Text(l10n?.productPage ?? 'Product Page'),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
