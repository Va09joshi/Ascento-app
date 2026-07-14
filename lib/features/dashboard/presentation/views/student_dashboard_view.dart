import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ascento_abacus/shared/providers/feature_providers.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';

class StudentDashboardView extends ConsumerWidget {
  const StudentDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(authControllerProvider).currentUser;

    // Fetch live stats
    final attendanceAsync = ref.watch(attendanceSummaryProvider);
    final examsAsync = ref.watch(examScheduleProvider);
    final feesAsync = ref.watch(feeHistoryProvider);
    final homeworkAsync = ref.watch(homeworkListProvider(null));

    // Calculate values safely
    final attendancePct = attendanceAsync.valueOrNull?.percentage ?? 0.0;
    
    // Count only upcoming exams (future dates)
    final now = DateTime.now();
    final upcomingExamsCount = examsAsync.valueOrNull?.where((e) => e.date.isAfter(now)).length ?? 0;
    
    // Sum pending/overdue fees
    final pendingFees = feesAsync.valueOrNull?.where((f) => f.balanceDue > 0).fold<double>(0, (sum, f) => sum + f.balanceDue) ?? 0.0;
    
    // Count pending homeworks
    final pendingHomeworkCount = homeworkAsync.valueOrNull?.where((h) => h.status == HomeworkStatus.pending).length ?? 0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header Card
              _buildUserHeader(context, user, isDark),
              SizedBox(height: 32.h),

              // Overview Section
              Text(
                'Overview',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.calendar_month_rounded,
                      iconColor: const Color(0xFF2FAE78),
                      iconBgColor: const Color(0xFFE8F6EF),
                      title: 'Attendance',
                      value: '${attendancePct.toStringAsFixed(0)}%',
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildOverviewCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.assignment_turned_in_rounded,
                      iconColor: const Color(0xFFFF7A59),
                      iconBgColor: const Color(0xFFFFF0EC),
                      title: 'Upcoming Exams',
                      value: '$upcomingExamsCount',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: _buildOverviewCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.account_balance_wallet_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      iconBgColor: const Color(0xFFF3EDFF),
                      title: 'Pending Fees',
                      value: 'Rs ${pendingFees.toStringAsFixed(0)}',
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildOverviewCard(
                      context: context,
                      isDark: isDark,
                      icon: Icons.menu_book_rounded,
                      iconColor: const Color(0xFFE85A9A),
                      iconBgColor: const Color(0xFFFDEDF5),
                      title: 'Homework',
                      value: '$pendingHomeworkCount pending',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // Quick Actions Section
              Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickActionButton(
                    context: context,
                    icon: Icons.schedule_rounded,
                    color: const Color(0xFF6366F1), // Indigo
                    label: 'Timetable',
                    onTap: () => context.go(RoutePaths.timetable),
                  ),
                  _buildQuickActionButton(
                    context: context,
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFF10B981), // Emerald
                    label: 'Reports',
                    onTap: () => context.go(RoutePaths.exams),
                  ),
                  _buildQuickActionButton(
                    context: context,
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFFF97316), // Orange
                    label: 'Homework',
                    onTap: () {}, // Navigate to homework when available
                  ),
                  _buildQuickActionButton(
                    context: context,
                    icon: Icons.campaign_rounded,
                    color: const Color(0xFFF59E0B), // Amber
                    label: 'Enquiry',
                    onTap: () {}, // Navigate to enquiry when available
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, dynamic user, bool isDark) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60.w,
                height: 60.h,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'V',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      user?.name ?? 'Vaibhav Joshi',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '- | Roll No. ${user?.id.substring(0, 4) ?? '---'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B), size: 20),
                SizedBox(width: 8.w),
                Text(
                  'You ranked 3rd in class this month!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: isDark ? iconColor.withOpacity(0.15) : iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: isDark ? [] : [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 28.sp),
          ),
          SizedBox(height: 10.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
