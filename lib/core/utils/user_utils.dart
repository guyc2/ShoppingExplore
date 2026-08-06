library;

/// Helper functions for user display names and collaborator formatting.

String getDisplayNameForEmail(String? email) {
  if (email == null || email.trim().isEmpty) {
    return '';
  }
  final cleanEmail = email.trim().toLowerCase();

  // Known mapping for demo/debug accounts
  if (cleanEmail == 'guy@shoppingexplore.com' || cleanEmail == 'guyc@shoppingexplore.com' || cleanEmail == 'guyc2@shoppingexplore.com') {
    return 'Guy C';
  }
  if (cleanEmail == 'user@shoppingexplore.com') {
    return 'Alex User';
  }
  if (cleanEmail == 'friend@shoppingexplore.com') {
    return 'Taylor Friend';
  }
  if (cleanEmail == 'admin@shoppingexplore.com') {
    return 'Admin Manager';
  }
  if (cleanEmail == 'colleague@shoppingexplore.com') {
    return 'Colleague';
  }

  // Fallback: format name part before @
  final namePart = email.split('@').first;
  final parts = namePart.replaceAll(RegExp(r'[._-]'), ' ').split(' ');
  return parts.map((p) => p.isNotEmpty ? '${p[0].toUpperCase()}${p.substring(1)}' : '').join(' ').trim();
}
