import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/app.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';

void main() {
  group('Hebrew & English Localization (i18n & RTL) Tests', () {
    testWidgets('AppLocalizations loads Hebrew strings correctly', (tester) async {
      late AppLocalizations? l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('he', ''),
          supportedLocales: const [Locale('he', ''), Locale('en', '')],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context);
              return const Scaffold();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(l10n, isNotNull);
      expect(l10n?.signIn, equals('התחבר'));
      expect(l10n?.signUp, equals('הרשם'));
      expect(l10n?.emptyList, equals('רשימת הקניות שלך ריקה'));
      expect(l10n?.appTitle, equals('Shopping Explore'));
    });

    testWidgets('AppLocalizations loads English strings correctly', (tester) async {
      late AppLocalizations? l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', ''),
          supportedLocales: const [Locale('he', ''), Locale('en', '')],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context);
              return const Scaffold();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(l10n, isNotNull);
      expect(l10n?.signIn, equals('Sign In'));
      expect(l10n?.signUp, equals('Sign Up'));
      expect(l10n?.emptyList, equals('Your shopping list is empty'));
      expect(l10n?.appTitle, equals('Shopping Explore'));
    });

    testWidgets('Language toggle button in ShoppingExploreApp switches between Hebrew and English', (tester) async {
      await tester.pumpWidget(const ShoppingExploreApp());
      await tester.pumpAndSettle();

      expect(find.text('HE'), findsOneWidget);
      expect(find.text('התחבר'), findsWidgets);
      expect(find.text('הרשם'), findsOneWidget);

      await tester.tap(find.text('HE'));
      await tester.pumpAndSettle();

      expect(find.text('EN'), findsOneWidget);
      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Sign Up'), findsOneWidget);
    });
  });
}
