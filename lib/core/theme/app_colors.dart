import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- LIGHT MODE (Clean White Academic) ---
  static const Color creamBg = Color(0xFFFFFFFF); // Clean white background
  static const Color creamSurface = Color(0xFFFFFFFF); // White surface cards
  static const Color creamBorder = Color(0xFFE6E9F0); // Soft neutral border
  static const Color primaryClay = Color(0xFFFF6B6B); // Bright coral primary
  static const Color secondarySage = Color(0xFF4FB6FF); // Sky blue secondary
  static const Color tertiaryHoney = Color(
    0xFFFFD166,
  ); // Bright sunny yellow accent
  static const Color textCharcoal = Color(0xFF1F2328); // Deep charcoal text
  static const Color textMuted = Color(0xFF6B7280); // Neutral gray for subtext

  // --- DARK MODE (Midnight Slate ERP) ---
  static const Color darkBg = Color(
    0xFF121215,
  ); // Midnight slate black background
  static const Color darkSurface = Color(
    0xFF1A1A1F,
  ); // Dark slate card surface panel
  static const Color darkBorder = Color(0xFF2D2D36); // Cool outline dark border
  static const Color darkPrimary = Color(
    0xFFFF8F87,
  ); // Coral for dark mode visibility
  static const Color darkSecondary = Color(0xFF6FC5FF); // Brighter sky blue
  static const Color darkTertiary = Color(0xFFFFD98A); // Soft sunny yellow
  static const Color darkText = Color(
    0xFFF0EFEA,
  ); // Eggshell white high contrast text
  static const Color darkTextMuted = Color(
    0xFFA09F98,
  ); // Soft silver-gray for secondary text

  // --- COMMON SYSTEM COLORS ---
  static const Color white = Color(0xFFFFFFFF);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color successGreen = Color(0xFF388E3C);
}

class AppGradients {
  AppGradients._();

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primaryClay,
      Color(0xFFFF8F87),
    ],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.secondarySage,
      Color(0xFF8AD1FF),
    ],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF23232A),
      Color(0xFF1A1A1F),
    ],
  );
}
