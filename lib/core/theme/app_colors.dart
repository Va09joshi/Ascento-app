import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- LIGHT MODE (Premium Navy & Slate) ---
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color primary = Color(0xFF1E3A8A); // Premium Navy Blue
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF0F172A); // Slate 900
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color surfaceDarker = Color(0xFFF1F5F9); // Slate 100

  // --- DARK MODE (Deep Navy / Midnight) ---
  static const Color darkBackground = Color(0xFF020617); // Slate 950 (Midnight Navy)
  static const Color darkSurface = Color(0xFF0F172A); // Slate 900
  static const Color darkBorder = Color(0xFF1E293B); // Slate 800
  static const Color darkPrimary = Color(0xFF3B82F6); // Vibrant Blue for Dark Mode
  static const Color darkOnPrimary = Color(0xFFFFFFFF);
  static const Color darkSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkOnSecondary = Color(0xFF020617);
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkTextMuted = Color(0xFF64748B); // Slate 500
  static const Color darkSurfaceDarker = Color(0xFF1E293B); // Slate 800

  // --- SYSTEM COLORS ---
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444);   // Red
  static const Color info = Color(0xFF0EA5E9);    // Sky Blue
}

class AppGradients {
  AppGradients._();

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)], // Navy to Blue
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)], // Slate 900 to Slate 800
  );
}
