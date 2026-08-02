import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_explore/app.dart';
import 'package:shopping_explore/features/auth/presentation/views/login_view.dart';
import 'package:shopping_explore/features/auth/presentation/widgets/auth_user_button.dart';

void main() {
  group('ShoppingExploreApp Auth Wiring & UI Tests', () {
    testWidgets('App renders Sign In and Sign Up buttons in Hebrew by default', (tester) async {
      await tester.pumpWidget(const ShoppingExploreApp());
      await tester.pumpAndSettle();

      expect(find.byType(AuthUserButton), findsOneWidget);
      expect(find.text('התחבר'), findsWidgets);
      expect(find.text('הרשם'), findsOneWidget);
    });

    testWidgets('Tapping Sign In opens LoginView in Sign In mode', (tester) async {
      await tester.pumpWidget(const ShoppingExploreApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('התחבר').first);
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsOneWidget);
      expect(find.text('שם תצוגה'), findsNothing);
    });

    testWidgets('Tapping Sign Up opens LoginView in Register mode with Display Name field', (tester) async {
      await tester.pumpWidget(const ShoppingExploreApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('הרשם'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsOneWidget);
      expect(find.text('שם תצוגה'), findsOneWidget);
    });
  });
}
