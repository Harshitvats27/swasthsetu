import 'package:flutter_test/flutter_test.dart';
import 'package:swasthsetu/core/errors/failures.dart';

void main() {
  // ── NetworkFailure ──────────────────────────────────────────────────────────
  group('NetworkFailure', () {
    test('has a default message', () {
      const f = NetworkFailure();
      expect(f.message, isNotEmpty);
    });

    test('two instances with same message are equal', () {
      const a = NetworkFailure();
      const b = NetworkFailure();
      expect(a, equals(b));
    });

    test('accepts a custom message', () {
      const f = NetworkFailure(message: 'Custom network error');
      expect(f.message, 'Custom network error');
    });
  });

  // ── ServerFailure ───────────────────────────────────────────────────────────
  group('ServerFailure', () {
    test('statusCode is included in props', () {
      const f = ServerFailure(statusCode: 500);
      expect(f.props, contains(500));
    });

    test('two instances with different statusCode are not equal', () {
      const a = ServerFailure(statusCode: 404);
      const b = ServerFailure(statusCode: 500);
      expect(a, isNot(equals(b)));
    });

    test('statusCode can be null', () {
      const f = ServerFailure();
      expect(f.statusCode, isNull);
    });
  });

  // ── AuthFailure ─────────────────────────────────────────────────────────────
  group('AuthFailure', () {
    test('message and code are in props', () {
      const f = AuthFailure(message: 'invalid-otp', code: 'auth/invalid-code');
      expect(f.props, containsAll(['invalid-otp', 'auth/invalid-code']));
    });

    test('two AuthFailures with same message but different code differ', () {
      const a = AuthFailure(message: 'err', code: 'code-a');
      const b = AuthFailure(message: 'err', code: 'code-b');
      expect(a, isNot(equals(b)));
    });
  });

  // ── ValidationFailure ───────────────────────────────────────────────────────
  group('ValidationFailure', () {
    test('carries the validation message', () {
      const f = ValidationFailure(message: 'Phone must be 10 digits');
      expect(f.message, 'Phone must be 10 digits');
    });
  });

  // ── Failure is abstract ─────────────────────────────────────────────────────
  group('Failure hierarchy', () {
    test('all failures extend Failure', () {
      const failures = [
        NetworkFailure(),
        ServerFailure(),
        CacheFailure(),
        ValidationFailure(message: 'x'),
        NotFoundFailure(),
        PermissionFailure(),
        UnexpectedFailure(),
      ];
      for (final f in failures) {
        expect(f, isA<Failure>());
      }
    });
  });
}
