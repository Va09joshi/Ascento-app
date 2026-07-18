import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';

class DrawerSection extends StatelessWidget {
  final String title;
  const DrawerSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 18.w, top: 24.h, bottom: 8.h),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 1.5,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkTextMuted.withValues(alpha: 0.6)
              : AppColors.textMuted.withValues(alpha: 0.6),
          fontSize: 10.sp,
        ),
      ),
    );
  }
}
