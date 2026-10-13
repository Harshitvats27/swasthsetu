import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swasthsetu/core/theme/app_theme.dart';
import 'package:swasthsetu/features/auth/presentation/pages/pin_page.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: child,
    );

void main() {
  group('PinPage widget', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap(const PinPage()));
    });

    testWidgets('shows "Login with Fingerprint" text', (tester) async {
      await tester.pumpWidget(_wrap(const PinPage()));
      expect(find.text('Login with Fingerprint'), findsOneWidget);
    });

    testWidgets('shows fingerprint icon', (tester) async {
      await tester.pumpWidget(_wrap(const PinPage()));
      expect(find.byIcon(Icons.fingerprint), findsOneWidget);
    });

    testWidgets('shows exactly 4 PIN input boxes', (tester) async {
      await tester.pumpWidget(_wrap(const PinPage()));
      // Each box is a TextFormField
      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('shows "Not You ?" button', (tester) async {
      await tester.pumpWidget(_wrap(const PinPage()));
      expect(find.text('Not You ?'), findsOneWidget);
    });

    testWidgets('shows "Forgot Login PIN ?" button', (tester) async {
      await tester.pumpWidget(_wrap(const PinPage()));
      expect(find.text('Forgot Login PIN ?'), findsOneWidget);
    });

    testWidgets('shows "or" separator', (tester) async {
      await tester.pumpWidget(_wrap(const PinPage()));
      expect(find.text('or'), findsOneWidget);
    });

    testWidgets('shows emergency banner', (tester) async {
      await tester.pumpWidget(_wrap(const PinPage()));
      expect(find.text('Dial 24x7 Emergency'), findsOneWidget);
    });
  });
}
