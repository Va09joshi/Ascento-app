import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';

class DrawerItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color? accent;
  final VoidCallback onTap;
  final bool isDanger;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.accent,
    this.isDanger = false,
  });

  @override
  State<DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<DrawerItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = widget.isDanger ? AppColors.error : (widget.accent ?? AppColors.primary);
    
    final unselectedTextColor = isDark ? Colors.white60 : Colors.black54;
    final hoverTextColor = isDark ? Colors.white : Colors.black;
    final activeTextColor = Colors.white; // Pure white for solid background
    
    final isActive = widget.active;
    final isHovered = _isHovered;

    final textColor = isActive 
        ? activeTextColor 
        : (isHovered ? hoverTextColor : unselectedTextColor);

    final iconColor = isActive 
        ? Colors.white 
        : (isHovered ? baseColor : unselectedTextColor);

    final hoverBgColor = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03);
    final activeBgColor = baseColor; // Solid color for active state

    return Container(
      margin: EdgeInsets.only(bottom: 6.h, left: 16.w, right: 16.w),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(14.r), // slightly rounder
            highlightColor: activeBgColor.withValues(alpha: 0.1),
            splashColor: activeBgColor.withValues(alpha: 0.2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                color: isActive 
                    ? activeBgColor 
                    : (isHovered ? hoverBgColor : Colors.transparent),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: baseColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ] : [],
              ),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    size: 22.r,
                    color: iconColor,
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: theme.textTheme.titleSmall!.copyWith(
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: textColor,
                        fontSize: 14.sp,
                        letterSpacing: 0.2,
                      ),
                      child: Text(widget.label),
                    ),
                  ),
                  if (isActive)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 14.r,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
