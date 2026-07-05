import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/theme/app_radius.dart';

/// Themed dropdown with consistent Ascento styling.
class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String label;
  final String hint;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;

  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    this.hint = 'Select an option',
    required this.itemLabel,
    required this.onChanged,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withValues(alpha: isDark ? 1.0 : 0.85),
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<T>(
          value: value,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: theme.colorScheme.primary, size: 20)
                : null,
            fillColor: isDark
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.r12.r),
              borderSide: BorderSide(color: theme.colorScheme.outline, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.r12.r),
              borderSide: BorderSide(color: theme.colorScheme.outline, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.r12.r),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(itemLabel(item)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Themed app bar with consistent Ascento styling.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? leading;

  const AppAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.onBack,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: showBack
          ? (leading ??
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: isDark ? Colors.white : AppColors.textCharcoal),
                onPressed: onBack ?? () => Navigator.maybePop(context),
              ))
          : null,
      actions: actions,
    );
  }
}

/// Empty state placeholder with illustration, message, and optional CTA.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.inbox_rounded,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkPrimary : AppColors.primaryClay).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56.r,
                  color: isDark ? AppColors.darkPrimary : AppColors.primaryClay),
            ),
            SizedBox(height: 24.h),
            Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            SizedBox(height: 8.h),
            Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center),
            if (actionText != null && onAction != null) ...[
              SizedBox(height: 24.h),
              TextButton(
                onPressed: onAction,
                child: Text(actionText!, style: TextStyle(
                  color: isDark ? AppColors.darkPrimary : AppColors.primaryClay,
                  fontWeight: FontWeight.bold,
                )),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
