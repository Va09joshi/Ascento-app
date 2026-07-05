import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/theme/app_radius.dart';

/// Themed card with soft shadow, rounded corners, and optional tap handler.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? EdgeInsets.only(bottom: 12.h),
        padding: padding ?? EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color:
              color ??
              (isDark ? AppColors.darkSurface : AppColors.creamSurface),
          borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.r16.r),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.creamBorder,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : AppColors.textCharcoal)
                  .withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
