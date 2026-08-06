// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Shopping Explore';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signOut => 'Sign Out';

  @override
  String get switchAccount => 'Switch Account';

  @override
  String signedInAs(String email) {
    return 'Signed in as:\n$email';
  }

  @override
  String get createAccount => 'Create Account';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get displayName => 'Display Name';

  @override
  String get cancel => 'Cancel';

  @override
  String get register => 'Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign In';

  @override
  String get needAccount => 'Need an account? Register';

  @override
  String get noListsAvailable => 'No lists available';

  @override
  String get addItem => 'Add Item';

  @override
  String get quickAddItem => 'Quick-add item...';

  @override
  String get editItem => 'Edit Item';

  @override
  String get titleLabel => 'Title';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get categoryLabel => 'Category';

  @override
  String get notesLabel => 'Notes';

  @override
  String get save => 'Save';

  @override
  String get shareList => 'Share List';

  @override
  String get collaborators => 'Collaborators';

  @override
  String get inviteByEmail => 'Invite by Email';

  @override
  String get canEdit => 'Can edit';

  @override
  String get canView => 'Can view';

  @override
  String get emailRequired => 'Email and password are required';

  @override
  String get displayNameRequired => 'Display name is required for registration';

  @override
  String get authFailed => 'Authentication failed';

  @override
  String get emptyList => 'Your shopping list is empty';

  @override
  String get addFirstItem => 'Add an item below to get started!';

  @override
  String get quickDebugGuyC => 'Quick Debug Login as Guy C';

  @override
  String get allMyLists => 'All My Lists';

  @override
  String get newShoppingList => 'New Shopping List';

  @override
  String get shortDescriptionLabel => 'Short Description';

  @override
  String get fullDescriptionLabel => 'Full Description';

  @override
  String get sharedWithLabel => 'Shared with';

  @override
  String get accountProfile => 'Account & Profile';

  @override
  String get assignedToLabel => 'Assigned to';

  @override
  String get activeShoppingMode => 'Active Shopping Mode';

  @override
  String get removedItemsSection => 'In Cart / Removed Items';

  @override
  String get completeShopping => 'Complete Shopping';

  @override
  String get cancelShopping => 'Cancel Shopping';

  @override
  String get startShopping => 'Start Shopping';

  @override
  String get restoreItem => 'Restore to list';

  @override
  String get activeItemsSection => 'Active Items';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get welcomeGuest => 'Welcome!';

  @override
  String get listsCount => 'lists';

  @override
  String get itemsCount => 'items';

  @override
  String get createFirstList => 'Tap + to create your first shopping list!';

  @override
  String get createList => 'Create List';

  @override
  String get newListTitleHint => 'e.g., Birthday Party Supplies';

  @override
  String get newListDescHint => 'Optional brief description';

  @override
  String get colorLabel => 'Color';

  @override
  String get completedLabel => 'completed';

  @override
  String get memberSince => 'Member since 2024';

  @override
  String get statsLists => 'Lists';

  @override
  String get statsItems => 'Items';

  @override
  String get statsShared => 'Shared';

  @override
  String get deleteList => 'Delete List';

  @override
  String get deleteListConfirm => 'Are you sure you want to delete this list?';

  @override
  String get rememberMeOnDevice => 'Remember me on this device';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get saveProfile => 'Save Changes';

  @override
  String get avatarStyle => 'Avatar Style';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully';

  @override
  String get authGuardTitle => 'Authentication Required';

  @override
  String get authGuardMessage =>
      'Please sign in or create an account to view and manage your shopping lists.';

  @override
  String get toBuySection => 'To Buy';

  @override
  String get completedSection => 'Completed';

  @override
  String get liveSyncing => 'Live Sync';

  @override
  String get itemDetails => 'Item Details';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get addSuggestion => 'Add Suggestion';

  @override
  String get noSuggestionsYet => 'No suggestions yet';

  @override
  String get addSuggestionToHelp =>
      'Add a suggestion to help others know exactly what to buy.';

  @override
  String get pros => 'Pros';

  @override
  String get cons => 'Cons';

  @override
  String get deleteSuggestion => 'Delete Suggestion';

  @override
  String get productPage => 'Product Page';

  @override
  String get nameExample => 'Name (e.g. Nike Pegasus)';

  @override
  String get description => 'Description';

  @override
  String get imageUrl => 'Image URL';

  @override
  String get prosComma => 'Pros (comma separated)';

  @override
  String get consComma => 'Cons (comma separated)';

  @override
  String get storeName => 'Store Name';

  @override
  String get price => 'Price';

  @override
  String get productPageLink => 'Product Page Link';

  @override
  String get saveSuggestion => 'Save Suggestion';

  @override
  String get editSuggestion => 'Edit Suggestion';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get removeImage => 'Remove Image';

  @override
  String get imagePickError => 'Failed to pick image';

  @override
  String get addItemHint => 'Add an item...';

  @override
  String get editItemDetails => 'Edit Item Details';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String get urlsAndLinks => 'URLs / Links (comma separated)';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get assignedToUser => 'Assigned To (responsible user)';
}
