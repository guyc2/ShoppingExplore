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

/// Helper functions for user display names and collaborator formatting.
String getDisplayNameForEmail(String? identifier) {
  if (identifier == null || identifier.trim().isEmpty) {
    return '';
  }
  final clean = identifier.trim();

  // If it's already a display name (doesn't contain '@'), return it directly
  if (!clean.contains('@')) {
    return clean;
  }

  final cleanEmail = clean.toLowerCase();
  if (userRegistry.containsKey(cleanEmail)) {
    return userRegistry[cleanEmail]!;
  }

  // Return the original string as-is without splitting or parsing email text
  return clean;
}
