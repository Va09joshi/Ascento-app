import 'package:flutter/material.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/theme/app_radius.dart';
import 'package:ascento_abacus/core/theme/app_spacing.dart';
import 'package:ascento_abacus/core/theme/app_theme_extensions.dart';
import 'package:ascento_abacus/core/theme/app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTypography.fontFamily,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.surface,
        onPrimaryContainer: AppColors.primary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        tertiary: AppColors.info,
        onTertiary: AppColors.white,
        error: AppColors.error,
        onError: AppColors.white,
        surface: AppColors.background,
        onSurface: AppColors.textPrimary,
        outline: AppColors.border,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      dividerColor: AppColors.border,
    );

    return baseTheme.copyWith(
      textTheme: AppTypography.lightTextTheme,
      
      extensions: [
        ScholasticThemeExtension.light, // Future SaaS refactoring placeholder
      ],

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border, width: 1.0),
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.lightTextTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        shape: const Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.p24, vertical: AppSpacing.p16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTypography.lightTextTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.p24, vertical: AppSpacing.p16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTypography.lightTextTheme.labelLarge?.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          textStyle: AppTypography.lightTextTheme.titleMedium?.copyWith(
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTypography.fontFamily,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkOnPrimary,
        primaryContainer: AppColors.darkSurface,
        onPrimaryContainer: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        onSecondary: AppColors.darkOnSecondary,
        tertiary: AppColors.info,
        onTertiary: AppColors.white,
        error: AppColors.error,
        onError: AppColors.white,
        surface: AppColors.darkBackground,
        onSurface: AppColors.darkTextPrimary,
        outline: AppColors.darkBorder,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      dividerColor: AppColors.darkBorder,
    );

    return baseTheme.copyWith(
      textTheme: AppTypography.darkTextTheme,

      extensions: [
        ScholasticThemeExtension.dark,
      ],

      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.darkBorder, width: 1.0),
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.darkTextTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        shape: const Border(bottom: BorderSide(color: AppColors.darkBorder, width: 1.0)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.p24, vertical: AppSpacing.p16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTypography.darkTextTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.p24, vertical: AppSpacing.p16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTypography.darkTextTheme.labelLarge?.copyWith(
            color: AppColors.darkPrimary,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkTextSecondary,
          textStyle: AppTypography.darkTextTheme.titleMedium?.copyWith(
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
