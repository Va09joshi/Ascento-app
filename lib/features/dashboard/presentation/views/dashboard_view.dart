import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ascento_abacus/core/theme/app_colors.dart';
import 'package:ascento_abacus/core/widgets/app_card.dart';
import 'package:ascento_abacus/core/widgets/app_shimmer.dart';
import 'package:ascento_abacus/shared/router/route_names.dart';
import 'package:ascento_abacus/shared/models/feature_models.dart';
import 'package:ascento_abacus/shared/providers/feature_providers.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final profileAsync = ref.watch(studentProfileProvider);
    final attendanceAsync = ref.watch(attendanceSummaryProvider);
    final examsAsync = ref.watch(examScheduleProvider);
    final feesAsync = ref.watch(feeHistoryProvider);
    final homeworkAsync = ref.watch(homeworkListProvider(null));

    // Initial loading skeleton state when dynamic database metrics are resolving
    final bool isInitialLoading =
        (profileAsync.isLoading && !profileAsync.hasValue) ||
        (attendanceAsync.isLoading && !attendanceAsync.hasValue) ||
        (examsAsync.isLoading && !examsAsync.hasValue) ||
        (feesAsync.isLoading && !feesAsync.hasValue) ||
        (homeworkAsync.isLoading && !homeworkAsync.hasValue);

    if (isInitialLoading) {
      return _buildShimmerSkeleton(context, isDark, theme);
    }

    final profile = profileAsync.asData?.value;
    final String studentName = profile?.user.name ?? 'Student';
    final String classLabel = profile != null
        ? '${profile.className} - ${profile.section} | Roll No. ${profile.rollNumber}'
        : 'Class 8 - A | Roll No. 12';

    final attendance = attendanceAsync.asData?.value;
    final double attendancePercent = attendance?.percentage ?? 0;

    final exams = examsAsync.asData?.value ?? <ExamSchedule>[];
    final now = DateTime.now();
    final upcomingExams = exams
        .where((e) => !e.date.isBefore(DateTime(now.year, now.month, now.day)))
        .toList();

    final fees = feesAsync.asData?.value ?? <FeeRecord>[];
    final double pendingFees = fees
        .where((f) => f.status != PaymentStatus.paid)
        .fold<double>(0, (sum, f) => sum + f.balanceDue);

    final homework = homeworkAsync.asData?.value ?? <HomeworkItem>[];
    final int pendingHomework = homework
        .where(
          (h) =>
              h.status == HomeworkStatus.pending ||
              h.status == HomeworkStatus.late ||
              h.isOverdue,
        )
        .length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(
                isDark: isDark,
                studentName: studentName,
                classLabel: classLabel,
                subtitle: 'You ranked 3rd in class this month!',
              ),
              SizedBox(height: 20.h),

              Text(
                'Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Attendance',
                      value: attendance != null
                          ? '${attendancePercent.toStringAsFixed(0)}%'
                          : '--',
                      icon: Icons.calendar_month_rounded,
                      color: const Color(0xFF2FAE78),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _StatCard(
                      title: 'Upcoming Exams',
                      value: upcomingExams.isNotEmpty
                          ? '${upcomingExams.length}'
                          : '--',
                      icon: Icons.edit_calendar_rounded,
                      color: const Color(0xFFFF8A34),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Pending Fees',
                      value: feesAsync.asData != null
                          ? 'Rs ${pendingFees.toStringAsFixed(0)}'
                          : '--',
                      icon: Icons.account_balance_wallet_rounded,
                      color: const Color(0xFF6C4ED9),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _StatCard(
                      title: 'Homework',
                      value: homeworkAsync.asData != null
                          ? '$pendingHomework pending'
                          : '--',
                      icon: Icons.menu_book_rounded,
                      color: const Color(0xFFE85A9A),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickAction(
                    label: 'Timetable',
                    icon: Icons.access_time_rounded,
                    color: const Color(0xFF5B67F4),
                    onTap: () => context.go(RoutePaths.timetable),
                  ),
                  _QuickAction(
                    label: 'Reports',
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFF23B07D),
                    onTap: () => context.go(RoutePaths.exams),
                  ),
                  _QuickAction(
                    label: 'Homework',
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFFFF7A3A),
                    onTap: () => context.go(RoutePaths.homework),
                  ),
                  _QuickAction(
                    label: 'Enquiry',
                    icon: Icons.campaign_rounded,
                    color: const Color(0xFFF6A400),
                    onTap: () => context.go(RoutePaths.enquiry),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Exams',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(RoutePaths.exams),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              if (upcomingExams.isEmpty)
                AppCard(
                  child: Text(
                    'No exams scheduled',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                )
              else
                ...upcomingExams.take(2).map((exam) => _ExamTile(exam: exam)),
            ],
          ),
        ),
      ),
    );
  }

  // --- Centralized Dashboard Shimmer Skeleton Loader ---
  Widget _buildShimmerSkeleton(BuildContext context, bool isDark, ThemeData theme) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Shimmer Header Card
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppShimmer.circle(size: 52.r),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppShimmer(width: 80.w, height: 10.h),
                              SizedBox(height: 6.h),
                              AppShimmer(width: 160.w, height: 16.h),
                              SizedBox(height: 6.h),
                              AppShimmer(width: 120.w, height: 12.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                              .withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            color: isDark ? AppColors.info : const Color(0xFFFFB100),
                            size: 18,
                          ),
                          SizedBox(width: 10.w),
                          const Expanded(
                            child: AppShimmer(width: double.infinity, height: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              Text(
                'Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.all(14.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppShimmer(width: 40.w, height: 40.w, borderRadius: 14.r),
                          SizedBox(height: 12.h),
                          AppShimmer(width: 70.w, height: 10.h),
                          SizedBox(height: 6.h),
                          AppShimmer(width: 50.w, height: 16.h),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppCard(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.all(14.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppShimmer(width: 40.w, height: 40.w, borderRadius: 14.r),
                          SizedBox(height: 12.h),
                          AppShimmer(width: 90.w, height: 10.h),
                          SizedBox(height: 6.h),
                          AppShimmer(width: 30.w, height: 16.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.all(14.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppShimmer(width: 40.w, height: 40.w, borderRadius: 14.r),
                          SizedBox(height: 12.h),
                          AppShimmer(width: 80.w, height: 10.h),
                          SizedBox(height: 6.h),
                          AppShimmer(width: 65.w, height: 16.h),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppCard(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.all(14.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppShimmer(width: 40.w, height: 40.w, borderRadius: 14.r),
                          SizedBox(height: 12.h),
                          AppShimmer(width: 75.w, height: 10.h),
                          SizedBox(height: 6.h),
                          AppShimmer(width: 85.w, height: 16.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickAction(
                    label: 'Timetable',
                    icon: Icons.access_time_rounded,
                    color: const Color(0xFF5B67F4),
                    onTap: () => context.go(RoutePaths.timetable),
                  ),
                  _QuickAction(
                    label: 'Reports',
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFF23B07D),
                    onTap: () => context.go(RoutePaths.exams),
                  ),
                  _QuickAction(
                    label: 'Homework',
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFFFF7A3A),
                    onTap: () => context.go(RoutePaths.homework),
                  ),
                  _QuickAction(
                    label: 'Enquiry',
                    icon: Icons.campaign_rounded,
                    color: const Color(0xFFF6A400),
                    onTap: () => context.go(RoutePaths.enquiry),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Exams',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(RoutePaths.exams),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Shimmering exam list items mimicking real cards
              ...List.generate(2, (index) => AppCard(
                margin: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    AppShimmer(width: 48.w, height: 48.w, borderRadius: 14.r),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppShimmer(width: 120.w, height: 12.h),
                          SizedBox(height: 6.h),
                          AppShimmer(width: 80.w, height: 10.h),
                        ],
                      ),
                    ),
                    AppShimmer(width: 70.w, height: 24.h, borderRadius: 16.r),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final bool isDark;
  final String studentName;
  final String classLabel;
  final String subtitle;

  const _HeaderCard({
    required this.isDark,
    required this.studentName,
    required this.classLabel,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26.r,
                backgroundColor: (isDark ? AppColors.darkPrimary : AppColors.primary)
                    .withValues(alpha: 0.12),
                child: Text(
                  studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20.sp,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      studentName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      classLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: (isDark ? AppColors.darkPrimary : AppColors.primary)
                    .withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  color: isDark ? AppColors.info : const Color(0xFFFFB100),
                  size: 18,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.18),
                  color.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ExamTile extends StatelessWidget {
  final ExamSchedule exam;
  const _ExamTile({required this.exam});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${exam.date.day}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  _monthShort(exam.date.month),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.subject,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  exam.time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              '${exam.date.day} ${_monthShort(exam.date.month)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
