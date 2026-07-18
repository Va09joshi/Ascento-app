import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/shared/models/notice_model.dart';
import 'package:intl/intl.dart';

class AdminNoticeDetailsView extends StatelessWidget {
  final NoticeModel notice;
  const AdminNoticeDetailsView({super.key, required this.notice});

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'general': return Colors.blue;
      case 'academic': return Colors.green;
      case 'fees': return Colors.orange;
      case 'event': return Colors.purple;
      case 'update': return Colors.teal;
      case 'alert': return Colors.red;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _getTypeColor(notice.type);

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
            if (notice.bannerUrl != null && notice.bannerUrl!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 240.h,
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
                  image: DecorationImage(
                    image: NetworkImage(notice.bannerUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: notice.bannerUrl != null ? 8.h : 24.h),
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
                          notice.type.toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.sp,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      if (!notice.isPublished) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: AppColors.textMuted.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Text(
                            'DRAFT',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        notice.createdAt != null 
                          ? DateFormat('MMM dd, yyyy').format(notice.createdAt!) 
                          : 'Just now',
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
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Text(
                      notice.content,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 15.sp,
                      ),
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
