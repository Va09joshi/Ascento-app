import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';

class AppTypography {
  AppTypography._();

  static String get fontFamily => GoogleFonts.outfit().fontFamily ?? 'Outfit';

  static TextTheme get lightTextTheme {
    return TextTheme(
      displayLarge: GoogleFonts.outfit(fontSize: 32.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.5),
      displayMedium: GoogleFonts.outfit(fontSize: 26.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.5),
      titleLarge: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.2),
      titleMedium: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      bodyLarge: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.normal, color: AppColors.textPrimary, height: 1.5),
      bodyMedium: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.normal, color: AppColors.textPrimary, height: 1.4),
      bodySmall: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
      labelLarge: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.onPrimary, letterSpacing: 0.2),
    );
  }

  static TextTheme get darkTextTheme {
    return TextTheme(
      displayLarge: GoogleFonts.outfit(fontSize: 32.sp, fontWeight: FontWeight.bold, color: AppColors.darkTextPrimary, letterSpacing: -0.5),
      displayMedium: GoogleFonts.outfit(fontSize: 26.sp, fontWeight: FontWeight.bold, color: AppColors.darkTextPrimary, letterSpacing: -0.5),
      titleLarge: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary, letterSpacing: -0.2),
      titleMedium: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
      bodyLarge: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.normal, color: AppColors.darkTextPrimary, height: 1.5),
      bodyMedium: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.normal, color: AppColors.darkTextPrimary, height: 1.4),
      bodySmall: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w500, color: AppColors.darkTextSecondary),
      labelLarge: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.darkOnPrimary, letterSpacing: 0.2),
    );
  }
}
