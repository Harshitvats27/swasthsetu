import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:swasthsetu/core/theme/app_theme.dart';
import 'package:swasthsetu/features/auth/presentation/pages/login_page.dart';

// Wraps a widget with a minimal MaterialApp (no router) for most tests.
Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: child,
    );

// Wraps with a real GoRouter so context.go works in navigation tests.
Widget _wrapWithRouter(Widget child) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [GoRoute(path: '/', builder: (_, __) => child)],
  );
  return MaterialApp.router(
    theme: AppTheme.light,
    routerConfig: router,
  );
}

void main() {
  group('LoginPage widget', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap(const LoginPage()));
      // No exception = pass
    });

    testWidgets('shows the Send OTP button', (tester) async {
      await tester.pumpWidget(_wrap(const LoginPage()));
      expect(find.widgetWithText(ElevatedButton, 'Send OTP'), findsOneWidget);
    });

    testWidgets('shows a phone number text field', (tester) async {
      await tester.pumpWidget(_wrap(const LoginPage()));
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('shows +91 country code prefix', (tester) async {
      await tester.pumpWidget(_wrap(const LoginPage()));
      expect(find.text('+91'), findsOneWidget);
    });

    testWidgets('shows Dial 24x7 Emergency banner', (tester) async {
      await tester.pumpWidget(_wrap(const LoginPage()));
      expect(find.text('Dial 24x7 Emergency'), findsOneWidget);
    });

    testWidgets('shows follow us on social row', (tester) async {
      await tester.pumpWidget(_wrap(const LoginPage()));
      expect(find.text('follow us on'), findsOneWidget);
    });

    testWidgets('shows validation error on empty submit', (tester) async {
      await tester.pumpWidget(_wrap(const LoginPage()));
      // Tap button without entering a number
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send OTP'));
      await tester.pump(); // let form validate
      expect(
        find.text('Enter a valid 10-digit mobile number'),
        findsOneWidget,
      );
    });

    testWidgets('shows validation error for short phone number', (tester) async {
      await tester.pumpWidget(_wrap(const LoginPage()));
      await tester.enterText(find.byType(TextFormField), '98765');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send OTP'));
      await tester.pump();
      expect(
        find.text('Enter a valid 10-digit mobile number'),
        findsOneWidget,
      );
    });

    testWidgets('accepts exactly 10 digits without showing error', (tester) async {
      // Use router-aware wrapper so context.go(AppRoutes.otp) works
      await tester.pumpWidget(_wrapWithRouter(const LoginPage()));
      await tester.enterText(find.byType(TextFormField), '9876543210');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Send OTP'));
      await tester.pump(); // form validates — no error message
      expect(
        find.text('Enter a valid 10-digit mobile number'),
        findsNothing,
      );
      // Drain the 1-second navigation timer
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
