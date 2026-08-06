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

  @override
  String get startShopping => 'התחל קנייה';

  @override
  String get restoreItem => 'החזר לרשימה';

  @override
  String get activeItemsSection => 'פריטים פעילים';

  @override
  String get welcomeBack => 'ברוך שובך';

  @override
  String get welcomeGuest => '!ברוכים הבאים';

  @override
  String get listsCount => 'רשימות';

  @override
  String get itemsCount => 'פריטים';

  @override
  String get createFirstList => 'לחץ + כדי ליצור את רשימת הקניות הראשונה שלך!';

  @override
  String get createList => 'צור רשימה';

  @override
  String get newListTitleHint => 'לדוגמה, ציוד למסיבת יום הולדת';

  @override
  String get newListDescHint => 'תיאור קצר אופציונלי';

  @override
  String get colorLabel => 'צבע';

  @override
  String get completedLabel => 'הושלמו';

  @override
  String get memberSince => 'חבר מאז 2024';

  @override
  String get statsLists => 'רשימות';

  @override
  String get statsItems => 'פריטים';

  @override
  String get statsShared => 'משותפים';

  @override
  String get deleteList => 'מחק רשימה';

  @override
  String get deleteListConfirm => 'האם אתה בטוח שברצונך למחוק רשימה זו?';

  @override
  String get rememberMeOnDevice => 'זכור אותי במכשיר זה';

  @override
  String get editProfile => 'ערוך פרופיל';

  @override
  String get saveProfile => 'שמור שינויים';

  @override
  String get avatarStyle => 'סגנון תמונה';

  @override
  String get profileUpdatedSuccess => 'הפרופיל עודכן בהצלחה';

  @override
  String get authGuardTitle => 'נדרשת התחברות';

  @override
  String get authGuardMessage =>
      'אנא התחבר או צור חשבון כדי לצפות ולנהל את רשימות הקניות שלך.';

  @override
  String get toBuySection => 'לקנות';

  @override
  String get completedSection => 'הושלמו';

  @override
  String get liveSyncing => 'סנכרון חי';

  @override
  String get itemDetails => 'פרטי פריט';

  @override
  String get suggestions => 'הצעות / אפשרויות';

  @override
  String get addSuggestion => 'הוסף הצעה';

  @override
  String get noSuggestionsYet => 'אין עדיין הצעות';

  @override
  String get addSuggestionToHelp =>
      'הוסף הצעה כדי לעזור לאחרים לדעת בדיוק מה לקנות.';

  @override
  String get pros => 'יתרונות';

  @override
  String get cons => 'חסרונות';

  @override
  String get deleteSuggestion => 'מחק הצעה';

  @override
  String get productPage => 'עמוד המוצר';

  @override
  String get nameExample => 'שם (למשל: נעלי ריצה)';

  @override
  String get description => 'תיאור';

  @override
  String get imageUrl => 'קישור לתמונה';

  @override
  String get prosComma => 'יתרונות (מופרדים בפסיק)';

  @override
  String get consComma => 'חסרונות (מופרדים בפסיק)';

  @override
  String get storeName => 'שם החנות';

  @override
  String get price => 'מחיר';

  @override
  String get productPageLink => 'קישור לעמוד המוצר';

  @override
  String get saveSuggestion => 'שמור הצעה';

  @override
  String get editSuggestion => 'ערוך הצעה';
}
