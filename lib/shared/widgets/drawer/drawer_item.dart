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
    final activeTextColor = baseColor; 
    
    final isActive = widget.active;
    final isHovered = _isHovered;

    final textColor = isActive 
        ? activeTextColor 
        : (isHovered ? hoverTextColor : unselectedTextColor);

    final iconColor = isActive 
        ? baseColor 
        : (isHovered ? baseColor : unselectedTextColor);

    final hoverBgColor = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03);

    return Container(
      margin: EdgeInsets.only(bottom: 4.h, left: 12.w, right: 12.w),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12.r),
            highlightColor: Colors.transparent,
            splashColor: hoverBgColor,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: isActive 
                    ? baseColor.withValues(alpha: 0.1) 
                    : (isHovered ? hoverBgColor : Colors.transparent),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
