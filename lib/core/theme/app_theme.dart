import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// The single source-of-truth [ThemeData] for SwasthSetu.
/// Mirrors the visual language of the Aadhar Health Institute app:
///   • Navy-blue (#1A3A6E) primary
///   • Off-white (#F4F6FA) scaffold background
///   • Rounded cards (12 dp) and pill buttons (30 dp radius)
///   • Poppins typeface throughout
abstract final class AppTheme {
  // ── Dimensions ─────────────────────────────────────────────────────────────
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusPill = 30;

  static const double paddingXs = 4;
  static const double paddingSm = 8;
  static const double paddingMd = 16;
  static const double paddingLg = 24;
  static const double paddingXl = 32;

  static const double elevationCard = 2;
  static const double elevationModal = 8;

  // ── Light theme ────────────────────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.white,
        secondary: AppColors.accent,
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.iconBlue,
        onSecondaryContainer: AppColors.primary,
        tertiary: AppColors.emergency,
        onTertiary: AppColors.white,
        error: AppColors.error,
        onError: AppColors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        outline: AppColors.divider,
      ),
      scaffoldBackgroundColor: AppColors.background,
      // ── Typography ─────────────────────────────────────────────────────────
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineSmall,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppColors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      // ── Bottom nav ─────────────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.bottomNavUnselected,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      // ── Card ───────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: elevationCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: paddingMd,
          vertical: paddingSm,
        ),
      ),
      // ── Elevated button ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.divider,
          elevation: 0,
          textStyle: AppTextStyles.buttonLabel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: paddingLg,
            vertical: paddingMd,
          ),
        ),
      ),
      // ── Outlined button ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppTextStyles.buttonLabel.copyWith(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: paddingLg,
            vertical: paddingMd,
          ),
        ),
      ),
      // ── Text button ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: AppTextStyles.link,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingSm,
            vertical: paddingXs,
          ),
        ),
      ),
      // ── Input / TextField ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: paddingMd,
          vertical: 14,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textHint,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      // ── Chip ───────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        labelStyle: AppTextStyles.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPill),
          side: BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: paddingMd,
          vertical: paddingSm,
        ),
      ),
      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),
      // ── Dialog ─────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: elevationModal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        titleTextStyle: AppTextStyles.headlineSmall,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),
      // ── SnackBar ───────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return base;
  }
}
