import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:intl/intl.dart';

class NoticeDetailsView extends StatelessWidget {
  final NotificationItem notice;
  const NoticeDetailsView({super.key, required this.notice});

  Color _typeColor() {
    switch (notice.type) {
      case NotificationType.fees: return AppColors.info;
      case NotificationType.homework: return AppColors.primary;
      case NotificationType.event: return const Color(0xFF7E57C2);
      case NotificationType.attendance: return AppColors.error;
      case NotificationType.academic: return AppColors.secondary;
      case NotificationType.general: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _typeColor();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notice Details',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notice.imageUrl != null && notice.imageUrl!.isNotEmpty)
              Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: InteractiveViewer(
                    child: Image.network(
                      notice.imageUrl!,
                      fit: BoxFit.contain, // Ensures the whole image is visible without cropping
                      width: double.infinity,
                      // Let height be determined by image aspect ratio if possible, 
                      // but limit max height so it doesn't overflow screen
                      height: 300.h, 
                    ),
                  ),
                ),
              ),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: notice.imageUrl != null ? 8.h : 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Text(
                          notice.type.name.toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.sp,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('MMM dd, yyyy • hh:mm a').format(notice.createdAt),
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    notice.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAFAFA), // Paper-like color
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isDark ? Colors.white10 : const Color(0xFFE0E0E0),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Accent top bar (Letterhead style)
                        Container(
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OFFICIAL NOTICE',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                  fontSize: 11.sp,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'From: Administration',
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black54,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Divider(color: isDark ? Colors.white24 : Colors.black12),
                              SizedBox(height: 16.h),
                              Text(
                                notice.body,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.8, // More readable line height
                                  color: isDark ? Colors.white70 : const Color(0xFF2C3E50),
                                  fontSize: 15.sp,
                                  fontFamily: 'Georgia', // Serif font for realistic letter feel (if available)
                                ),
                              ),
                              SizedBox(height: 32.h),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Ascento Abacus\nManagement Team',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: isDark ? Colors.white54 : Colors.black54,
                                    fontSize: 13.sp,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
