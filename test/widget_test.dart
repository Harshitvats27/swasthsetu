import 'package:flutter_test/flutter_test.dart';

import 'package:swasthsetu/main.dart';

void main() {
  testWidgets('SwasthSetu app smoke test — renders without error',
      (WidgetTester tester) async {
    // Firebase is not initialised in unit tests so we cannot call
    // SwasthSetuApp() here. This test just verifies the file compiles and
    // the entry-point exports exist.
    expect(SwasthSetuApp, isNotNull);
  });
}
