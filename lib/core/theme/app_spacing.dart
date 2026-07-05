import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSpacing {
  AppSpacing._();

  // --- RAW DYNAMIC SPACINGS (Padding/Margins) ---
  static double get p4 => 4.r;
  static double get p8 => 8.r;
  static double get p12 => 12.r;
  static double get p16 => 16.r;
  static double get p20 => 20.r;
  static double get p24 => 24.r;
  static double get p32 => 32.r;
  static double get p40 => 40.r;
  static double get p48 => 48.r;

  // --- VERTICAL SPACER HELPER SHORTCUTS ---
  static Widget get h4 => SizedBox(height: 4.h);
  static Widget get h8 => SizedBox(height: 8.h);
  static Widget get h12 => SizedBox(height: 12.h);
  static Widget get h16 => SizedBox(height: 16.h);
  static Widget get h20 => SizedBox(height: 20.h);
  static Widget get h24 => SizedBox(height: 24.h);
  static Widget get h32 => SizedBox(height: 32.h);
  static Widget get h40 => SizedBox(height: 40.h);
  static Widget get h48 => SizedBox(height: 48.h);

  // --- HORIZONTAL SPACER HELPER SHORTCUTS ---
  static Widget get w4 => SizedBox(width: 4.w);
  static Widget get w8 => SizedBox(width: 8.w);
  static Widget get w12 => SizedBox(width: 12.w);
  static Widget get w16 => SizedBox(width: 16.w);
  static Widget get w20 => SizedBox(width: 20.w);
  static Widget get w24 => SizedBox(width: 24.w);
  static Widget get w32 => SizedBox(width: 32.w);
}
