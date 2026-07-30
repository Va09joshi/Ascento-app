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

    // Corkboard/Wood background colors
    final bgColor = isDark ? const Color(0xFF2D1A11) : const Color(0xFFE3C9A6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Notice Board',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.brown.shade800,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white70 : Colors.brown.shade800),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // The Paper Card (Slightly rotated for realism)
                Transform.rotate(
                  angle: 0.02, // slight tilt
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 16.h),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFFDFBF7), // Warm paper color
                      borderRadius: BorderRadius.circular(2.r), // Sharp paper edges
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(4, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (notice.imageUrl != null && notice.imageUrl!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.all(16.w),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: InteractiveViewer(
                                child: Image.network(
                                  notice.imageUrl!,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: 250.h,
                                ),
                              ),
                            ),
                          ),
                        
                        Padding(
                          padding: EdgeInsets.fromLTRB(24.w, notice.imageUrl != null ? 8.h : 32.h, 24.w, 32.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.1),
                                      border: Border.all(color: color.withValues(alpha: 0.5)),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      notice.type.name.toUpperCase(),
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10.sp,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd MMM, yyyy').format(notice.createdAt),
                                    style: TextStyle(
                                      color: isDark ? Colors.white54 : Colors.black54,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Courier', // Typewriter feel
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24.h),
                              Text(
                                notice.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : Colors.black87,
                                  height: 1.3,
                                  fontFamily: 'Georgia',
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Divider(color: isDark ? Colors.white24 : Colors.black12, thickness: 2),
                              SizedBox(height: 16.h),
                              Text(
                                notice.body,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.8,
                                  color: isDark ? Colors.white70 : const Color(0xFF2C3E50),
                                  fontSize: 15.sp,
                                  fontFamily: 'Georgia', 
                                ),
                              ),
                              SizedBox(height: 40.h),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Regards,',
                                      style: TextStyle(
                                        color: isDark ? Colors.white54 : Colors.black54,
                                        fontSize: 14.sp,
                                        fontStyle: FontStyle.italic,
                                        fontFamily: 'Georgia',
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Ascento Abacus\nAdministration',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: isDark ? Colors.white70 : Colors.black87,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Georgia',
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // The Pushpin
                Positioned(
                  top: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(1, 3),
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.push_pin_rounded,
                      color: Colors.redAccent.shade700,
                      size: 36.r,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
