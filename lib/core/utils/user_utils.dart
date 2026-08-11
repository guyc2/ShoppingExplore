library;

/// Helper functions for user display names and collaborator formatting.

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
String getDisplayNameForEmail(String? identifier) {
  if (identifier == null || identifier.trim().isEmpty) {
    return '';
  }
  final clean = identifier.trim();

  // If the identifier doesn't contain '@', it might already be a display name
  if (!clean.contains('@')) {
    return clean;
  }

  final cleanEmail = clean.toLowerCase();
  if (userRegistry.containsKey(cleanEmail)) {
    return userRegistry[cleanEmail]!;
  }

  // NEVER return the email address or part of it, as per strict user instructions.
  // Fallback to a generic name for unknown collaborators.
  return 'Collaborator';
}
