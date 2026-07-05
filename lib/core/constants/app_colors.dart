import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Educational Clean White Palette (Light) ---
  static const Color creamBg = Color(0xFFFFFFFF); // Clean white background
  static const Color creamSurface = Color(0xFFFFFFFF); // White cards/surfaces
  static const Color creamSurfaceDarker = Color(
    0xFFE6E9F0,
  ); // Outline & divider tint

  static const Color primaryClay = Color(0xFFFF6B6B); // Bright coral primary
  static const Color secondarySage = Color(
    0xFF4FB6FF,
  ); // Bright sky blue secondary
  static const Color tertiaryHoney = Color(
    0xFFFFD166,
  ); // Bright sunny yellow accent

  static const Color textCharcoal = Color(
    0xFF1F2328,
  ); // Charcoal for premium readability
  static const Color textMuted = Color(0xFF6B7280); // Subtitle gray
  static const Color white = Color(0xFFFFFFFF);

  // --- Premium Midnight Charcoal Palette (Dark) ---
  static const Color darkBg = Color(
    0xFF131418,
  ); // Sleek dark grey/charcoal background
  static const Color darkSurface = Color(0xFF1D1E24); // Sleek card dark color
  static const Color darkBorder = Color(0xFF2E313D); // Dark outlines

  static const Color darkPrimary = Color(
    0xFFFF8F87,
  ); // Coral for dark mode visibility
  static const Color darkSecondary = Color(0xFF6FC5FF); // Brighter sky blue
  static const Color darkTertiary = Color(0xFFFFD98A); // Soft sunny yellow

  static const Color darkText = Color(0xFFEBEFF5); // Soft bone white for text
  static const Color darkTextMuted = Color(0xFF9EA3AE); // Muted dark text
}
