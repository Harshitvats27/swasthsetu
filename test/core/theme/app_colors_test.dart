import 'package:flutter_test/flutter_test.dart';
import 'package:swasthsetu/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

void main() {
  group('AppColors', () {
    test('primary is navy blue #1A3A6E', () {
      expect(AppColors.primary, const Color(0xFF1A3A6E));
    });

    test('emergency is red #E53935', () {
      expect(AppColors.emergency, const Color(0xFFE53935));
    });

    test('background is off-white #F4F6FA', () {
      expect(AppColors.background, const Color(0xFFF4F6FA));
    });

    test('surface is pure white', () {
      expect(AppColors.surface, const Color(0xFFFFFFFF));
    });

    test('accent differs from primary', () {
      expect(AppColors.accent, isNot(AppColors.primary));
    });

    test('bottomNavSelected equals primary', () {
      expect(AppColors.bottomNavSelected, AppColors.primary);
    });
  });
}
