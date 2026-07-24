import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/shared/models/user_model.dart';
import 'package:ascento_abacus/core/widgets/app_components.dart';

class UserDetailsView extends StatelessWidget {
  final UserModel user;

  const UserDetailsView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppAppBar(
        title: 'User Details',
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                ],
              ),
              padding: EdgeInsets.all(32.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with Avatar and Name
                  Row(
                    children: [
                      if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                        ClipOval(
                          child: Image.network(
                            user.avatarUrl!,
                            width: 80.r,
                            height: 80.r,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(user),
                          ),
                        )
                      else
                        _buildFallbackAvatar(user),
                      SizedBox(width: 24.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: AppColors.info.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                user.role.name.toUpperCase(),
                                style: TextStyle(
                                  color: AppColors.info,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 48.h),
                  // Details List
                  _buildDetailRow(context, Icons.badge_rounded, 'User ID', user.id),
                  _buildDetailRow(context, Icons.email_rounded, 'Email', user.email),
                  _buildDetailRow(context, Icons.phone_rounded, 'Phone', user.phone ?? 'N/A'),
                  if (user.role == UserRole.student) ...[
                    _buildDetailRow(context, Icons.class_rounded, 'Class', user.className ?? 'Not assigned'),
                    _buildDetailRow(context, Icons.group_work_rounded, 'Section', user.sectionName ?? 'Not assigned'),
                    _buildDetailRow(context, Icons.numbers_rounded, 'Roll No', user.rollNumber ?? 'Not assigned'),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(UserModel user) {
    return Container(
      width: 80.r,
      height: 80.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Text(
        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 32.sp,
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceDarker : AppColors.background,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 24.r, color: AppColors.primary),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
