import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping Explore'**
  String get appTitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @switchAccount.
  ///
  /// In en, this message translates to:
  /// **'Switch Account'**
  String get switchAccount;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as:\n{email}'**
  String signedInAs(String email);

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get alreadyHaveAccount;

  /// No description provided for @needAccount.
  ///
  /// In en, this message translates to:
  /// **'Need an account? Register'**
  String get needAccount;

  /// No description provided for @noListsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No lists available'**
  String get noListsAvailable;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @quickAddItem.
  ///
  /// In en, this message translates to:
  /// **'Quick-add item...'**
  String get quickAddItem;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @shareList.
  ///
  /// In en, this message translates to:
  /// **'Share List'**
  String get shareList;

  /// No description provided for @collaborators.
  ///
  /// In en, this message translates to:
  /// **'Collaborators'**
  String get collaborators;

  /// No description provided for @inviteByEmail.
  ///
  /// In en, this message translates to:
  /// **'Invite by Email'**
  String get inviteByEmail;

  /// No description provided for @canEdit.
  ///
  /// In en, this message translates to:
  /// **'Can edit'**
  String get canEdit;

  /// No description provided for @canView.
  ///
  /// In en, this message translates to:
  /// **'Can view'**
  String get canView;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email and password are required'**
  String get emailRequired;

  /// No description provided for @displayNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Display name is required for registration'**
  String get displayNameRequired;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get authFailed;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'Your shopping list is empty'**
  String get emptyList;

  /// No description provided for @addFirstItem.
  ///
  /// In en, this message translates to:
  /// **'Add an item below to get started!'**
  String get addFirstItem;

  /// No description provided for @quickDebugGuyC.
  ///
  /// In en, this message translates to:
  /// **'Quick Debug Login as Guy C'**
  String get quickDebugGuyC;

  /// No description provided for @allMyLists.
  ///
  /// In en, this message translates to:
  /// **'All My Lists'**
  String get allMyLists;

  /// No description provided for @newShoppingList.
  ///
  /// In en, this message translates to:
  /// **'New Shopping List'**
  String get newShoppingList;

  /// No description provided for @shortDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Short Description'**
  String get shortDescriptionLabel;

  /// No description provided for @fullDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Description'**
  String get fullDescriptionLabel;

  /// No description provided for @sharedWithLabel.
  ///
  /// In en, this message translates to:
  /// **'Shared with'**
  String get sharedWithLabel;

  /// No description provided for @accountProfile.
  ///
  /// In en, this message translates to:
  /// **'Account & Profile'**
  String get accountProfile;

  /// No description provided for @assignedToLabel.
  ///
  /// In en, this message translates to:
  /// **'Assigned to'**
  String get assignedToLabel;

  /// No description provided for @activeShoppingMode.
  ///
  /// In en, this message translates to:
  /// **'Active Shopping Mode'**
  String get activeShoppingMode;

  /// No description provided for @removedItemsSection.
  ///
  /// In en, this message translates to:
  /// **'In Cart / Removed Items'**
  String get removedItemsSection;

  /// No description provided for @completeShopping.
  ///
  /// In en, this message translates to:
  /// **'Complete Shopping'**
  String get completeShopping;

  /// No description provided for @cancelShopping.
  ///
  /// In en, this message translates to:
  /// **'Cancel Shopping'**
  String get cancelShopping;

  /// No description provided for @startShopping.
  ///
  /// In en, this message translates to:
  /// **'Start Shopping'**
  String get startShopping;

  /// No description provided for @restoreItem.
  ///
  /// In en, this message translates to:
  /// **'Restore to list'**
  String get restoreItem;

  /// No description provided for @activeItemsSection.
  ///
  /// In en, this message translates to:
  /// **'Active Items'**
  String get activeItemsSection;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @welcomeGuest.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcomeGuest;

  /// No description provided for @listsCount.
  ///
  /// In en, this message translates to:
  /// **'lists'**
  String get listsCount;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get itemsCount;

  /// No description provided for @createFirstList.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first shopping list!'**
  String get createFirstList;

  /// No description provided for @createList.
  ///
  /// In en, this message translates to:
  /// **'Create List'**
  String get createList;

  /// No description provided for @newListTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Birthday Party Supplies'**
  String get newListTitleHint;

  /// No description provided for @newListDescHint.
  ///
  /// In en, this message translates to:
  /// **'Optional brief description'**
  String get newListDescHint;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @completedLabel.
  ///
  /// In en, this message translates to:
  /// **'completed'**
  String get completedLabel;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since 2024'**
  String get memberSince;

  /// No description provided for @statsLists.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get statsLists;

  /// No description provided for @statsItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get statsItems;

  /// No description provided for @statsShared.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get statsShared;

  /// No description provided for @deleteList.
  ///
  /// In en, this message translates to:
  /// **'Delete List'**
  String get deleteList;

  /// No description provided for @deleteListConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this list?'**
  String get deleteListConfirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
