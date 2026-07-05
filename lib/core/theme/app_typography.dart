import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';

class AppTypography {
  AppTypography._();

  // Primary scholastic typeface family
  static String get fontFamily =>
      GoogleFonts.fredoka().fontFamily ?? 'Fredoka';

  // --- LIGHT TEXT THEME SCHEME ---
  static TextTheme get lightTextTheme {
    return TextTheme(
      displayLarge: GoogleFonts.fredoka(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textCharcoal,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.fredoka(
        fontSize: 26.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textCharcoal,
        letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.fredoka(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textCharcoal,
        letterSpacing: -0.2,
      ),
      titleMedium: GoogleFonts.fredoka(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textCharcoal,
      ),
      bodyLarge: GoogleFonts.fredoka(
        fontSize: 15.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.textCharcoal,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.fredoka(
        fontSize: 13.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.textCharcoal,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.fredoka(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      ),
      labelLarge: GoogleFonts.fredoka(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
        letterSpacing: 0.5,
      ),
    );
  }

  // --- DARK TEXT THEME SCHEME ---
  static TextTheme get darkTextTheme {
    return TextTheme(
      displayLarge: GoogleFonts.fredoka(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.fredoka(
        fontSize: 26.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
        letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.fredoka(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
        letterSpacing: -0.2,
      ),
      titleMedium: GoogleFonts.fredoka(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      ),
      bodyLarge: GoogleFonts.fredoka(
        fontSize: 15.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.darkText,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.fredoka(
        fontSize: 13.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.darkText,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.fredoka(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextMuted,
      ),
      labelLarge: GoogleFonts.fredoka(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.darkBg,
        letterSpacing: 0.5,
      ),
    );
  }
}
