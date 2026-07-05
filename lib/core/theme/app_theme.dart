import 'package:flutter/material.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/theme/app_radius.dart';
import 'package:ascento_abacus/core/theme/app_spacing.dart';
import 'package:ascento_abacus/core/theme/app_theme_extensions.dart';
import 'package:ascento_abacus/core/theme/app_typography.dart';

class AppTheme {
  AppTheme._();

  // --- WHITE CREAM EDUCATIONAL LIGHT THEME ---
  static ThemeData lightTheme() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryClay,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.creamSurface,
        onPrimaryContainer: AppColors.primaryClay,
        secondary: AppColors.secondarySage,
        onSecondary: AppColors.white,
        tertiary: AppColors.tertiaryHoney,
        onTertiary: AppColors.white,
        error: AppColors.errorRed,
        onError: AppColors.white,
        surface: AppColors.creamBg,
        onSurface: AppColors.textCharcoal,
        outline: AppColors.creamBorder,
      ),
      scaffoldBackgroundColor: AppColors.creamBg,
      dividerColor: AppColors.creamBorder,
    );

    return baseTheme.copyWith(
      textTheme: AppTypography.lightTextTheme,
      
      // Theme extensions registration
      extensions: [
        ScholasticThemeExtension.light,
      ],

      cardTheme: CardThemeData(
        color: AppColors.creamSurface,
        elevation: 0,
        shape: AppRadius.shape16.copyWith(
          side: const BorderSide(color: AppColors.creamBorder, width: 1.5),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.creamBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.lightTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.textCharcoal),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryClay,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.p24, vertical: AppSpacing.p16),
          shape: AppRadius.shape12,
          textStyle: AppTypography.lightTextTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryClay,
          side: const BorderSide(color: AppColors.primaryClay, width: 1.8),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.p24, vertical: AppSpacing.p16),
          shape: AppRadius.shape12,
          textStyle: AppTypography.lightTextTheme.labelLarge?.copyWith(
            color: AppColors.primaryClay,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondarySage,
          textStyle: AppTypography.lightTextTheme.titleMedium?.copyWith(
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // --- MIDNIGHT CHARCOAL SLATE DARK THEME ---
  static ThemeData darkTheme() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkBg,
        primaryContainer: AppColors.darkSurface,
        onPrimaryContainer: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        onSecondary: AppColors.darkBg,
        tertiary: AppColors.darkTertiary,
        onTertiary: AppColors.darkBg,
        error: AppColors.errorRed,
        onError: AppColors.white,
        surface: AppColors.darkBg,
        onSurface: AppColors.darkText,
        outline: AppColors.darkBorder,
      ),
      scaffoldBackgroundColor: AppColors.darkBg,
      dividerColor: AppColors.darkBorder,
    );

    return baseTheme.copyWith(
      textTheme: AppTypography.darkTextTheme,

      // Theme extensions registration
      extensions: [
        ScholasticThemeExtension.dark,
      ],

      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: AppRadius.shape16.copyWith(
          side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.darkTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkText),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkBg,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.p24, vertical: AppSpacing.p16),
          shape: AppRadius.shape12,
          textStyle: AppTypography.darkTextTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          side: const BorderSide(color: AppColors.darkPrimary, width: 1.8),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.p24, vertical: AppSpacing.p16),
          shape: AppRadius.shape12,
          textStyle: AppTypography.darkTextTheme.labelLarge?.copyWith(
            color: AppColors.darkPrimary,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkSecondary,
          textStyle: AppTypography.darkTextTheme.titleMedium?.copyWith(
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
