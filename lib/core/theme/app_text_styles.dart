import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralised text-style definitions for the SwasthSetu app.
/// Base typeface: Poppins (from Google Fonts) — matches the clean,
/// rounded look used in the Aadhar Health Institute app.
abstract final class AppTextStyles {
  // ── Display / Hero ─────────────────────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get displayMedium => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.25,
      );

  // ── Headings ───────────────────────────────────────────────────────────────
  static TextStyle get headlineLarge => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineSmall => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // ── Title ──────────────────────────────────────────────────────────────────
  static TextStyle get titleLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle get titleSmall => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.1,
      );

  // ── Body ───────────────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // ── Label / Caption ────────────────────────────────────────────────────────
  static TextStyle get labelLarge => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        letterSpacing: 0.5,
      );

  static TextStyle get labelMedium => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      );

  static TextStyle get labelSmall => GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      );

  // ── Specialty styles ───────────────────────────────────────────────────────

  /// Blue link / "View All" text
  static TextStyle get link => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.accent,
      );

  /// OTP / PIN digit box text
  static TextStyle get pinDigit => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  /// Emergency banner text
  static TextStyle get emergencyBanner => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.emergency,
      );

  /// Button label — used on filled primary buttons
  static TextStyle get buttonLabel => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        letterSpacing: 0.3,
      );
}
