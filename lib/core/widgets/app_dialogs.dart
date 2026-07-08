import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';

/// Themed dialog helper methods for Ascento Abacus.
///
/// Usage:
/// ```dart
/// AppDialog.show(context, title: 'Confirm', message: 'Are you sure?',
///   confirmText: 'Yes', onConfirm: () => doAction());
///
/// AppDialog.confirm(context, message: 'Delete this item?')
///   .then((confirmed) { if (confirmed) deleteItem(); });
/// ```
class AppDialog {
  AppDialog._();

  /// Shows a themed alert dialog with optional confirm/cancel actions.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'OK',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDismissible = true,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showDialog(
      context: context,
      barrierDismissible: isDismissible,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        content: Text(message, style: theme.textTheme.bodyMedium),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () { Navigator.pop(ctx); onCancel?.call(); },
              child: Text(cancelText, style: TextStyle(color: Colors.grey.shade600)),
            ),
          TextButton(
            onPressed: () { Navigator.pop(ctx); onConfirm?.call(); },
            child: Text(confirmText, style: TextStyle(
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
              fontWeight: FontWeight.bold,
            )),
          ),
        ],
      ),
    );
  }

  /// Returns `true` if the user confirms, `false` otherwise.
  static Future<bool> confirm(
    BuildContext context, {
    String title = 'Confirm Action',
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'Cancel',
  }) async {
    bool confirmed = false;
    await show(
      context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: () => confirmed = true,
    );
    return confirmed;
  }
}

/// Themed snackbar helper with success, error, and info variants.
class AppSnackbar {
  AppSnackbar._();

  static void show(BuildContext context, {required String message, Duration? duration}) {
    _show(context, message: message, icon: Icons.info_outline, color: AppColors.primary, duration: duration);
  }

  static void success(BuildContext context, {required String message}) {
    _show(context, message: message, icon: Icons.check_circle_outline, color: AppColors.secondary);
  }

  static void error(BuildContext context, {required String message}) {
    _show(context, message: message, icon: Icons.error_outline, color: AppColors.error);
  }

  static void warning(BuildContext context, {required String message}) {
    _show(context, message: message, icon: Icons.warning_amber_rounded, color: AppColors.info);
  }

  static void _show(BuildContext context, {required String message, required IconData icon, required Color color, Duration? duration}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            SizedBox(width: 12.w),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        margin: EdgeInsets.all(16.w),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
}

/// Themed bottom sheet helper.
class AppBottomSheet {
  AppBottomSheet._();

  /// Shows a modal bottom sheet with consistent theming.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool isScrollControlled = true,
    double? maxHeight,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      constraints: maxHeight != null ? BoxConstraints(maxHeight: maxHeight) : null,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
