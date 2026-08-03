---
name: flutter-verify-bilingual-rtl
description: Verifies complete Hebrew (RTL) and English (LTR) bilingual localization support, ARB file synchronization, and bidirectional layout in Flutter applications. Use when implementing UI features, adding user-facing text, or testing RTL/LTR localization.
---

# Bilingual Hebrew & English Localization (RTL + ARB i18n) Skill

In **ShoppingExplore** (and bilingual Flutter projects), every UI feature, dialog, message, and button **must** support both Hebrew (`'he'`, RTL directionality) and English (`'en'`, LTR directionality).

---

## 1. Mandatory Localization Rules

1. **Zero Hardcoded Strings**:
   - **Never** write hardcoded user-facing strings in UI widgets (e.g., `Text('Start Shopping')` or `Text('התחבר')`).
   - All user-facing strings **must** be retrieved from `AppLocalizations.of(context)`.

2. **ARB Translation Synchronization**:
   - Every string key must be added to **both**:
     - English: `lib/l10n/app_en.arb`
     - Hebrew: `lib/l10n/app_he.arb`
   - Use clear, semantic camelCase key names (e.g., `startShoppingButton`, `toBuySectionHeader`, `activeShoppersBanner`).
   - For parametrized strings, define explicit placeholders in the ARB files:
     ```json
     "activeShoppersCount": "Active Shoppers ({count})",
     "@activeShoppersCount": {
       "placeholders": {
         "count": {
           "type": "int"
         }
       }
     }
     ```

3. **Bidirectional (RTL / LTR) Layout Compliance**:
   - Use directional properties instead of absolute left/right properties whenever possible:
     - Use `EdgeInsetsDirectional.only(start: ..., end: ...)` instead of `EdgeInsets.only(left: ..., right: ...)`.
     - Use `AlignmentDirectional.centerStart` instead of `Alignment.centerLeft`.
   - When inspecting directionality at runtime:
     ```dart
     final isHebrew = Localizations.localeOf(context).languageCode == 'he';
     final isRtl = Directionality.of(context) == TextDirection.rtl;
     ```

---

## 2. Localization Verification & Testing Workflow

When developing or reviewing a feature, verify localization using the following steps:

1. **Generate Localizations**:
   - Ensure `flutter generate: true` is enabled in `pubspec.yaml`.
   - Run `flutter pub get` or `flutter gen-l10n` to regenerate `AppLocalizations`.

2. **Widget Test Verification**:
   - In widget tests, wrap widgets under test with explicit localizations delegates and test both locales:
     ```dart
     MaterialApp(
       locale: const Locale('he', ''),
       localizationsDelegates: AppLocalizations.localizationsDelegates,
       supportedLocales: AppLocalizations.supportedLocales,
       home: Scaffold(body: MyWidget()),
     )
     ```
   - Verify that Hebrew localized strings render correctly in RTL and English strings render correctly in LTR.

3. **Checklist Before PR Submission**:
   - [ ] No hardcoded strings in Dart UI code.
   - [ ] All new ARB keys exist in `app_en.arb` and `app_he.arb`.
   - [ ] Dynamic string interpolation uses ARB placeholders (`{param}`).
   - [ ] `flutter analyze` reports 0 errors and 0 warnings.
