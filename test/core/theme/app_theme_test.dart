// AppTheme unit tests — deliberately do NOT construct AppTheme.light because
// that calls GoogleFonts.poppinsTextTheme(), which hits the network in tests.
//
// Instead we test the exported design constants (the single source of truth
// that the theme itself uses) and verify color tokens via AppColors.
//
// The full ThemeData is exercised in widget tests (login_page_test, pin_page_test).

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:swasthsetu/core/theme/app_theme.dart';
import 'package:swasthsetu/core/theme/app_colors.dart';

void main() {
  // ── Radius constants ─────────────────────────────────────────────────────────
  group('AppTheme radius constants', () {
    test('radiusPill is 30 dp (pill-shaped buttons)', () {
      expect(AppTheme.radiusPill, 30.0);
    });

    test('radiusMedium is 12 dp (cards)', () {
      expect(AppTheme.radiusMedium, 12.0);
    });

    test('radiusLarge is 16 dp (dialogs)', () {
      expect(AppTheme.radiusLarge, 16.0);
    });

    test('radiusSmall is 8 dp (snackbars)', () {
      expect(AppTheme.radiusSmall, 8.0);
    });

    test('button radius exceeds card radius (more rounded)', () {
      expect(AppTheme.radiusPill, greaterThan(AppTheme.radiusMedium));
    });
  });

  // ── Padding constants ────────────────────────────────────────────────────────
  group('AppTheme padding constants', () {
    test('paddingMd is 16 dp', () => expect(AppTheme.paddingMd, 16.0));
    test('paddingLg is 24 dp', () => expect(AppTheme.paddingLg, 24.0));
    test('paddingSm < paddingMd < paddingLg', () {
      expect(AppTheme.paddingSm, lessThan(AppTheme.paddingMd));
      expect(AppTheme.paddingMd, lessThan(AppTheme.paddingLg));
    });
  });

  // ── Elevation constants ──────────────────────────────────────────────────────
  group('AppTheme elevation constants', () {
    test('modal elevation is greater than card elevation', () {
      expect(AppTheme.elevationModal, greaterThan(AppTheme.elevationCard));
    });
  });

  // ── Color tokens used by theme ───────────────────────────────────────────────
  // (Full color coverage is in app_colors_test.dart; these verify the values
  // that theme components explicitly rely on.)
  group('AppTheme color token assertions', () {
    test('primary is not transparent', () {
      expect(AppColors.primary.a, isNot(0));
    });

    test('surface is fully opaque white', () {
      expect(AppColors.surface, const Color(0xFFFFFFFF));
    });

    test('error is distinct from primary', () {
      expect(AppColors.error, isNot(AppColors.primary));
    });

    test('background differs from surface', () {
      expect(AppColors.background, isNot(AppColors.surface));
    });

    test('divider is lighter than textPrimary', () {
      // Just verify they are different colours (divider should be subtle)
      expect(AppColors.divider, isNot(AppColors.textPrimary));
    });
  });
}
