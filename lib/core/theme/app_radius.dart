import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppRadius {
  AppRadius._();

  // --- RAW CORNER RADIUS VALUES ---
  static double get r4 => 4.r;
  static double get r8 => 8.r;
  static double get r12 => 12.r;
  static double get r16 => 16.r;
  static double get r24 => 24.r;
  static double get r32 => 32.r;

  // --- BORDER RADIUS SHORTCUTS ---
  static BorderRadius get radius4 => BorderRadius.circular(4.r);
  static BorderRadius get radius8 => BorderRadius.circular(8.r);
  static BorderRadius get radius12 => BorderRadius.circular(12.r);
  static BorderRadius get radius16 => BorderRadius.circular(16.r);
  static BorderRadius get radius24 => BorderRadius.circular(24.r);
  static BorderRadius get radius32 => BorderRadius.circular(32.r);

  // --- ROUNDED RECTANGLE SHAPES FOR MATERIAL 3 ---
  static RoundedRectangleBorder get shape4 => RoundedRectangleBorder(borderRadius: radius4);
  static RoundedRectangleBorder get shape8 => RoundedRectangleBorder(borderRadius: radius8);
  static RoundedRectangleBorder get shape12 => RoundedRectangleBorder(borderRadius: radius12);
  static RoundedRectangleBorder get shape16 => RoundedRectangleBorder(borderRadius: radius16);
  static RoundedRectangleBorder get shape24 => RoundedRectangleBorder(borderRadius: radius24);
  static RoundedRectangleBorder get shape32 => RoundedRectangleBorder(borderRadius: radius32);
}
