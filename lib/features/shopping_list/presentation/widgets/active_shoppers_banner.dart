import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/user_utils.dart';
import '../../domain/entities/shopping_session.dart';

class ActiveShoppersBanner extends StatelessWidget {
  final List<ShoppingSession> activeSessions;
  final String? currentUserEmail;

  const ActiveShoppersBanner({
    super.key,
    required this.activeSessions,
    this.currentUserEmail,
  });

  @override
  Widget build(BuildContext context) {
    if (activeSessions.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isHebrew = Localizations.localeOf(context).languageCode == 'he';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0D3B2E), const Color(0xFF1E1E2C)]
              : [
                  AppColors.secondary.withValues(alpha: 0.15),
                  AppColors.secondary.withValues(alpha: 0.05),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isHebrew
                    ? 'קונים פעילים ברשימה (${activeSessions.length})'
                    : 'Active Shoppers (${activeSessions.length})',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...activeSessions.map((session) {
            final email = session.userEmail;
            final displayName = getDisplayNameForEmail(email);
            final isMe = currentUserEmail != null &&
                email.toLowerCase() == currentUserEmail!.toLowerCase();
            final locationText = session.locationName != null && session.locationName!.isNotEmpty
                ? (isHebrew
                    ? 'קונה ב: ${session.locationName}'
                    : 'shopping at ${session.locationName}')
                : (isHebrew ? 'בקנייה פעילה כעת' : 'currently shopping');

            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: isMe ? AppColors.secondary : theme.colorScheme.secondary,
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        children: [
                          TextSpan(
                            text: isMe ? (isHebrew ? 'אתה ' : 'You ') : '$displayName ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: locationText,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (session.locationName != null && session.locationName!.isNotEmpty)
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
