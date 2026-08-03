import 'package:flutter/material.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../controllers/auth_controller.dart';

/// A modal dialog displaying user profile information and interactive
/// statistics. Shows avatar, display name, email, and stats like
/// total lists, total items, and shared lists. Includes inline Profile Editing mode.
class AccountProfileModal extends StatefulWidget {
  final AuthController authController;
  final int totalLists;
  final int totalItems;
  final int sharedLists;

  const AccountProfileModal({
    super.key,
    required this.authController,
    this.totalLists = 0,
    this.totalItems = 0,
    this.sharedLists = 0,
  });

  @override
  State<AccountProfileModal> createState() => _AccountProfileModalState();
}

class _AccountProfileModalState extends State<AccountProfileModal> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  String? _selectedAvatarUrl;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startEditing(User user) {
    setState(() {
      _nameController.text = user.displayName;
      _selectedAvatarUrl = user.avatarUrl ?? 'person';
      _isEditing = true;
      _errorMessage = null;
    });
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context);
    final displayName = _nameController.text.trim();
    if (displayName.isEmpty) {
      setState(() => _errorMessage = l10n?.displayNameRequired ?? 'Display Name is required');
      return;
    }
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final success = await widget.authController.updateProfile(
      displayName: displayName,
      avatarUrl: _selectedAvatarUrl,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.profileUpdatedSuccess ?? 'Profile updated successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() => _errorMessage = l10n?.authFailed ?? 'Failed to update profile');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: widget.authController,
      builder: (context, _) {
        final state = widget.authController.state;
        if (state is! Authenticated) {
          return const SizedBox.shrink();
        }
        final user = state.user;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primaryContainer.withValues(alpha: 0.3),
                  colorScheme.surface,
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),

                  // Avatar with glowing border
                  _buildAvatar(user.displayName, _isEditing ? _selectedAvatarUrl : user.avatarUrl, colorScheme),
                  const SizedBox(height: 16),

                  if (_isEditing) ...[
                    _buildEditForm(context, l10n, colorScheme),
                  ] else ...[
                    _buildReadOnlyView(context, user, l10n, colorScheme),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReadOnlyView(
    BuildContext context,
    User user,
    AppLocalizations? l10n,
    ColorScheme colorScheme,
  ) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Display name
        Text(
          user.displayName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // Email
        Text(
          user.email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),

        // Member since
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            l10n?.memberSince ?? 'Member since 2024',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Edit Profile button
        OutlinedButton.icon(
          onPressed: () => _startEditing(user),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(l10n?.editProfile ?? 'Edit Profile'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),

        // Stats row
        _buildStatsRow(context, l10n),

        const SizedBox(height: 20),

        // Sign out button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              AppLogger.i('User signing out from profile modal',
                  tag: 'AccountProfileModal');
              widget.authController.logout();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.logout, size: 18),
            label: Text(l10n?.signOut ?? 'Sign Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(
                color: colorScheme.error.withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(
    BuildContext context,
    AppLocalizations? l10n,
    ColorScheme colorScheme,
  ) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: l10n?.displayName ?? 'Display Name',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n?.avatarStyle ?? 'Avatar Style',
          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildAvatarStyleChip('person', Icons.person, colorScheme),
            _buildAvatarStyleChip('star', Icons.star, colorScheme),
            _buildAvatarStyleChip('face', Icons.face, colorScheme),
            _buildAvatarStyleChip('smile', Icons.sentiment_very_satisfied, colorScheme),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _isSaving ? null : () => setState(() => _isEditing = false),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n?.saveProfile ?? 'Save Changes'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatarStyleChip(String styleKey, IconData icon, ColorScheme colorScheme) {
    final isSelected = _selectedAvatarUrl == styleKey;
    return ChoiceChip(
      label: Icon(icon, size: 18, color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedAvatarUrl = styleKey);
        }
      },
    );
  }

  Widget _buildAvatar(String displayName, String? avatarUrl, ColorScheme colorScheme) {
    final initial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

    Widget innerContent;
    if (avatarUrl == 'star') {
      innerContent = Icon(Icons.star, size: 38, color: colorScheme.onPrimary);
    } else if (avatarUrl == 'face') {
      innerContent = Icon(Icons.face, size: 38, color: colorScheme.onPrimary);
    } else if (avatarUrl == 'smile') {
      innerContent = Icon(Icons.sentiment_very_satisfied, size: 38, color: colorScheme.onPrimary);
    } else {
      innerContent = Text(
        initial,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
      );
    }

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surface,
        ),
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.tertiary,
              ],
            ),
          ),
          alignment: Alignment.center,
          child: innerContent,
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, AppLocalizations? l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatTile(
          icon: Icons.list_alt_rounded,
          value: '${widget.totalLists}',
          label: l10n?.statsLists ?? 'Lists',
          color: colorScheme.primary,
        ),
        _StatTile(
          icon: Icons.check_circle_outline_rounded,
          value: '${widget.totalItems}',
          label: l10n?.statsItems ?? 'Items',
          color: colorScheme.secondary,
        ),
        _StatTile(
          icon: Icons.people_outline_rounded,
          value: '${widget.sharedLists}',
          label: l10n?.statsShared ?? 'Shared',
          color: colorScheme.tertiary,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
