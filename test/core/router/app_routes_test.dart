import 'package:flutter_test/flutter_test.dart';
import 'package:swasthsetu/core/router/app_routes.dart';

void main() {
  group('AppRoutes constants', () {
    test('splash is root /', () {
      expect(AppRoutes.splash, '/');
    });

    test('all auth routes start with /', () {
      final authRoutes = [
        AppRoutes.login,
        AppRoutes.pin,
      ];
      for (final r in authRoutes) {
        expect(r, startsWith('/'), reason: '$r must start with /');
      }
    });

    test('all routes are unique', () {
      final all = [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.pin,
        AppRoutes.shell,
        AppRoutes.home,
        AppRoutes.profile,
        AppRoutes.appointments,
        AppRoutes.bookAppointment,
        AppRoutes.doctors,
        AppRoutes.doctorDetail,
        AppRoutes.hospitalsQueue,
        AppRoutes.pharmacy,
        AppRoutes.sos,
        AppRoutes.chat,
        AppRoutes.aiSearch,
      ];
      expect(all.toSet().length, all.length,
          reason: 'Duplicate route paths detected');
    });

    test('feature routes are under their own prefix', () {
      expect(AppRoutes.bookAppointment, startsWith(AppRoutes.appointments));
      expect(AppRoutes.doctorDetail, startsWith(AppRoutes.doctors));
    });

    test('no route has trailing slash (except root)', () {
      final nonRoot = [
        AppRoutes.login,
        AppRoutes.pin,
        AppRoutes.home,
        AppRoutes.profile,
        AppRoutes.appointments,
        AppRoutes.doctors,
        AppRoutes.hospitalsQueue,
        AppRoutes.pharmacy,
        AppRoutes.sos,
        AppRoutes.chat,
        AppRoutes.aiSearch,
      ];
      for (final r in nonRoot) {
        expect(r.endsWith('/'), isFalse,
            reason: '$r must not have trailing slash');
      }
    });
  });
}
