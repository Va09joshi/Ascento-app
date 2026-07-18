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

    final baseColor = widget.isDanger ? AppColors.error : (widget.accent ?? const Color(0xFF5B67F4));
    final textColor = widget.isDanger 
        ? AppColors.error 
        : (isDark ? Colors.white70 : const Color(0xFF4B5563));
        
    final isActive = widget.active;
    final showHighlight = isActive || _isHovered;

    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(30.r),
            highlightColor: baseColor.withValues(alpha: 0.05),
            splashColor: baseColor.withValues(alpha: 0.1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.r),
                color: showHighlight 
                    ? baseColor.withValues(alpha: isActive ? 0.12 : 0.04) 
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    size: 22.r,
                    color: showHighlight ? baseColor : textColor.withValues(alpha: 0.8),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: theme.textTheme.titleSmall!.copyWith(
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                        color: showHighlight ? baseColor : textColor,
                        letterSpacing: 0.3,
                        fontSize: 14.sp,
                      ),
                      child: Text(widget.label),
                    ),
                  ),
                  if (isActive)
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: BoxDecoration(
                        color: baseColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: baseColor.withValues(alpha: 0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          )
                        ]
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
