import '../../features/shopping_list/domain/entities/shopping_list.dart';

/// Global registry of registered user display names mapped by email/id.
final Map<String, String> userRegistry = {
  'guy@shoppingexplore.com': 'Guy C',
  'guyc@shoppingexplore.com': 'Guy C',
  'guyc2@shoppingexplore.com': 'Guy C',
  'user@shoppingexplore.com': 'Alex User',
  'friend@shoppingexplore.com': 'Taylor Friend',
  'admin@shoppingexplore.com': 'Admin Manager',
  'colleague@shoppingexplore.com': 'Colleague',
};

/// Registers a user's display name dynamically at runtime (e.g., after login/signup).
void registerUserDisplayName(String email, String displayName) {
  if (email.trim().isNotEmpty && displayName.trim().isNotEmpty) {
    userRegistry[email.trim().toLowerCase()] = displayName.trim();
  }
}

/// Helper functions for user display names and collaborator formatting.
String getDisplayNameForEmail(String? identifier, {ShoppingList? list}) {
  if (identifier == null || identifier.trim().isEmpty) {
    return '';
  }
  final clean = identifier.trim();
  final cleanEmail = clean.toLowerCase();

  // 1. Check list-specific collaborator display names map first
  if (list != null && list.collaboratorDisplayNames.containsKey(cleanEmail)) {
    final listName = list.collaboratorDisplayNames[cleanEmail]!;
    if (listName.trim().isNotEmpty) return listName.trim();
  }
  if (list != null && list.collaboratorDisplayNames.containsKey(clean)) {
    final listName = list.collaboratorDisplayNames[clean]!;
    if (listName.trim().isNotEmpty) return listName.trim();
  }

  // 2. Check global user registry
  if (userRegistry.containsKey(cleanEmail)) {
    return userRegistry[cleanEmail]!;
  }
  if (userRegistry.containsKey(clean)) {
    return userRegistry[clean]!;
  }

  // 3. If the identifier doesn't contain '@', it might already be a display name
  if (!clean.contains('@')) {
    return clean;
  }

  // NEVER return the email address or part of it, as per strict user instructions.
  // Fallback to a generic name for unknown collaborators.
  return 'Collaborator';
}
