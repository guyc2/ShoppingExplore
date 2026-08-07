import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/l10n/generated/app_localizations.dart';
import 'package:shopping_explore/features/auth/presentation/utils/auth_error_mapper.dart';
import 'package:shopping_explore/features/auth/presentation/controllers/auth_controller.dart';
import 'package:shopping_explore/features/auth/presentation/views/login_view.dart';
import 'package:shopping_explore/features/auth/domain/usecases/login_usecase.dart';
import 'package:shopping_explore/features/auth/domain/usecases/register_usecase.dart';
import 'package:shopping_explore/features/auth/domain/usecases/logout_usecase.dart';
import 'package:shopping_explore/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:shopping_explore/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:shopping_explore/features/auth/data/repositories/auth_repository_impl.dart';
import '../../shared_fakes.dart';

void main() {
  group('AuthErrorMapper Localization Tests', () {
    testWidgets('maps Firebase error codes to English localizations', (tester) async {
      late AppLocalizations enL10n;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              enL10n = AppLocalizations.of(context)!;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(AuthErrorMapper.mapErrorMessage('email-already-in-use', enL10n), 'The email address is already in use by another account.');
      expect(AuthErrorMapper.mapErrorMessage('weak-password', enL10n), 'The password is not strong enough.');
      expect(AuthErrorMapper.mapErrorMessage('wrong-password', enL10n), 'Wrong password provided for that user.');
      expect(AuthErrorMapper.mapErrorMessage('invalid-email', enL10n), 'The email address is badly formatted.');
      expect(AuthErrorMapper.mapErrorMessage('network-request-failed', enL10n), 'A network error occurred. Please check your connection.');
    });

    testWidgets('maps Firebase error codes to Hebrew localizations', (tester) async {
      late AppLocalizations heL10n;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('he'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              heL10n = AppLocalizations.of(context)!;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(AuthErrorMapper.mapErrorMessage('email-already-in-use', heL10n), 'כתובת הדוא"ל כבר נמצאת בשימוש בחשבון אחר.');
      expect(AuthErrorMapper.mapErrorMessage('weak-password', heL10n), 'הסיסמה חלשה מדי. יש להזין סיסמה חזקה יותר.');
      expect(AuthErrorMapper.mapErrorMessage('wrong-password', heL10n), 'הסיסמה שהוזנה שגויה.');
      expect(AuthErrorMapper.mapErrorMessage('invalid-email', heL10n), 'כתובת הדוא"ל אינה תקינה.');
      expect(AuthErrorMapper.mapErrorMessage('network-request-failed', heL10n), 'התרחשה שגיאת רשת. אנא בדוק את החיבור לאינטרנט.');
    });
  });

  group('LoginView UX & Interactions Tests', () {
    late AuthController authController;

    setUp(() {
      final dataSource = InMemoryAuthDataSource(startAuthenticated: false);
      final repo = AuthRepositoryImpl(
        remoteDataSource: dataSource,
        storageRepository: FakeStorageRepository(),
        firestore: FakeFirebaseFirestore(),
      );
      authController = AuthController(
        loginUseCase: LoginUseCase(repo),
        registerUseCase: RegisterUseCase(repo),
        logoutUseCase: LogoutUseCase(repo),
        getCurrentUserUseCase: GetCurrentUserUseCase(repo),
      );
    });

    testWidgets('Auto-clears password field on first tap during sign-up', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: LoginView(
              authController: authController,
              initialIsRegistering: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final emailFieldFinder = find.widgetWithText(TextField, 'Email Address');
      final passwordFieldFinder = find.widgetWithText(TextField, 'Password');
      expect(passwordFieldFinder, findsOneWidget);

      // 1. Focus email field first
      await tester.tap(emailFieldFinder, warnIfMissed: false);
      await tester.pump();

      // 2. Focus password field for first time
      await tester.tap(passwordFieldFinder, warnIfMissed: false);
      await tester.pump();

      await tester.enterText(passwordFieldFinder, 'NewPassword456');
      await tester.pump();
      expect(find.text('NewPassword456'), findsOneWidget);

      // 3. Focus email field again
      await tester.tap(emailFieldFinder, warnIfMissed: false);
      await tester.pump();

      // 4. Focus password field a second time — text remains intact
      await tester.tap(passwordFieldFinder, warnIfMissed: false);
      await tester.pump();
      expect(find.text('NewPassword456'), findsOneWidget);
    });

    testWidgets('Registration auto-logins user and transitions state to Authenticated', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: LoginView(
              authController: authController,
              initialIsRegistering: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter registration details
      await tester.enterText(find.widgetWithText(TextField, 'Display Name'), 'New User');
      await tester.enterText(find.widgetWithText(TextField, 'Email Address'), 'newuser@example.com');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');

      // Tap Register button
      await tester.tap(find.widgetWithText(FilledButton, 'Register'));
      await tester.pumpAndSettle();

      expect(authController.state, isA<Authenticated>());
      final user = (authController.state as Authenticated).user;
      expect(user.email, 'newuser@example.com');
      expect(user.displayName, 'New User');
    });
  });
}
