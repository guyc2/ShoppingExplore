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
}
