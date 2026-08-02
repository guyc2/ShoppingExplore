// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'Shopping Explore';

  @override
  String get signIn => 'התחבר';

  @override
  String get signUp => 'הרשם';

  @override
  String get signOut => 'התנתק';

  @override
  String get switchAccount => 'החליף חשבון';

  @override
  String signedInAs(String email) {
    return 'מחובר כ:\n$email';
  }

  @override
  String get createAccount => 'צור חשבון';

  @override
  String get emailAddress => 'כתובת דוא\"ל';

  @override
  String get password => 'סיסמה';

  @override
  String get displayName => 'שם תצוגה';

  @override
  String get cancel => 'ביטול';

  @override
  String get register => 'הרשמה';

  @override
  String get alreadyHaveAccount => 'כבר יש לך חשבון? התחבר';

  @override
  String get needAccount => 'אין לך חשבון? הרשם';

  @override
  String get noListsAvailable => 'אין רשימות זמינות';

  @override
  String get addItem => 'הוסף פריט';

  @override
  String get quickAddItem => 'הוסף פריט מהיר...';

  @override
  String get editItem => 'ערוך פריט';

  @override
  String get titleLabel => 'כותרת';

  @override
  String get quantityLabel => 'כמות';

  @override
  String get categoryLabel => 'קטגוריה';

  @override
  String get notesLabel => 'הערות';

  @override
  String get save => 'שמור';

  @override
  String get shareList => 'שתף רשימה';

  @override
  String get collaborators => 'משתתפים';

  @override
  String get inviteByEmail => 'הזמן לפי דוא\"ל';

  @override
  String get canEdit => 'יכול לערוך';

  @override
  String get canView => 'יכול לצפות';

  @override
  String get emailRequired => 'נדרשים אימייל וסיסמה';

  @override
  String get displayNameRequired => 'שם תצוגה נדרש להרשמה';

  @override
  String get authFailed => 'האימות נכשל';

  @override
  String get emptyList => 'רשימת הקניות שלך ריקה';

  @override
  String get addFirstItem => 'הוסף פריט למטה כדי להתחיל!';

  @override
  String get quickDebugGuyC => 'התחברות מהירה כ-Guy C (מצב דיבאג)';

  @override
  String get allMyLists => 'כל הרשימות שלי';

  @override
  String get newShoppingList => 'רשימת קניות חדשה';

  @override
  String get shortDescriptionLabel => 'תיאור קצר';

  @override
  String get fullDescriptionLabel => 'תיאור מלא';

  @override
  String get sharedWithLabel => 'משותף עם';

  @override
  String get accountProfile => 'חשבון ופרופיל';

  @override
  String get assignedToLabel => 'מוקצה ל-';

  @override
  String get activeShoppingMode => 'מצב קניות פעיל';

  @override
  String get removedItemsSection => 'בעגלה / פריטים שהוסרו';

  @override
  String get completeShopping => 'סיום קנייה';

  @override
  String get cancelShopping => 'ביטול קנייה';
}
