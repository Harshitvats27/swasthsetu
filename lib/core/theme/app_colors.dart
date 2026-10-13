import 'package:flutter/material.dart';

/// Design-token colours extracted from the Aadhar Health Institute screenshots.
///
/// Primary brand navy-blue (#1A3A6E) — app bars, CTAs, pill buttons.
/// Accent vivid-blue (#1565C0 / #1877F2 shade) — links, icon backgrounds.
/// Emergency red (#E53935) — SOS, emergency banner.
/// Background off-white (#F4F6FA) — page background.
/// Card white (#FFFFFF) with subtle shadow.
/// Text dark (#1A1A2E) and medium-grey (#607D8B).
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A3A6E); // Navy blue (header / CTA)
  static const Color primaryDark = Color(0xFF102850); // Darker variant
  static const Color primaryLight = Color(0xFF2B5BA8); // Lighter variant

  static const Color accent = Color(0xFF1565C0); // Vivid blue (links / icons)
  static const Color accentLight = Color(0xFF1877F2); // Bright blue (Send OTP)

  // ── Functional ─────────────────────────────────────────────────────────────
  static const Color emergency = Color(0xFFE53935); // Emergency banner / SOS
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFD32F2F);

  // ── Neutrals ───────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF4F6FA); // Page background
  static const Color surface = Color(0xFFFFFFFF); // Cards / sheets
  static const Color surfaceVariant = Color(0xFFEAEDF3); // Chip backgrounds
  static const Color divider = Color(0xFFDDE1EA);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E); // Headings
  static const Color textSecondary = Color(0xFF607D8B); // Subtitles / labels
  static const Color textHint = Color(0xFFADB5BD); // Placeholder

  // ── Icon accent circles (home grid) ────────────────────────────────────────
  static const Color iconBlue = Color(0xFFBBDEFB);
  static const Color iconPink = Color(0xFFF8BBD0);
  static const Color iconTeal = Color(0xFFB2EBF2);
  static const Color iconYellow = Color(0xFFFFF9C4);
  static const Color iconGreen = Color(0xFFC8E6C9);

  // ── Misc ───────────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // ── Bottom-nav ─────────────────────────────────────────────────────────────
  static const Color bottomNavSelected = primary;
  static const Color bottomNavUnselected = Color(0xFF90A4AE);
}
