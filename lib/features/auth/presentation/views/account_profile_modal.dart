import 'package:flutter/material.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';
import '../../../../core/utils/logger.dart';
import '../controllers/auth_controller.dart';

/// A modal dialog displaying user profile information and interactive
/// statistics. Shows avatar, display name, email, and stats like
/// total lists, total items, and shared lists.
class AccountProfileModal extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: authController,
      builder: (context, _) {
        final state = authController.state;
        if (state is! Authenticated) {
          return const SizedBox.shrink();
        }
        final user = state.user;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: 340,
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
                _buildAvatar(user.displayName, colorScheme),
                const SizedBox(height: 16),

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
                const SizedBox(height: 24),

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
                      authController.logout();
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(String displayName, ColorScheme colorScheme) {
    final initial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

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
          child: Text(
            initial,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
          ),
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
          value: '$totalLists',
          label: l10n?.statsLists ?? 'Lists',
          color: colorScheme.primary,
        ),
        _StatTile(
          icon: Icons.check_circle_outline_rounded,
          value: '$totalItems',
          label: l10n?.statsItems ?? 'Items',
          color: colorScheme.secondary,
        ),
        _StatTile(
          icon: Icons.people_outline_rounded,
          value: '$sharedLists',
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
